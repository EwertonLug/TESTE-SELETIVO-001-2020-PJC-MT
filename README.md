# TESTE-SELETIVO-001-2020-PJC-MT
Teste prático para Administrador de Dados do processo seletivo 001/2020/PJC/MT


# Sumário

1 - Iniciar Projeto - Mostra como configurar o projeto

2 - Etapas - Mostra a resolução do teste.


# 1 - Iniciar Projeto
## - Baixar as Imagens

| Image     | Link para baixar |
| --------- | -----:|
| PgAdmin-Template  | [Google Drive](https://drive.google.com/drive/folders/1-d8afIDvjm5_soSfJLEAsNaQd8Y2krAV?usp=sharing "Google Drive") |
| Postgres-Template     |   [Google Drive](https://drive.google.com/drive/folders/1-d8afIDvjm5_soSfJLEAsNaQd8Y2krAV?usp=sharing "Google Drive") |

Salve as imagens em um diretorio de facil acesso.
## - Importar Imagens no Docker
Com o docker instalado, abra o terminal como administrador e digite os comandos:

Para o Postgres
`docker load -i <Caminho da imagem baixada do Postgres>`

Para o PgAdmin
`docker load -i <Caminho da imagem baixada do PgAdmin>`
## - Criar Rede
Criando a rede para o Postgres e o PgAdmin:
`docker network create --driver bridge postgres-network`
## - Levantar Containers
Criar um container do Postgres na rede `postgres-network` e configurar um volume.

NOTA: Substituir `CAMINHO_VOLUME_HOSPEDEIRO` por um diretorio do pc hospedeiro do Docker.

`docker run --name postgres-server --network=postgres-network -e "POSTGRES_PASSWORD=postgres" -p 5432:5432 -v <CAMINHO_VOLUME_HOSPEDEIRO>:/var/lib/postgresql/data -d postgres-seletivo`

------------
Criar um container do PgAdmin:

NOTA: Substituir o email,senha e porta caso necessario.

`docker run --name pgadmin --network=postgres-network -p 15432:80 -e "PGADMIN_DEFAULT_EMAIL=ewertonlug@hotmail.com" -e "PGADMIN_DEFAULT_PASSWORD=pg@123" -d pgadmin4-seletivo`
## - Configurar PgAdmin
Acessar: http://localhost:15432 

Clicar na aba *Dashboard* e depois *Add New server*

Na aba *General* colocar um *name*

Na aba *Connection* colocar:

-*Host name/address*: `postgres-server`.

-*Port*: `5432`

-*Username*: `postgres`

-*Passsword*: `postgres`

Clicar em Save
# 2 - Etapas

## Primeira Etapa
- Levantados os containers do PostreSql e PgAdmin.

`docker container ls`

- Acessanco OS do container postgres-server

`docker exec -it postgres-server /bin/bash`

- Configurado pg_hba.conf para permitir acesso externo:

`host	all		        all		        0.0.0.0/0		        md5`

- Criado banco de dados dbPolicia

- Criado script para fazer backup do bando de dados utilizando o editor nano.

Acessar pasta backup:

`cd /temp/bkp/dbPolicia`

Acessar script

` nano  /seletivo/backup-script.sh`

- Instalado Cron e  para executar o script todo dia as 2h da manha.

Iniciar cron

`service cron start`

Acessar Cron Jobs

`nano /etc/crontab`

Job

`* 2 * * * root /bin/bash /seletivo/backup-script.sh > /seletivo/log.txt`

##  Segunda Etapa

TESTE-SELETIVO-001-2020-PJC-MT/2 - Segunda Etapa/[Acessar Scripts](https://github.com/EwertonLug/TESTE-SELETIVO-001-2020-PJC-MT/tree/main/2%20-%20Segunda%20Etapa)
 
##  Terceira Etapa

TESTE-SELETIVO-001-2020-PJC-MT/3 - Terceira Etapa/[Acessar Proposta](https://github.com/EwertonLug/TESTE-SELETIVO-001-2020-PJC-MT/blob/main/3%20-%20Terceira%20Etapa/3%20ETAPA.pdf)


