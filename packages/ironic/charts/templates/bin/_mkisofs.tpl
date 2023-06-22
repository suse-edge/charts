#! /bin/sh

# this script is intended to intercept calls to mkisofs for debugging purposes.
# the redirects are to ensure that this doesn't change the output in any way.

echo -e "\n# BEGIN CAPTURE\n"      >> /var/log/mkisofs.log 2> /dev/null
echo -e "\n# Timestamp\n"          >> /var/log/mkisofs.log 2> /dev/null
date                               >> /var/log/mkisofs.log 2> /dev/null
echo -e "\n# Environment\n"        >> /var/log/mkisofs.log 2> /dev/null
env | sort                         >> /var/log/mkisofs.log 2> /dev/null
echo -e "\n# Command\n"            >> /var/log/mkisofs.log 2> /dev/null
echo -e "${0}" "${@}"              >> /var/log/mkisofs.log 2> /dev/null
echo -e "\n# Output (STDOUT only)" >> /var/log/mkisofs.log 2> /dev/null
/usr/bin/mkisofs "${@}"      | tee -a /var/log/mkisofs.log
echo -e "\n# END CAPTURE\n"        >> /var/log/mkisofs.log 2> /dev/null

