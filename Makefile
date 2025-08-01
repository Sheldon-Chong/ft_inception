BITS				= 2048
CERTS_DIR			= ./srcs/requirements/nginx/tools
DOMAIN_NAME			= my_domain
DOCKER_COMPOSE_PATH = docker-compose.yml
NAME 				= Inception

HOME_DIR := $(shell echo $$HOME)
DATA_DIR = $(HOME_DIR)/data

# ----- .pem (Privacy Enhanced Mail) format ------
# A .pem file is a common format for cryptographic keys and certificates.
# mostly used for SSL/TLS certificates and keys, in web servers, mail servers, VPNs, etc.
# All the below files use the .pem format

# Certificate Signing Request file, which contains info about the person/organization/server requesting the certificate and is used to generate the SSL certificate.
CSR_PATH		=$(CERTS_DIR)/certificate_signing_request.csr

# .key file is used by the server to secure connection
KEY_PATH		=$(CERTS_DIR)/private.key

# self-signed certificate file used by the server to prove its identity to clients.
PEM_PATH		=$(CERTS_DIR)/self_signed_certificate.pem

# Diffie-Hellman parameter file, which is used to enable secure key exchange for SSL/TLS connections.
DHPARAM_PATH	=$(CERTS_DIR)/dhparam.pem


# ------ SUBJECT ------

COUNTRY_KEY		= /C
STATE_KEY		= /ST
LOCALITY_KEY	= /L
ORG_KEY			= /O
ORG_UNIT_KEY	= /OU
COMMON_NAME_KEY	= /CN


SUBJ = $(COUNTRY_KEY)=MY$(STATE_KEY)=Selangor$(LOCALITY_KEY)=SungaiBuloh$(ORG_KEY)=MyCompany$(ORG_UNIT_KEY)=IT$(COMMON_NAME_KEY)=$(DOMAIN_NAME)

all: $(NAME)

$(NAME): generate_certificates
	@docker compose \
		--file srcs/$(DOCKER_COMPOSE_PATH) \
		--project-name inception \
		up \
			--build \
			--detach

generate_certificates:
	@if [ ! -f $(DHPARAM_PATH) ] || \
		[ ! -f $(PEM_PATH) ] || \
		[ ! -f $(KEY_PATH) ]; then \
		rm -f $(DHPARAM_PATH) $(PEM_PATH) $(KEY_PATH) $(CSR_PATH);\
		\
		\
		# Generate Diffie-Hellman parameters (DHPARAM) file using OpenSSL\
		# 		Use with specified bit length BITS\
		openssl dhparam -out $(DHPARAM_PATH) $(BITS); \
		\
		\
		# Create an SSL/TLS using "openSSL req" -- \
		# 		Handles certificate requests and creation of private keys -- \
		# 		create an SSL/TLS certificate using RSA algorithm with the specified no. of bits \
		# 		nodes ("no DES" (Data Encryption Standard)) tells OpenSSL that this key can be accessed without a passphrase, so that automated services (E.g. web servers) can access the key without manual intervention.\
		openssl req \
			-new \
			-newkey rsa:$(BITS)	\
			-nodes \
			-keyout ${KEY_PATH} \
			-out ${CSR_PATH} \
			-subj "${SUBJ}"; \
		\
		\
		# Generate self-signed cert using "openSSL x509" -- \
		# 		Manages X.509 certificates (the standard for SSL/TLS certificates) \
		# 		Generate a self-signed certificate from the CSR_PATH and private key \
		openssl x509 \
			-req \
			-days 3650 \
			-in ${CSR_PATH} \
			-signkey ${KEY_PATH} \
			-out ${PEM_PATH}; \
		chmod u=rw,go= ${KEY_PATH}; \
		chmod u=rw,go=r ${PEM_PATH}; \
		chmod u=rw,go=r ${DHPARAM_PATH}; \
	fi

re: fclean all

fclean: clean
    @rm -rf $(DATA_DIR)/mariadb
    @rm -rf $(DATA_DIR)/wordpress

clean:
	@sudo docker compose -f srcs/$(DOCKER_COMPOSE_FILE) -v down

.PHONY = generate_certificates re clean fclean 