--Criando usuario:
CREATE ROLE usr_relatorio LOGIN PASSWORD '123'
--Removendo todas permissões na base:
REVOKE ALL PRIVILEGES ON DATABASE coveniencia FROM usr_relatorio
--Dando permissão para acessar apenas a view:
GRANT SELECT ON '4) ESTILO_CLIENTES_VENDAS' TO usr_relatorio
