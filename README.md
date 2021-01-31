# TESTE-SELETIVO-001-2020-PJC-MT
Teste prático para Administrador de Dados do processo seletivo 001/2020/PJC/MT
# Iniciar Projeto
##### - Baixar as Imagens

| Image     | Link para baixar |
| --------- | -----:|
| PgAdmin-Template  | https://drive.google.com/ |
| Postgres-Template     |   https://drive.google.com/ |

Salve as imagens em um diretorio de facil acesso.
##### - Importar Imagens no Docker
Com o docker instalado, abra o terminal como administrador e digite os comandos:

Para o Postgres
`docker load -i <Caminho da imagem baixada do Postgres>`

Para o PgAdmin
`docker load -i <Caminho da imagem baixada do PgAdmin>`
##### - Criar Rede
Criando a rede para o Postgres e o PgAdmin:
`docker network create --driver bridge postgres-network`
##### - Levantar Containers
Criar um container do Postgres na rede `postgres-network` e configurar um volume.

NOTA: Substituir `CAMINHO_VOLUME_HOSPEDEIRO` por um diretorio do pc hospedeiro do Docker.

`docker run --name postgres-server --network=postgres-network -e "POSTGRES_PASSWORD=postgres" -p 5432:5432 -v <CAMINHO_VOLUME_HOSPEDEIRO>:/var/lib/postgresql/data -d postgres-seletivo`

------------
Criar um container do PgAdmin:
NOTA: Substituir o email,senha e porta caso necessario.
`docker run --name pgadmin --network=postgres-network -p 15432:80 -e "PGADMIN_DEFAULT_EMAIL=ewertonlug@hotmail.com" -e "PGADMIN_DEFAULT_PASSWORD=pg@123" -d pgadmin4-seletivo`
##### - Configurar PgAdmin
Acessar: http://localhost:15432 
Clicar na aba *Dashboard* e depois *Add New server*
Na aba *General* colocar um *name*
Na aba *Connection* colocar:
-*Host name/address*: `postgres-server`.
-*Port*: `5432`
-*Username*: `postgres`
-*Passsword*: `postgres`
Clicar em Save
