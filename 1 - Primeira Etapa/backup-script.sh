#!/bin/bash

#Variaveis
server="localhost"   #Servidor postgres
login="postgres"     #login da base
pw="postgres"        #senha
nome_temp="all"      #nome do arquivo temporário 
bk="/temp/bkp"       #Diretório para salvar arquivos de backup
nw=$(date "+%Y%m%d") #Obtendo a data atual
nb=3                 #número de cópias do banco de dados
hs="backup_$nw"      #nome do arquivo compactado

fazerBK()
{
 echo "Iniciando BK do PostgresSQL"
 if [ -d "$bk/dbPolicia" ]; then
   continue
 else
   mkdir "$bk/dbPolicia"
 fi
 pg_dump dbPolicia -U $login -Fc -v -h $server > "$bk/dbPolicia/$hs.sql"
 a=0
 b=$(ls -t "$bk/dbPolicia")
 c=$nb
 for arq in $b; do
   a=$(($a+1))
   if [ "$a" -gt $c ];  then
     rm -f "$bk/dbPolicia/$arq"
   fi
 done
 echo "Backup da base PostgreSQL realizado com sucesso!"
}
backup()
{
 if [ -d $bk ]; then
   continue
 else
   mkdir $bk
 fi
 echo "Realizando backup do servidor postgres"
 export PGPASSWORD=$pw
 fazerBK
 
}

fazerBK postgres
