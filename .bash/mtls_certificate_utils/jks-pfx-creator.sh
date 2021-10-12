#!/bin/bash
FILE_NAME = $1
KEY_FILE_NAME = $2
PASSWORD = $3

openssl pkcs12                          \
        -export                         \
        -out ${FILE_NAME}.pfx           \
        -inkey ${KEY_FILE_NAME}.key     \
        -in ${FILE_NAME}.cer            \
        -password pass:${PASSWORD}      
keytool -importkeystore                 \
        -srckeystore ${FILE_NAME}.pfx   \
        -srcstoretype pkcs12            \
        -srcalias 1                     \
        -srcstorepass ${PASSWORD}       \
        -destkeystore ${FILE_NAME}.jks  \
        -deststoretype pkcs12           \
        -deststorepass ${PASSWORD}      \
        -destalias ssl        