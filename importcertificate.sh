#!/bin/bash
 
# 2017-11-29 Import the Entrust certificate into Java keystore. Note the same keystore was used to generate CSR
# 2018-02-13 DF Eval redo
# 2018-03-01 Java Truststore (jssecacerts) should have both root (G3R) and Intermediate (L1R) certificate
 
# Notes
# A PEM-encoded certificate may also have file extension of .CRT or .CER
# server cert + intermediate cert should be in server-keystore.jks
# root cert should be in Java Truststore jssecacerts
 
[[ -f ~/.bash_profile ]] && source ~/.bash_profile
 
 
DATEFMT=$(date +"%y%m%d%H%M")
SCRIPTNAME=$(basename $0)
NAME=$(echo ${SCRIPTNAME}|sed -e 's/.ksh$|.sh$//')
LOGF=${DATEFMT}.${NAME}.log
USAGE="${SCRIPTNAME} -z {Entrust zipfile} -p {passphrase file}"
 
 
while getopts  z:p:  OPT
do
   case $OPT in
      z) ZIPFILE=$OPTARG ;;
      p) PASSFILE=$OPTARG ;;
      *) echo $USAGE; exit 1 ;;
   esac
done
 
if [[ -z ${ZIPFILE} || ! -f ${PASSFILE} ]];then
   echo "$USAGE"
   exit 8
fi
if [[ -z ${JAVA_HOME} ]];then
   echo "\$JAVA_HOME is not defined"
   exit 8
fi
export PATH=${JAVA_HOME}/bin:$PATH
 
FQDN=$(hostname -f)
myHost=$(echo $FQDN|cut -d. -f1)
 
echo "Copy java truststore (jssecacerts) if doesn't exist in local dir"
 
[[ ! -f jssecacerts ]] && cp -p /usr/java/latest/jre/lib/security/cacerts jssecacerts
 
echo "Unzip Entrust zip file ${ZIPFILE}"
unzip ${ZIPFILE}
 
# Verify the certificate contents
echo "Note the hostnames in SANs ServerCertificate.crt"
echo "openssl x509 -noout -text -in ServerCertificate.crt "
openssl x509 -noout -text -in ServerCertificate.crt
echo "openssl x509 -noout -text -in  Intermediate.crt"
openssl x509 -noout -text -in  Intermediate.crt
 
echo "Convert certificates to .pem format"
echo "openssl x509 -in ServerCertificate.crt -outform PEM -out ServerCertificate.pem"
openssl x509 -in ServerCertificate.crt -outform PEM -out ServerCertificate.pem
echo "openssl x509 -in Intermediate.crt -outform PEM -out Intermediate.pem"
openssl x509 -in Intermediate.crt -outform PEM -out Intermediate.pem
echo "openssl x509 -in Root.crt -outform PEM -out Root.pem"
openssl x509 -in Root.crt -outform PEM -out Root.pem
 
echo "# Check md5 of private key"
openssl rsa -noout -modulus -in server.key -passin pass:$(cat ${PASSFILE})| openssl md5
openssl x509 -noout -modulus -in ServerCertificate.crt | openssl md5
 
echo "Import Root Certificate into Java Truststore(jssecacerts)"
keytool -importcert -keystore jssecacerts -storepass changeit -file Root.pem -alias rootca -noprompt
 
echo "Verify java truststore fingerprint"
keytool -keystore  jssecacerts -storepass changeit -list -alias rootca
 
echo "Import Intermediate Certificate into Java Truststore(jssecacerts)"
keytool -importcert -keystore jssecacerts -storepass changeit -file Intermediate.pem -alias intca -noprompt
 
echo "Verify java truststore fingerprint"
keytool -keystore  jssecacerts -storepass changeit -list -alias intca
 
# if the format is not in x509 then following error may be thrown
# keytool error: java.lang.Exception: Input not an X.509 certificate
echo "Append the intermediate cert to the signed server cert and then import it into the server keystore(server-keystore.jks)"
echo "cp ServerCertificate.pem server.crt"  # server.crt in PEM format will be copied to CM and agent servers
echo "cp ServerCertificate.pem server_int.pem"
cp ServerCertificate.pem server.crt  # exiting scripts use server.crt didnt want to change
cp ServerCertificate.pem server_int.pem
echo " " >> server_int.pem  # To ensure intermediate cert begins on new line
echo "cat Intermediate.pem >> server_int.pem"
cat Intermediate.pem >> server_int.pem
 
# For HUE
cp -p Root.pem root_int.pem
echo " " >>  root_int.pem
cat Intermediate.pem >> root_int.pem
 
if [[ -f "server_int.pem" ]];then
  # If original keystore is not available and only private key is available
  #echo "Create PKCS12 to combine Server private key + (Server certificate + intermediate certificate)"
  #openssl pkcs12 -password pass:$(cat ${PASSFILE}) -export -out server-keystore.p12 -inkey server.key -passin pass:$(cat ${PASSFILE}) -in server_int.pem -name $FQDN
 
  #echo "Create server-keystore.jks using pkcs12 file"
  #keytool -importkeystore -srckeystore server-keystore.p12 -srcstoretype PKCS12 -srcstorepass $(cat ${PASSFILE}) -alias $FQDN -deststorepass $(cat ${PASSFILE}) -destkeypass $(cat ${PASSFILE}) -destkeystore server-keystore.jks
 
  # If CSR was created using keytool, then following may be used
  echo "Import the combined cert (server+intermediate) into server keystore)"
  keytool -importcert -keystore server-keystore.jks -storepass $(cat ${PASSFILE}) -file server_int.pem -alias ${FQDN} -noprompt
 
  echo "Verify the keystore fingerprints"
  keytool -keystore  server-keystore.jks -storepass $(cat ${PASSFILE}) -list
fi
