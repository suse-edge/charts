#!/bin/bash -xe
#CACHEURL=http://172.22.0.1/images

# Check and set http(s)_proxy. Required for cURL to use a proxy
export http_proxy=${http_proxy:-$HTTP_PROXY}
export https_proxy=${https_proxy:-$HTTPS_PROXY}
export no_proxy=${no_proxy:-$NO_PROXY}

# Which image should we use
if [ -z "${IPA_BASEURI}" ]; then
  # SLES BASED IPA - openstack-ironic-image-x86_64 package
  mkdir -p /shared/html/images
  cp /tmp/initrd.xz /shared/html/images/ironic-python-agent.initramfs
  cp /tmp/openstack-ironic-image.x86_64*.kernel /shared/html/images/ironic-python-agent.kernel
else
  FILENAME=ironic-python-agent
  FILENAME_EXT=.tar
  FFILENAME=$FILENAME$FILENAME_EXT
  
  mkdir -p /shared/html/images /shared/tmp
  cd /shared/html/images
  
  TMPDIR=$(mktemp -d -p /shared/tmp)
  
  # If we have a CACHEURL and nothing has yet been downloaded
  # get header info from the cache
  ls -l
  if [ -n "$CACHEURL" -a ! -e $FFILENAME.headers ] ; then
      curl -g --verbose --fail -O "$CACHEURL/$FFILENAME.headers" || true
  fi
  
  # Download the most recent version of IPA
  if [ -e $FFILENAME.headers ] ; then
      ETAG=$(awk '/ETag:/ {print $2}' $FFILENAME.headers | tr -d "\r")
      cd $TMPDIR
      curl -g --verbose --dump-header $FFILENAME.headers -O $IPA_BASEURI/$FFILENAME --header "If-None-Match: $ETAG" || cp /shared/html/images/$FFILENAME.headers .
      # curl didn't download anything because we have the ETag already
      # but we don't have it in the images directory
      # Its in the cache, go get it
      ETAG=$(awk '/ETag:/ {print $2}' $FFILENAME.headers | tr -d "\"\r")
      if [ ! -s $FFILENAME -a ! -e /shared/html/images/$FILENAME-$ETAG/$FFILENAME ] ; then
          mv /shared/html/images/$FFILENAME.headers .
          curl -g --verbose -O "$CACHEURL/$FILENAME-$ETAG/$FFILENAME"
      fi
  else
      cd $TMPDIR
      curl -g --verbose --dump-header $FFILENAME.headers -O $IPA_BASEURI/$FFILENAME
  fi
  
  if [ -s $FFILENAME ] ; then
      tar -xf $FFILENAME
  
      ETAG=$(awk '/ETag:/ {print $2}' $FFILENAME.headers | tr -d "\"\r")
      cd -
      chmod 755 $TMPDIR
      mv $TMPDIR $FILENAME-$ETAG
      ln -sf $FILENAME-$ETAG/$FFILENAME.headers $FFILENAME.headers
      ln -sf $FILENAME-$ETAG/$FILENAME.initramfs $FILENAME.initramfs
      ln -sf $FILENAME-$ETAG/$FILENAME.kernel $FILENAME.kernel
  else
      rm -rf $TMPDIR
  fi
fi
