#!/bin/bash
#	Versão 1.0
#Script para automatizar o upload de imagens para o zabbix

#	Variáveis
tamanhos=(24 48 64 96 128)
dir='/home/dpanegassi/Pictures/redimensionado'
dir_img_resize='/home/dpanegassi/Pictures/redimensionado/novos_arquivos'

#Redimenciona os aquivos de imgens
for imagem in $(ls -Inovos_arquivos $dir)
do
nome=$(echo $imagem | sed -r 's/\.(png|jpg|gif|jpeg)$//g')
extencao=$(echo $imagem | sed -r 's/(\w)+\.//gi')
  for size in ${tamanhos[@]};
  do
    convert -resize $size\x $dir/$nome.$extencao $dir_img_resize/$nome\_\($size\).$extencao
  done
done

# Upload das imagens para o Zabbix

for imagem in $(ls $dir_img_resize)
do
hash=$(cat $dir_img_resize/$imagem | base64 -w 0)
var=$(jq -n --arg a "$hash" --arg b "$imagem" '{
    "jsonrpc": "2.0",
    "method": "image.create",
    "params": {
        "imagetype": 1,
        "name": $b,
	"image": $a
    },
    "auth": "329b5f1dd6f561e7931a7d794ee52bb6",
    "id": 1
}')
echo $var > request.json
echo $hash
curl -H 'Content-Type: application/json-rpc' -d @request.json 10.0.0.125/api_jsonrpc.php
done