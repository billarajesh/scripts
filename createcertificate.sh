Use Java keytool to generate Certificate Signing Request (CSR).
Below steps outline to create single CSR request for all servers in a cluster,
 using Subject Alternative Name or Multi-Domain (SAN)
 
# On CM Server
FQDN=$(hostname -f)
 
myEXT="EKU=serverAuth,clientAuth"
 
# Create a variable mySAN to hold all hostnames of the cluster. Note the last server is added separately
mySAN="SAN=$(for i in {01..10};do printf "dns:usaltapedf%s.aln.experian.com," $i;done) \
$(for i in {01..20};do printf "dns:cdh%s.com," $i;done) \
$(for i in {01..04};do printf "dns:hdp%s.com," $i;done)"
mySAN="${mySAN}dns:hdp05.com"
 
# Create server keystore
keytool -genkeypair -alias $FQDN  -keyalg RSA -keystore "server-keystore.jks" -keysize 2048 -dname \
 "CN=${FQDN},OU=DataFabric,O=Experian,L=McKinney,ST=Texas,C=US" -storepass $(cat /etc/jks.pass) \
 -keypass $(cat /etc/jks.pass) -validity 1000 -ext "$myEXT" -ext $mySAN
 
# Create Certificate Sign Request (CSR)
keytool -certreq -alias ${FQDN} -keystore "server-keystore.jks" -storepass $(cat /etc/jks.pass) -rfc -file "server.csr"
 
# Paste the contents of the server.csr in Private SSL request page and also enter all the hostnames
# Command to review all the hostnames in SAN
keytool -keystore server-keystore.jks -storepass $(cat /etc/jks.pass) -list -v
