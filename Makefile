
SECRETS_DIR=./srcs/requirements/nginx/tools

DOMAIN_NAME=my_domain
CSR=$(SECRETS_DIR)/certificate_signing_request.csr	# Certificate Signing Request file, which contains info about the person/organization/server requesting the certificate and is used to generate the SSL certificate.
KEY=$(SECRETS_DIR)/private.key 						# private key file, which is used to establish secure connections and must be kept secret.
PEM=$(SECRETS_DIR)/self_signed_certificate.pem 		# self-signed certificate file in PEM format, which is used by the server to prove its identity to clients.
DHPARAM=$(SECRETS_DIR)/dhparam.pem 					# Diffie-Hellman parameter file, which is used to enable secure key exchange for SSL/TLS connections.

BITS=2048


# -- KEYS --
COUNTRY_KEY=/C
STATE_KEY=/ST
LOCALITY_KEY=/L
ORG_KEY=/O
ORG_UNIT_KEY=/OU
COMMON_NAME_KEY=/CN

# -- SUBJECT -- 
SUBJ = $(COUNTRY_KEY)=MY$(STATE_KEY)=Selangor$(LOCALITY_KEY)=SungaiBuloh$(ORG_KEY)=MyCompany$(ORG_UNIT_KEY)=IT$(COMMON_NAME_KEY)=mydomain.com

generate_ssl:
	@: # testing
	@if [ ! -f $(DHPARAM) ] || \
		[ ! -f $(PEM) ] || \
		[ ! -f $(KEY) ]; then \
		rm -f $(DHPARAM) $(PEM) $(KEY) $(CSR);\
		\
		\
		# Generate Diffie-Hellman parameters file with specified bit length using OpenSSL\
		openssl dhparam -out $(DHPARAM) $(BITS); \
		\
		\
		# -- openSSL req: Handles certificate requests and creation of private keys -- \
		# create an SSL/TLS certificate using RSA algorithm with the specified no. of bits \
		# nodes (no DES (Data Encryption Standard)) tells OpenSSL that this key can be accessed without a passphrase, so that automated services (E.g. web servers) can access the key without manual intervention.\
		openssl req \
			-new \
			-newkey rsa:$(BITS)	\
			-nodes \
			-keyout ${KEY} \
			-out ${CSR} \
			-subj "${SUBJ}"; \
		\
		\
		# -- openSSL x509: Manages X.509 certificates (the standard for SSL/TLS certificates) \
		# Generate a self-signed certificate from the CSR and private key \
		openssl x509 \
			-req \
			-days 3650 \
			-in ${CSR} \
			-signkey ${KEY} \
			-out ${PEM}; \
		chmod 600 ${KEY}; \
		chmod 644 ${PEM}; \
		chmod 644 ${DHPARAM}; \
	fi