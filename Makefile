# ----- COLORS ------
RESET   = \033[0m
BOLD    = \033[1m
RED     = \033[31m
GREEN   = \033[32m
YELLOW  = \033[33m
BLUE    = \033[34m
MAGENTA = \033[35m
CYAN    = \033[36m
WHITE   = \033[37m



BITS				= 2048
CERTS_DIR			= ./srcs/requirements/nginx/tools
DOCKER_COMPOSE_FILE = ./srcs/docker-compose.yml
DOMAIN_NAME			= shechong.42.fr
NAME 				= inception

HOME_DIR := $(shell echo $$HOME)
DATA_DIR = $(HOME_DIR)/data


# ----- CERTIFICATE ------
# All the below files use the .pem format
# A .pem file is a common format for SSL/TLS keys and certificates. 

# Certificate Signing Request file, which contains info about the person/organization/server requesting the certificate and 
# Is passed to a function to generate an SSL certificate.
CSR_PATH	 = $(CERTS_DIR)/certificate_signing_request.csr

# self-signed certificate file used by the server to prove its identity to clients.
CERT_PATH	 = $(CERTS_DIR)/self_signed_certificate.pem

# .key file is used by the server to secure connection
KEY_PATH	 = $(CERTS_DIR)/private.key

# Diffie-Hellman parameter file
# is used to enable secure key exchange for SSL/TLS connections.
DHPARAM_PATH = $(CERTS_DIR)/dhparam.pem


# ------ SUBJECT ------

COUNTRY_KEY		= /C
STATE_KEY		= /ST
LOCALITY_KEY	= /L
ORG_KEY			= /O
ORG_UNIT_KEY	= /OU
COMMON_NAME_KEY	= /CN


SUBJ = $(COUNTRY_KEY)=MY$(STATE_KEY)=Selangor$(LOCALITY_KEY)=SungaiBuloh$(ORG_KEY)=MyCompany$(ORG_UNIT_KEY)=IT$(COMMON_NAME_KEY)=$(DOMAIN_NAME)

all: $(NAME)

$(NAME): prepare_dir
	@docker compose \
		--file $(DOCKER_COMPOSE_FILE) \
		--project-name inception \
		up \
			--build \
			--detach
	@echo "$(GREEN)$(NAME) is runnng$(RESET)..."
	@echo "Visit $(GREEN)https://$(DOMAIN_NAME)$(RESET)"


prepare_dir: generate_certificates
	@mkdir --parents $(DATA_DIR)/mariadb
	@mkdir --parents $(DATA_DIR)/wordpress

generate_certificates:
	@if [ ! -f $(DHPARAM_PATH) ] || \
		[ ! -f $(CERT_PATH) ] || \
		[ ! -f $(KEY_PATH) ]; then \
		rm -f $(DHPARAM_PATH) $(CERT_PATH) $(KEY_PATH) $(CSR_PATH);\
		\
		\
		# Generate Diffie-Hellman parameters (DHPARAM) file using OpenSSL\
		# 		Use with specified bit length BITS\
		openssl dhparam -out $(DHPARAM_PATH) $(BITS); \
		\
		\
		# Create an SSL/TLS using "openSSL req" -- \
		# 		Uses RSA algorithm with the specified no. of bits \
		# 		nodes ("no DES" (Data Encryption Standard)) makes it such that this key can be accessed without a passphrase, \
		#		This is so that automated services (E.g. web servers) can access the key without manual intervention.\
		openssl req \
			-new \
			-newkey rsa:$(BITS)	\
			-nodes \
			-keyout	${KEY_PATH} \
			-out 	${CSR_PATH} \
			-subj	"${SUBJ}"; \
		\
		\
		# Generate self-signed cert using "openSSL x509" -- \
		# 		Inputs include the CSR_PATH and private key \
		openssl x509 \
			-req \
			-days 	 3650 \
			-in 	 ${CSR_PATH} \
			-signkey ${KEY_PATH} \
			-out 	 ${CERT_PATH}; \
		chmod u=rw,go= ${KEY_PATH}; \
		chmod u=rw,go=r ${CERT_PATH}; \
		chmod u=rw,go=r ${DHPARAM_PATH}; \
	fi

stop:
	docker compose --file $(DOCKER_COMPOSE_FILE) --project-name $(NAME) down


# deletes volumes
fclean: clean
	@# delete volumes
	@sudo rm -rf $(DATA_DIR)
	@echo "$(GREEN)mariadb and wordpress volumes have been succesfully deleted from $(DATA_DIR)$(RESET)"

# simply shuts down the containers, but data is retained
clean:
	@sudo docker compose --file $(DOCKER_COMPOSE_FILE) -v down
	@docker rm -f mariadb wordpress nginx

re: fclean all

.PHONY = generate_certificates re clean fclean 