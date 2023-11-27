#!/bin/bash

PARAMETERS=("$@")

create_client_config_file(){
    echo "
    [ req ]
    default_bits = 2048
    prompt = no
    default_md = sha256
    distinguished_name = dn
    
    [ dn ]
    C=PL
    ST=Mazowieckie
    L=Warszawa
    O=<organistaion_name>
    OU=<organistaion_unit>
    CN=${PARAMETERS[1]}" >> configPattern
}

create_server_config_file(){
    echo "
    [ req ]
    default_bits = 2048
    prompt = no
    default_md = sha256
    req_extensions = req_ext
    distinguished_name = dn
    
    [ dn ]
    C=PL
    ST=Mazowieckie
    L=Warszawa
    O=<organistaion_name>
    OU=<organistaion_unit>
    CN=${PARAMETERS[1]}
    
    [ req_ext ]
    subjectAltName = @alt_names
    
    [ alt_names ]
    $(alt_names_agregator)" >> configPattern
}

generate_csr_certificate(){
    openssl req -new -sha256 -nodes -out ${PARAMETERS[2]}.csr -newkey rsa:2048 -keyout ${PARAMETERS[2]}.key -config configPattern
}

alt_names_agregator(){
    COUNTER = 3
    while [ $COUNTER -lt ${#PARAMETERS[@]} ]; do
        ((INDEX = $COUNTER - 2))
        printf "DNS.$INDEX = ${PARAMETERS[$COUNTER]}\n"
        ((COUNTER = COUNTER + 1))
    done
}

display_manual(){
    echo "Example of usage below."
    printf 
    "Type: ./`basename "$0"` [-s] [-c] [namespace] [target_environment] [list_of_alternative_DNS]
    Where:
    -s generating server config file
    -c generating clinet config file"
}

case $1 in 
    -h)
        display_manual
        exit
        ;;
    --help)
        display_manual
        exit
        ;;
    -s)
        create_server_config_file
        printf "=================\nServer Certificate Configuration\n=================\n"
        printf "$(<configPattern)"
        printf "=================\nCSR Key Result\n=================\n"
        generate_csr_certificate
        rm configPattern
        ;;
    -c) 
        create_client_config_file
        printf "=================\nClient Certificate Configuration\n=================\n"
        printf "$(<configPattern)"
        printf "=================\nCSR Key Result\n=================\n"
        generate_csr_certificate
        rm configPattern
        ;;
    *) 
        printf "Illegal option. Please use -h or --help for more information"
        exit 1
        ;;
esac

