#!/usr/bin/bash

. /bin/tls-common.sh

. /bin/ironic-common.sh

export HTTP_PORT=${HTTP_PORT:-"80"}
export VMEDIA_TLS_PORT=${VMEDIA_TLS_PORT:-8083}

INSPECTOR_ORIG_HTTPD_CONFIG=/etc/apache2/conf.d/inspector-apache.conf.j2
INSPECTOR_RESULT_HTTPD_CONFIG=/etc/apache2/conf.d/ironic-inspector.conf
export IRONIC_REVERSE_PROXY_SETUP=${IRONIC_REVERSE_PROXY_SETUP:-"false"}
export INSPECTOR_REVERSE_PROXY_SETUP=${INSPECTOR_REVERSE_PROXY_SETUP:-"false"}

# Whether to enable fast_track provisioning or not
IRONIC_FAST_TRACK=${IRONIC_FAST_TRACK:-true}

wait_for_interface_or_ip

mkdir -p /shared/html
chmod 0777 /shared/html

IRONIC_BASE_URL="${IRONIC_SCHEME}://${IRONIC_URL_HOST}"

if [[ $IRONIC_FAST_TRACK == true ]]; then
    INSPECTOR_EXTRA_ARGS=" ipa-api-url=${IRONIC_API_BASE_URL} ipa-inspection-callback-url=${IRONIC_INSPECTOR_BASE_URL}/v1/continue"
else
    INSPECTOR_EXTRA_ARGS=" ipa-inspection-callback-url=${IRONIC_INSPECTOR_BASE_URL}/v1/continue"
fi

. /bin/coreos-ipa-common.sh

# Copy files to shared mount
render_j2_config /tmp/inspector.ipxe.j2 /shared/html/inspector.ipxe
cp /tmp/uefi_esp.img /shared/html/uefi_esp.img

purelib=`python3 -m sysconfig | grep purelib | head -n 1 | awk '{print $3}'`
purelib=`echo "$purelib" | tr -d '"'`
cp $purelib/ironic/drivers/modules/boot.ipxe /shared/html/boot.ipxe

if [ "$IRONIC_INSPECTOR_TLS_SETUP" = "true" ]; then
    if [[ "${INSPECTOR_REVERSE_PROXY_SETUP}" == "true" ]]; then
        render_j2_config $INSPECTOR_ORIG_HTTPD_CONFIG $INSPECTOR_RESULT_HTTPD_CONFIG
    fi
    # Add user 'apache' to the group `ironic-inspector`, so httpd can access /etc/ironic-inspector and read the pasword file
    usermod -aG ironic-inspector apache
else
    export INSPECTOR_REVERSE_PROXY_SETUP="false" # If TLS is not used, we have no reason to use the reverse proxy
fi

if [ "$IRONIC_TLS_SETUP" = "true" ]; then
    if [[ "${IRONIC_REVERSE_PROXY_SETUP}" == "true" ]]; then
        render_j2_config /etc/httpd-ironic-api.conf.j2 /etc/apache2/conf.d/ironic.conf
    fi
    # Add user 'apache' to the group `ironic-inspector`, so httpd can access /etc/ironic-inspector and read the pasword file
    usermod -aG ironic apache
else
    export IRONIC_REVERSE_PROXY_SETUP="false" # If TLS is not used, we have no reason to use the reverse proxy
fi

export IRONIC_HTPASSWD=${IRONIC_HTPASSWD:-${HTTP_BASIC_HTPASSWD:-}}
export INSPECTOR_HTPASSWD=${INSPECTOR_HTPASSWD:-${HTTP_BASIC_HTPASSWD:-}}

# Configure HTTP basic auth for API server
if [ -n "${IRONIC_HTPASSWD:-}" ]; then
    printf "%s\n" "${IRONIC_HTPASSWD}" > /etc/ironic/htpasswd
fi
if [ -n "${INSPECTOR_HTPASSWD:-}" ]; then
    printf "%s\n" "${INSPECTOR_HTPASSWD}" > /etc/ironic-inspector/htpasswd
fi

if [[ "${LISTEN_ALL_INTERFACES}" == "true" ]]; then
    sed -i 's/^Listen .*$/Listen [::]:'"$HTTP_PORT"'/' /etc/apache2/listen.conf
else
    sed -i 's/^Listen .*$/Listen '"$IRONIC_URL_HOST"':'"$HTTP_PORT"'/' /etc/apache2/listen.conf
fi

sed -i -e 's|\(^[[:space:]]*\)\(DocumentRoot\)\(.*\)|\1\2 "/shared/html"|' /etc/apache2/default-server.conf
cat /tmp/docroot_shared >> /etc/apache2/default-server.conf

# Log to std out/err
grep -qxF 'CustomLog /dev/stderr combined' /etc/apache2/httpd.conf || echo 'CustomLog /dev/stderr combined' >> /etc/apache2/httpd.conf
sed -i -e 's%^ErrorLog.*%ErrorLog /dev/stderr%g' /etc/apache2/httpd.conf

if [ "$IRONIC_VMEDIA_TLS_SETUP" = "true" ]; then
    render_j2_config /etc/httpd-vmedia.conf.j2 /etc/apache2/conf.d/vmedia.conf
fi

if [[ "$IRONIC_INSPECTOR_TLS_SETUP" == "true"  && "${RESTART_CONTAINER_CERTIFICATE_UPDATED}" == "true" ]]; then
    inotifywait -m -e delete_self "${IRONIC_INSPECTOR_CERT_FILE}" | while read file event; do
        kill -WINCH $(pgrep httpd)
    done &
fi

if [[ "$IRONIC_TLS_SETUP" == "true"  && "${RESTART_CONTAINER_CERTIFICATE_UPDATED}" == "true" ]]; then
    inotifywait -m -e delete_self "${IRONIC_CERT_FILE}" | while read file event; do
        kill -WINCH $(pgrep httpd)
    done &
fi

if [[ "$IRONIC_VMEDIA_TLS_SETUP" == "true"  && "${RESTART_CONTAINER_CERTIFICATE_UPDATED}" == "true" ]]; then
    inotifywait -m -e delete_self "${IRONIC_VMEDIA_CERT_FILE}" | while read file event; do
        kill -WINCH $(pgrep httpd)
    done &
fi

exec /usr/sbin/httpd -DFOREGROUND
