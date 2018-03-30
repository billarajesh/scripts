#!/bin/bash
 
# 2017-11-29 Naveen B Import the Entrust certificate into Java keystore. Note the same keystore was used to generate CSR
# 2018-02-13 Naveen B DF Eval redo
 
# Notes
# A PEM-encoded certificate may also have file extension of .CRT or .CER
 
[[ -f ~/.bash_profile ]] && source ~/.bash_profile
 
DATEFMT=$(date +"%y%m%d%H%M")
SCRIPTNAME=$(basename $0)
NAME=$(echo ${SCRIPTNAME}|sed -e 's/.ksh$|.sh$//')
LOGF=${DATEFMT}.${NAME}.log
USAGE="${SCRIPTNAME} -d {Dir containing the certs,jks etc} -p {passphrase file}"
 
while getopts  d:p:  OPT
do
   case $OPT in
      d) DIR=$OPTARG ;;
      p) PASSFILE=$OPTARG ;;
      *) echo $USAGE; exit 1 ;;
   esac
done
 
if [[ ! -f server-keystore.jks || ! -f config.ini || ! -f jssecacerts || ! -f server.crt || ! -f server.key ]];then
   echo "One of the files is missing jssecacerts server.crt server.key"
   echo "$USAGE"
   exit 8
fi
 
if [[ -z ${DIR} || ! -f ${PASSFILE} ]];then
   echo "$USAGE"
   exit 8
   cd ${DIR}
fi
echo "$DIR"
 
if [[ -z ${JAVA_HOME} ]];then
   echo "\$JAVA_HOME is not defined"
fi
export PATH=${JAVA_HOME}/bin:$PATH
 
if [[ ! -d /usr/java/security/x509 ]];then
   mkdir -p /usr/java/security/x509
 
fi
 
cp -p  jssecacerts /usr/java/security/jssecacerts
cp -p local_policy.jar /usr/java/security/local_policy.jar
cp -p US_export_policy.jar /usr/java/security/US_export_policy.jar
cp -p  jks.pass  /etc/jks.pass
cp -p  config.ini  /etc/cloudera-scm-agent/config.ini
cp -p  server.key /usr/java/security/x509/
cp -p  server.crt /usr/java/security/x509/
cp -p  Root.pem         /usr/java/security/x509/
cp -p  Intermediate.pem /usr/java/security/x509/
cp -p  server-keystore.jks /usr/java/security/server-keystore.jks
 
ln -s /usr/java/security/local_policy.jar /usr/java/latest/jre/lib/security/local_policy.jar
ln -s /usr/java/security/US_export_policy.jar /usr/java/latest/jre/lib/security/US_export_policy.jar
ln -s /usr/java/security/jssecacerts /usr/java/latest/jre/lib/security/jssecacerts
 
chown -R cloudera-scm:cloudera-scm /etc/jks.pass /etc/cloudera-scm-agent/config.ini /usr/java/security
chmod 440 /etc/jks.pass
ls -lR /etc/jks.pass /etc/cloudera-scm-agent/config.ini /usr/java/security/
ls -l /usr/java/latest/jre/lib/security/*.jar /usr/java/latest/jre/lib/security/jssecacerts
