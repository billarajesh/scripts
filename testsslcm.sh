echo |openssl s_client  -CAfile <(keytool -list -rfc -keystore /usr/java/security/jssecacerts -storepass changeit) -connect <cmhost>:7183
