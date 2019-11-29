#!/bin/bash

# you can provide your own domain name (used in the exercises of chapter B)
# by setting (and exporting) the environment variable DOMAIN_NAME_CHAPTER_B
# before starting this script
DOMAIN_NAME_CHAPTER_B=${DOMAIN_NAME_CHAPTER_B:-exercise.jumpingcrab.com}

HEADLINE_COLOR='\033[1;34m'
RED='\033[1;31m'
GREEN='\033[1;32m'
ORANGE='\033[0;33m'
NO_COLOR='\033[0m'

SUCCESS_COUNT=0
ERROR_COUNT=0
SKIPPED_COUNT=0

function success {
    echo -e "::: Result: ${GREEN}OK${NO_COLOR}"
    SUCCESS_COUNT=$(( $SUCCESS_COUNT + 1 ))
}

function error {
    echo -e "::: Result: ${RED}ERROR${NO_COLOR}"
    ERROR_COUNT=$(( $ERROR_COUNT + 1 ))
}

function skipped {
    echo -e "::: Result: ${ORANGE}Skipped${NO_COLOR}"
    SKIPPED_COUNT=$(( $SKIPPED_COUNT + 1 ))
}

echo -e ":::"
echo -e "::: ###################################################################"
echo -e "::: ${HEADLINE_COLOR}solving exercise A.1${NO_COLOR}"
echo -e "::: ###################################################################"
echo -e ":::"

echo -e "::: ${HEADLINE_COLOR}generating key${NO_COLOR}"
openssl genrsa -out /home/vagrant/example.com.key 2048 && success || error

echo -e "::: ${HEADLINE_COLOR}generating CSR${NO_COLOR}"
openssl req -new -key /home/vagrant/example.com.key -out /home/vagrant/example.com.csr -subj "/C=DE/ST=Franconia/L=Nuernberg/O=Raffzahn GmbH/CN=example.com/emailAddress=certificates@example.com" && success || error

echo -e "::: ${HEADLINE_COLOR}generating certificate${NO_COLOR}"
openssl x509 -req -days 365 -in /home/vagrant/example.com.csr -signkey /home/vagrant/example.com.key -out /home/vagrant/example.com.crt && success || error

echo -e "::: ${HEADLINE_COLOR}Apache config exercise-A1.conf${NO_COLOR}"
sudo cp /vagrant/exercises/A1/apache_conf.d/exercise-A1.conf /etc/httpd/conf.d/ && success || error

echo -e "::: ${HEADLINE_COLOR}restarting Apache${NO_COLOR}"
sudo systemctl restart httpd && success || error

echo -e ":::"
echo -e "::: ###################################################################"
echo -e "::: ${HEADLINE_COLOR}solving exercise A.2${NO_COLOR}"
echo -e "::: ###################################################################"
echo -e ":::"

echo -e "::: ${HEADLINE_COLOR}generating key${NO_COLOR}"
openssl genrsa -out /home/vagrant/localhost.key 2048 && success || error

echo -e "::: ${HEADLINE_COLOR}generating CSR${NO_COLOR}"
openssl req -new -key /home/vagrant/localhost.key -out /home/vagrant/localhost.csr -subj "/C=DE/ST=Franconia/L=Nuernberg/O=Raffzahn GmbH/CN=localhost/emailAddress=certificates@example.com" && success || error

echo -e "::: ${HEADLINE_COLOR}generating certificate${NO_COLOR}"
openssl x509 -req -days 365 -in /home/vagrant/localhost.csr -signkey /home/vagrant/localhost.key -out /home/vagrant/localhost.crt && success || error

echo -e "::: ${HEADLINE_COLOR}Apache config exercise-A2.conf${NO_COLOR}"
sudo cp /vagrant/exercises/A2/apache_conf.d/exercise-A2.conf /etc/httpd/conf.d/ && success || error

echo -e "::: ${HEADLINE_COLOR}restarting Apache${NO_COLOR}"
sudo systemctl restart httpd && success || error

echo -e "::: ${HEADLINE_COLOR}creating localhost.keystore.p12${NO_COLOR}"
openssl pkcs12 -export -in /home/vagrant/localhost.crt -inkey /home/vagrant/localhost.key -out /home/vagrant/localhost.keystore.p12 -passout pass:test && success || error

echo -e "::: ${HEADLINE_COLOR}creating localhost.truststore.p12${NO_COLOR}"
openssl pkcs12 -export -in /home/vagrant/localhost.crt -nokeys -out /home/vagrant/localhost.truststore.p12 -passout pass:test && success || error

echo -e ":::"
echo -e "::: ###################################################################"
echo -e "::: ${HEADLINE_COLOR}solving exercise A.3${NO_COLOR}"
echo -e "::: ###################################################################"
echo -e ":::"

echo -e "::: ${HEADLINE_COLOR}checking for previous created CA and removing it${NO_COLOR}"
if [[ -d /home/vagrant/ca ]]; then
    rm -Rf /home/vagrant/ca && success || error
else
    echo not existing
fi

echo -e "::: ${HEADLINE_COLOR}preparing config for the CA${NO_COLOR}"
/vagrant/exercises/A3/prepare_CA.sh /home/vagrant && success || error

echo -e "::: ${HEADLINE_COLOR}generating CA key${NO_COLOR}"
openssl genrsa -out /home/vagrant/ca/private/cacert.key 4096 && success || error

echo -e "::: ${HEADLINE_COLOR}generating CA certificate${NO_COLOR}"
openssl req -config /home/vagrant/ca/ca.cnf -new -x509 -days 3650 -key /home/vagrant/ca/private/cacert.key -out /home/vagrant/ca/cacert.pem -subj "/C=DE/ST=Franconia/L=Nuernberg/O=Raffzahn GmbH/CN=Raffzahn CA/emailAddress=certificates@example.com" && success || error

echo -e "::: ${HEADLINE_COLOR}generating server key${NO_COLOR}"
openssl genrsa -out /home/vagrant/server.key 2048 && success || error

echo -e "::: ${HEADLINE_COLOR}generating CSR${NO_COLOR}"
openssl req -new -key /home/vagrant/server.key -out /home/vagrant/server.csr -subj "/C=DE/ST=Franconia/L=Nuernberg/O=Raffzahn GmbH/CN=localhost/emailAddress=certificates@example.com" && success || error

echo -e "::: ${HEADLINE_COLOR}signing with CA certificate (creating server certificate)${NO_COLOR}"
openssl ca -batch -config /home/vagrant/ca/ca.cnf -extensions server_cert -days 365 -in /home/vagrant/server.csr -out /home/vagrant/server.crt && success || error

echo -e "::: ${HEADLINE_COLOR}Apache config exercise-A3.conf${NO_COLOR}"
sudo cp /vagrant/exercises/A3/apache_conf.d/exercise-A3.conf /etc/httpd/conf.d/ && success || error

echo -e "::: ${HEADLINE_COLOR}restarting Apache${NO_COLOR}"
sudo systemctl restart httpd && success || error

echo -e "::: ${HEADLINE_COLOR}creating server.keystore.p12${NO_COLOR}"
openssl pkcs12 -export -in /home/vagrant/server.crt -inkey /home/vagrant/server.key -out /home/vagrant/server.keystore.p12 -passout pass:test && success || error

echo -e "::: ${HEADLINE_COLOR}creating truststore.ca.p12${NO_COLOR}"
openssl pkcs12 -export -in /home/vagrant/ca/cacert.pem -nokeys -out /home/vagrant/ca/truststore.ca.p12 -passout pass:test && success || error

echo -e ":::"
echo -e "::: ###################################################################"
echo -e "::: ${HEADLINE_COLOR}solving exercise A.4${NO_COLOR}"
echo -e "::: ###################################################################"
echo -e ":::"

echo -e "::: ${HEADLINE_COLOR}generating client key${NO_COLOR}"
openssl genrsa -out /home/vagrant/client.key 2048 && success || error

echo -e "::: ${HEADLINE_COLOR}generating CSR${NO_COLOR}"
openssl req -new -key /home/vagrant/client.key -out /home/vagrant/client.csr -subj "/C=DE/ST=Franconia/L=Nuernberg/O=Raffzahn GmbH/CN=User Hans Wurst/emailAddress=hans.wurst@example.com" && success || error

echo -e "::: ${HEADLINE_COLOR}signing with CA certificate (creating client certificate)${NO_COLOR}"
openssl ca -batch -config /home/vagrant/ca/ca.cnf -extensions client_cert -days 365 -in /home/vagrant/client.csr -out /home/vagrant/client.crt && success || error

echo -e "::: ${HEADLINE_COLOR}Apache config exercise-A4.conf${NO_COLOR}"
sudo cp /vagrant/exercises/A4/apache_conf.d/exercise-A4.conf /etc/httpd/conf.d/ && success || error

echo -e "::: ${HEADLINE_COLOR}restarting Apache${NO_COLOR}"
sudo systemctl restart httpd && success || error

echo -e "::: ${HEADLINE_COLOR}creating client.keystore.p12${NO_COLOR}"
openssl pkcs12 -export -in /home/vagrant/client.crt -inkey /home/vagrant/client.key -out /home/vagrant/client.keystore.p12 -passout pass:test && success || error

echo -e ":::"
echo -e "::: ###################################################################"
echo -e "::: ${HEADLINE_COLOR}solving exercise B.1${NO_COLOR}"
echo -e "::: ###################################################################"
echo -e ":::"

sudo stat /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/cert.pem >/dev/null 2>/dev/null
CERT_FILE_RC=$?
sudo stat /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/chain.pem >/dev/null 2>/dev/null
CHAIN_FILE_RC=$?
sudo stat /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/privkey.pem >/dev/null 2>/dev/null
KEY_FILE_RC=$?

if [[ $CERT_FILE_RC -eq 0 ]] && [[ $CHAIN_FILE_RC -eq 0 ]] && [[ $KEY_FILE_RC -eq 0 ]]; then
    echo -e "::: ${HEADLINE_COLOR}Apache config exercise-B1.conf${NO_COLOR}"
    sudo cp /vagrant/exercises/B1/apache_conf.d/exercise-B1.conf /etc/httpd/conf.d/ && success || error

    echo -e "::: ${HEADLINE_COLOR}restarting Apache${NO_COLOR}"
    sudo systemctl restart httpd && success || error

    echo -e "::: ${HEADLINE_COLOR}creating ${DOMAIN_NAME_CHAPTER_B}.keystore.p12${NO_COLOR}"
    sudo openssl pkcs12 -export -in /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/cert.pem -inkey /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/privkey.pem -certfile /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/chain.pem -out /home/vagrant/${DOMAIN_NAME_CHAPTER_B}.keystore.p12 -passout pass:test && success || error
else
    echo -e "::: WARNING: Certificate files for ${DOMAIN_NAME_CHAPTER_B} are missing, see Prerequisites"
    skipped
fi

echo -e ":::"
echo -e "::: ###################################################################"
echo -e "::: ${HEADLINE_COLOR}solving exercise B.2${NO_COLOR}"
echo -e "::: ###################################################################"
echo -e ":::"

sudo stat /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/cert.pem >/dev/null 2>/dev/null
CERT_FILE_RC=$?
sudo stat /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/chain.pem >/dev/null 2>/dev/null
CHAIN_FILE_RC=$?
sudo stat /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/privkey.pem >/dev/null 2>/dev/null
KEY_FILE_RC=$?

echo -e "::: ${HEADLINE_COLOR}checking for previous created clientcrt directory and removing it${NO_COLOR}"
if [[ -d /home/vagrant/clientcrt ]]; then
    rm -Rf /home/vagrant/clientcrt && success || error
else
    echo not existing
fi

echo -e "::: ${HEADLINE_COLOR}creating clientcrt directory${NO_COLOR}"
mkdir /home/vagrant/clientcrt && chmod 700 /home/vagrant/clientcrt/ && success || error

if [[ $CERT_FILE_RC -eq 0 ]] && [[ $CHAIN_FILE_RC -eq 0 ]] && [[ $KEY_FILE_RC -eq 0 ]]; then
    echo -e "::: ${HEADLINE_COLOR}populating ~/clientcrt/${NO_COLOR}"
    for PEM_LINK in \
        /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/cert.pem \
        /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/chain.pem \
        /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/fullchain.pem \
        /etc/letsencrypt/live/${DOMAIN_NAME_CHAPTER_B}/privkey.pem
    do
        PEM_FILE=$(sudo readlink -f $PEM_LINK) && sudo cp $PEM_FILE ~/clientcrt/ && success || error
    done

    echo -e "::: ${HEADLINE_COLOR}Apache config exercise-B2.conf${NO_COLOR}"
    sudo cp /vagrant/exercises/B2/apache_conf.d/exercise-B2.conf /etc/httpd/conf.d/ && success || error

    echo -e "::: ${HEADLINE_COLOR}reloading Apache${NO_COLOR}"
    sudo systemctl reload httpd && success || error

    echo -e "::: ${HEADLINE_COLOR}creating client.keystore.p12${NO_COLOR}"
    openssl pkcs12 -export -in /home/vagrant/clientcrt/cert1.pem -inkey /home/vagrant/clientcrt/privkey1.pem -certfile /home/vagrant/clientcrt/chain1.pem -out /home/vagrant/clientcrt/client.keystore.p12 -passout pass:test && success || error
else
    echo -e "::: WARNING: Certificate files for ${DOMAIN_NAME_CHAPTER_B} are missing, see Prerequisites"
    skipped
fi

echo -e ":::"
echo -e "::: ###################################################################"
echo -e "::: ${HEADLINE_COLOR}solving exercise B.3${NO_COLOR}"
echo -e "::: ###################################################################"
echo -e ":::"

echo -e "::: ${HEADLINE_COLOR}Getting certificate for github.com${NO_COLOR}"
openssl s_client -connect github.com:443 </dev/null >/tmp/github.com.pem && success || error
sed -i -n '/-----BEGIN/,/-----END/p' /tmp/github.com.pem && success || error

echo -e "::: ${HEADLINE_COLOR}Extracting CRL URL${NO_COLOR}"
GITHUB_COM_CRL_URI=$(openssl x509 -in /tmp/github.com.pem -noout -text | grep -A 6 "X509v3 CRL Distribution Points" | grep "http://" | head -1 | sed -e "s/.*URI://")
if [[ -z $GITHUB_COM_CRL_URI ]]; then
    error
else
    success
fi

echo -e "::: ${HEADLINE_COLOR}Getting CRL for github.com${NO_COLOR}"
wget -O /tmp/crl.for.github.com.crl $GITHUB_COM_CRL_URI && success || error

echo -e "::: ${HEADLINE_COLOR}Getting chain certificate for github.com${NO_COLOR}"
openssl s_client -showcerts -connect github.com:443 </dev/null >/tmp/github.com.chain.pem && success || error
sed -i -n '/-----BEGIN/,/-----END/p' /tmp/github.com.chain.pem && sed -i '0,/^-----END CERTIFICATE-----$/d' /tmp/github.com.chain.pem && success || error


# echo -e "::: ${HEADLINE_COLOR}preparing config for the B.3 CA (issuing client certificates)${NO_COLOR}"
# WORKING_DIR=/home/vagrant
# mkdir $WORKING_DIR/ca.B3 && success || error
# mkdir $WORKING_DIR/ca.B3/newcerts && success || error
# mkdir $WORKING_DIR/ca.B3/private && success || error
# chmod 700 $WORKING_DIR/ca.B3/private && success || error
# echo -ne "01" >$WORKING_DIR/ca.B3/serial && success || error
# echo -ne "01" >$WORKING_DIR/ca.B3/crlnumber && success || error
# touch $WORKING_DIR/ca.B3/index.txt && success || error
# touch $WORKING_DIR/ca.B3/index.txt.attr && success || error
# cp /vagrant/exercises/A3/openssl/ca.cnf $WORKING_DIR/ca/ && success || error
# echo -e "::: ${HEADLINE_COLOR}generating B.3 Root CA key${NO_COLOR}"
# openssl genrsa -out /home/vagrant/ca.B3/private/cacert.key 4096 && success || error
#
# echo -e "::: ${HEADLINE_COLOR}generating B.3 Root CA certificate${NO_COLOR}"
# openssl req -config /home/vagrant/ca.B3/ca.cnf -new -x509 -days 3650 -key /home/vagrant/ca.B3/private/cacert.key -out /home/vagrant/ca.B3/cacert.pem -subj "/C=DE/ST=Franconia/L=Nuernberg/O=Raffzahn GmbH/CN=Raffzahn B.3 Root CA/emailAddress=certificates@example.com" && success || error
#
# echo -e "::: ${HEADLINE_COLOR}generating B.3 Intermediate CA key${NO_COLOR}"
# @ToDo: add the command
#
# echo -e "::: ${HEADLINE_COLOR}generating B.3 Intermediate CA certificate${NO_COLOR}"
# @ToDo: add the command (sign with B.3 Root CA)
#
# echo -e "::: ${HEADLINE_COLOR}generating client key${NO_COLOR}"
# openssl genrsa -out /home/vagrant/client.key 2048 && success || error
#
# echo -e "::: ${HEADLINE_COLOR}generating CSR${NO_COLOR}"
# openssl req -new -key /home/vagrant/client.key -out /home/vagrant/client.csr -subj "/C=DE/ST=Franconia/L=Nuernberg/O=Raffzahn GmbH/CN=User Hans Wurst/emailAddress=hans.wurst@example.com" && success || error
#
# echo -e "::: ${HEADLINE_COLOR}signing with  B.3 Intermediate CA (creating client certificate)${NO_COLOR}"
# openssl ca -batch -config /home/vagrant/ca/ca.cnf -extensions client_cert -days 365 -in /home/vagrant/client.csr -out /home/vagrant/client.crt && success || error

# @ToDo: generate a second client certificate
# @ToDo: revoke it
# @ToDo: generate CRL

echo -e "::: ${HEADLINE_COLOR}Apache config exercise-B3.ocsp.conf${NO_COLOR}"
sudo cp /vagrant/exercises/B3/apache_conf.d/exercise-B3.ocsp.conf /etc/httpd/conf.d/ && success || error

# echo -e "::: ${HEADLINE_COLOR}Apache config exercise-B3.crl.conf${NO_COLOR}"
# sudo cp /vagrant/exercises/B3/apache_conf.d/exercise-B3.crl.conf /etc/httpd/conf.d/ && success || error

echo -e "::: ${HEADLINE_COLOR}reloading Apache${NO_COLOR}"
sudo systemctl reload httpd && success || error

echo -e ":::"
echo -e "::: ###################################################################"
echo -e "::: ${HEADLINE_COLOR}Summary:${NO_COLOR}"
echo -e "::: Total successful:  ${GREEN}${SUCCESS_COUNT}${NO_COLOR}"
echo -e "::: Total skipped:     ${ORANGE}${SKIPPED_COUNT}${NO_COLOR}"
echo -e "::: Total errors:      ${RED}${ERROR_COUNT}${NO_COLOR}"
echo -e "::: ###################################################################"
echo -e ":::"