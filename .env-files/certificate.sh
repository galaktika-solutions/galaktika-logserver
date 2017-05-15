#!/bin/bash
set -e

CN="lcoalhost"
SAN="DNS:localhost"
KEY="$CN.key"
CSR="$CN.csr"
CRT="$CN.crt"
CACRT="rootCA.crt"
CAKEY="rootCA.key"

# rootCA create
openssl genrsa -out $CAKEY 2048
openssl req -x509 -new -nodes -key $CAKEY -sha256 -days 1024 -out $CACRT

# certificate create
openssl genrsa -out $KEY 2048

openssl req -new -sha256 -subj "/commonName=$CN" \
         -key $KEY -reqexts SAN -out $CSR \
         -config <(cat /etc/ssl/openssl.cnf \
                   <(printf "[SAN]\nsubjectAltName=%s" "$SAN"))

openssl x509 -req -in $CSR -CA $CACRT -CAkey $CAKEY \
         -out $CRT -days 500 -sha256 -extensions SAN \
         -CAcreateserial -CAserial "$CACRT.srl" \
         -extfile <(cat /etc/ssl/openssl.cnf \
                    <(printf "[SAN]\nsubjectAltName=%s" "$SAN"))

rm "$CSR"
rm "$CAKEY"
