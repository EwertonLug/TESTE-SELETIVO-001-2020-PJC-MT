--
-- PostgreSQL database dump
--

-- Dumped from database version 12.5 (Debian 12.5-1.pgdg100+1)
-- Dumped by pg_dump version 12.5

-- Started on 2021-01-31 17:34:55 UTC

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 232 (class 1255 OID 16767)
-- Name: venda_auditoria(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.venda_auditoria() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO VENDAS_AUDITORIA ( CODIGO, DATA_CRIACAO, VALOR_FRETE, VALOR_DESCONTO, VALOR_TOTAL, STATUS, OBSERVACAO, DATA_HORA_ENTREGA, CODIGO_CLIENTE, CODIGO_USUARIO, TIPO_EVENTO, DATA_EVENTO ) 
	VALUES ( NEW.CODIGO, NEW.DATA_CRIACAO, NEW.VALOR_FRETE, NEW.VALOR_DESCONTO, NEW.VALOR_TOTAL, NEW.STATUS, NEW.OBSERVACAO, NEW.DATA_HORA_ENTREGA, NEW.CODIGO_CLIENTE, NEW.CODIGO_USUARIO, TG_OP, current_timestamp);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.venda_auditoria() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 16746)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    codigo bigint NOT NULL,
    nome character varying(50),
    email character varying(50),
    senha character varying(120),
    ativo smallint,
    data_nascimento date
);


ALTER TABLE public.usuario OWNER TO postgres;
--Criando usuario:
CREATE ROLE usr_relatorio LOGIN PASSWORD '123';
--
-- TOC entry 209 (class 1259 OID 16451)
-- Name: venda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.venda (
    codigo bigint NOT NULL,
    data_criacao timestamp without time zone,
    valor_frete numeric(10,2),
    valor_desconto numeric(10,2),
    valor_total numeric(10,2),
    status character varying(30),
    observacao character varying(200),
    data_hora_entrega timestamp without time zone,
    codigo_cliente bigint,
    codigo_usuario bigint
);


ALTER TABLE public.venda OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 33150)
-- Name: 10) VENDAS POR USUARIO MENSAL; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."10) VENDAS POR USUARIO MENSAL" WITH (security_barrier='true') AS
 SELECT b.nome AS usuario,
    date_part('year'::text, a.data_hora_entrega) AS ano,
        CASE date_part('month'::text, a.data_hora_entrega)
            WHEN 1 THEN 'JANEIRO'::text
            WHEN 2 THEN 'FEVEREIRO'::text
            WHEN 3 THEN 'MARÇO'::text
            WHEN 4 THEN 'ABRIL'::text
            WHEN 5 THEN 'MAIO'::text
            WHEN 6 THEN 'JUNHO'::text
            WHEN 7 THEN 'JULHO'::text
            WHEN 8 THEN 'AGOSTO'::text
            WHEN 9 THEN 'SETEMBRO'::text
            WHEN 10 THEN 'OUTUBRO'::text
            WHEN 11 THEN 'NOVEMBRO'::text
            WHEN 12 THEN 'DEZEMBRO'::text
            ELSE NULL::text
        END AS mes,
    count(*) AS numero_vendas
   FROM (public.venda a
     JOIN public.usuario b ON ((b.codigo = a.codigo_usuario)))
  WHERE (((a.status)::text = 'EFE'::text) AND (date_part('year'::text, a.data_hora_entrega) = date_part('year'::text, CURRENT_DATE)))
  GROUP BY
        CASE date_part('month'::text, a.data_hora_entrega)
            WHEN 1 THEN 'JANEIRO'::text
            WHEN 2 THEN 'FEVEREIRO'::text
            WHEN 3 THEN 'MARÇO'::text
            WHEN 4 THEN 'ABRIL'::text
            WHEN 5 THEN 'MAIO'::text
            WHEN 6 THEN 'JUNHO'::text
            WHEN 7 THEN 'JULHO'::text
            WHEN 8 THEN 'AGOSTO'::text
            WHEN 9 THEN 'SETEMBRO'::text
            WHEN 10 THEN 'OUTUBRO'::text
            WHEN 11 THEN 'NOVEMBRO'::text
            WHEN 12 THEN 'DEZEMBRO'::text
            ELSE NULL::text
        END, (date_part('year'::text, a.data_hora_entrega)), b.nome
  ORDER BY b.nome;


ALTER TABLE public."10) VENDAS POR USUARIO MENSAL" OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 16460)
-- Name: cerveja; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cerveja (
    codigo bigint NOT NULL,
    sku character varying(50),
    nome character varying(50),
    descricao text,
    valor numeric(10,2),
    teor_alcoolico numeric(10,2),
    comissao numeric(10,2),
    sabor character varying(50),
    origem character varying(50),
    codigo_estilo bigint,
    quantidade_estoque integer,
    foto character varying(100),
    content_type character varying(100)
);


ALTER TABLE public.cerveja OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 16457)
-- Name: item_venda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item_venda (
    codigo bigint NOT NULL,
    quantidade integer,
    valor_unitario numeric(10,2),
    codigo_cerveja bigint,
    codigo_venda bigint
);


ALTER TABLE public.item_venda OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 33155)
-- Name: 11) COMISSAO GERAL USUARIO; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."11) COMISSAO GERAL USUARIO" WITH (security_barrier='true') AS
 SELECT sum((((a.valor_total * ( SELECT sum(b.comissao) AS sum
           FROM (public.cerveja b
             JOIN public.item_venda c ON ((b.codigo = c.codigo_cerveja)))
          WHERE (c.codigo_venda = a.codigo))) / (100)::numeric))::numeric(10,2)) AS total_comissao
   FROM public.venda a
  WHERE (a.codigo_usuario = 3);


ALTER TABLE public."11) COMISSAO GERAL USUARIO" OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 16448)
-- Name: cliente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cliente (
    codigo bigint NOT NULL,
    nome character varying(80),
    tipo_pessoa character varying(15),
    telefone character varying(50),
    email character varying(50),
    lagradouro character varying(50),
    numero character varying(15),
    complemento character varying(80),
    cep character varying(15),
    codigo_cidade bigint
);


ALTER TABLE public.cliente OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 16454)
-- Name: estilo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estilo (
    codigo bigint NOT NULL,
    nome character varying(50)
);


ALTER TABLE public.estilo OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 25006)
-- Name: 4) ESTILO_CLIENTES_VENDAS; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public."4) ESTILO_CLIENTES_VENDAS" AS
 SELECT d.nome AS cliente,
    f.nome AS estilo,
    c.nome AS cerveja
   FROM ((((public.venda a
     JOIN public.item_venda b ON ((b.codigo_venda = a.codigo)))
     JOIN public.cerveja c ON ((c.codigo = b.codigo_cerveja)))
     JOIN public.cliente d ON ((d.codigo = a.codigo_cliente)))
     JOIN public.estilo f ON ((f.codigo = c.codigo_estilo)))
  WHERE ((a.status)::text = 'EFE'::text)
  ORDER BY d.nome, f.nome
  WITH NO DATA;


ALTER TABLE public."4) ESTILO_CLIENTES_VENDAS" OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 24987)
-- Name: 9) CERVEJAS_VENDIDAS; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."9) CERVEJAS_VENDIDAS" WITH (security_barrier='true') AS
 SELECT a.codigo,
    a.nome AS cerveja,
    COALESCE(( SELECT sum(b.quantidade) AS sum
           FROM public.item_venda b
          WHERE (b.codigo_cerveja = a.codigo)), (0)::bigint) AS quantidade
   FROM public.cerveja a
  ORDER BY COALESCE(( SELECT sum(b.quantidade) AS sum
           FROM public.item_venda b
          WHERE (b.codigo_cerveja = a.codigo)), (0)::bigint) DESC;


ALTER TABLE public."9) CERVEJAS_VENDIDAS" OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 33160)
-- Name: COMISSAO POR VENDA USUARIO; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."COMISSAO POR VENDA USUARIO" AS
 SELECT a.codigo AS venda,
    (((a.valor_total * ( SELECT sum(b.comissao) AS sum
           FROM (public.cerveja b
             JOIN public.item_venda c ON ((b.codigo = c.codigo_cerveja)))
          WHERE (c.codigo_venda = a.codigo))) / (100)::numeric))::numeric(10,2) AS total_comissao
   FROM public.venda a
  WHERE (a.codigo_usuario = 3);


ALTER TABLE public."COMISSAO POR VENDA USUARIO" OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 24977)
-- Name: VENDAS_GERAL; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."VENDAS_GERAL" AS
 SELECT a.codigo,
    d.nome AS cliente,
    f.nome AS estilo,
    a.data_criacao,
    a.data_hora_entrega,
    c.nome AS cerveja,
    b.quantidade,
    b.valor_unitario,
    a.valor_total
   FROM ((((public.venda a
     JOIN public.item_venda b ON ((b.codigo_venda = a.codigo)))
     JOIN public.cerveja c ON ((c.codigo = b.codigo_cerveja)))
     JOIN public.cliente d ON ((d.codigo = a.codigo_cliente)))
     JOIN public.estilo f ON ((f.codigo = c.codigo_estilo)))
  WHERE ((a.status)::text = 'EFE'::text);


ALTER TABLE public."VENDAS_GERAL" OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16606)
-- Name: cerveja_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.cerveja ALTER COLUMN codigo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cerveja_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 16718)
-- Name: cidade; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cidade (
    codigo bigint NOT NULL,
    nome character varying(50),
    codigo_estado bigint
);


ALTER TABLE public.cidade OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16716)
-- Name: cidade_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.cidade ALTER COLUMN codigo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cidade_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 216 (class 1259 OID 16592)
-- Name: cliente_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.cliente ALTER COLUMN codigo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cliente_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 206 (class 1259 OID 16439)
-- Name: estado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estado (
    codigo bigint NOT NULL,
    nome character varying(50),
    sigla character varying(2)
);


ALTER TABLE public.estado OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 16522)
-- Name: estado_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.estado ALTER COLUMN codigo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.estado_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 218 (class 1259 OID 16613)
-- Name: estilo_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.estilo ALTER COLUMN codigo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.estilo_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 204 (class 1259 OID 16430)
-- Name: grupo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grupo (
    codigo bigint NOT NULL,
    nome character varying(50)
);


ALTER TABLE public.grupo OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16584)
-- Name: grupo_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.grupo ALTER COLUMN codigo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.grupo_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 203 (class 1259 OID 16427)
-- Name: grupo_permissao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grupo_permissao (
    codigo_grupo bigint,
    codigo_permissao bigint
);


ALTER TABLE public.grupo_permissao OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16641)
-- Name: item_venda_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.item_venda ALTER COLUMN codigo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.item_venda_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 202 (class 1259 OID 16424)
-- Name: permissao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissao (
    codigo bigint NOT NULL,
    nome character varying(50)
);


ALTER TABLE public.permissao OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16582)
-- Name: permissao_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.permissao ALTER COLUMN codigo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.permissao_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 207 (class 1259 OID 16445)
-- Name: schema_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_version (
);


ALTER TABLE public.schema_version OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16744)
-- Name: usuario_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.usuario ALTER COLUMN codigo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.usuario_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 205 (class 1259 OID 16433)
-- Name: usuario_grupo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario_grupo (
    codigo_grupo bigint,
    codigo_usuario bigint
);


ALTER TABLE public.usuario_grupo OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16623)
-- Name: venda_codigo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.venda ALTER COLUMN codigo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.venda_codigo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 225 (class 1259 OID 16761)
-- Name: vendas_auditoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vendas_auditoria (
    codigo bigint,
    data_criacao timestamp without time zone,
    valor_frete numeric(10,2),
    valor_desconto numeric(10,2),
    valor_total numeric(10,2),
    status character varying(30),
    observacao character varying(200),
    data_hora_entrega timestamp without time zone,
    codigo_cliente bigint,
    codigo_usuario bigint,
    tipo_evento character varying(10),
    data_evento timestamp without time zone
);


ALTER TABLE public.vendas_auditoria OWNER TO postgres;

--
-- TOC entry 3047 (class 0 OID 16460)
-- Dependencies: 212
-- Data for Name: cerveja; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cerveja (codigo, sku, nome, descricao, valor, teor_alcoolico, comissao, sabor, origem, codigo_estilo, quantidade_estoque, foto, content_type) OVERRIDING SYSTEM VALUE VALUES (1, '1515326', 'SUB ZERO 263ML', 'SUB ZERO 263ML', 2.50, 5.00, 5.00, 'CEVADA', 'MT', 1, 10, 'C:/S/I/1.JPG', NULL);
INSERT INTO public.cerveja (codigo, sku, nome, descricao, valor, teor_alcoolico, comissao, sabor, origem, codigo_estilo, quantidade_estoque, foto, content_type) OVERRIDING SYSTEM VALUE VALUES (2, '15513365', 'PETRA 263 ML', 'PETRA 263 ML', 3.00, 5.00, 5.00, 'PURO MALTE', 'SP', 5, 15, 'C:/S/I/2.JPG', NULL);
INSERT INTO public.cerveja (codigo, sku, nome, descricao, valor, teor_alcoolico, comissao, sabor, origem, codigo_estilo, quantidade_estoque, foto, content_type) OVERRIDING SYSTEM VALUE VALUES (3, '515156', 'SKOL 263 ML', 'SKOL 263 ML', 3.00, 5.00, 5.00, 'CEVADA', 'SP', 1, 25, 'C:/S/I/3.JPG', NULL);
INSERT INTO public.cerveja (codigo, sku, nome, descricao, valor, teor_alcoolico, comissao, sabor, origem, codigo_estilo, quantidade_estoque, foto, content_type) OVERRIDING SYSTEM VALUE VALUES (4, '15154856332', 'BURGUESA 263 ML', 'BURGUESA 263 ML', 1.75, 4.70, 3.00, 'CEVADA', 'MT', 1, NULL, 'C:/S/I/4.JPG', NULL);


--
-- TOC entry 3057 (class 0 OID 16718)
-- Dependencies: 222
-- Data for Name: cidade; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cidade (codigo, nome, codigo_estado) OVERRIDING SYSTEM VALUE VALUES (1, 'MIRASSOL D OESTE', 1);
INSERT INTO public.cidade (codigo, nome, codigo_estado) OVERRIDING SYSTEM VALUE VALUES (2, 'CACERES', 1);
INSERT INTO public.cidade (codigo, nome, codigo_estado) OVERRIDING SYSTEM VALUE VALUES (3, 'TALBATÉ', 2);
INSERT INTO public.cidade (codigo, nome, codigo_estado) OVERRIDING SYSTEM VALUE VALUES (4, 'MANAUS', 6);
INSERT INTO public.cidade (codigo, nome, codigo_estado) OVERRIDING SYSTEM VALUE VALUES (5, 'BRASÍLIA', 5);
INSERT INTO public.cidade (codigo, nome, codigo_estado) OVERRIDING SYSTEM VALUE VALUES (6, 'JARAGUÁ DO SUL', 4);


--
-- TOC entry 3043 (class 0 OID 16448)
-- Dependencies: 208
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cliente (codigo, nome, tipo_pessoa, telefone, email, lagradouro, numero, complemento, cep, codigo_cidade) OVERRIDING SYSTEM VALUE VALUES (3, 'Emily Marcela Monteiro', 'FISICA', '92992137393', 'emily@email', 'Praça 14 ', '574', 'Travessa Visconde', '69020528', 4);
INSERT INTO public.cliente (codigo, nome, tipo_pessoa, telefone, email, lagradouro, numero, complemento, cep, codigo_cidade) OVERRIDING SYSTEM VALUE VALUES (5, 'Manoel Lorenzo Benedito Ribeiro', 'FISICA', '47993506109', 'manoel@email', 'Vila Nova', '267', 'Servidão A.Weinfurte', '89259322', 6);
INSERT INTO public.cliente (codigo, nome, tipo_pessoa, telefone, email, lagradouro, numero, complemento, cep, codigo_cidade) OVERRIDING SYSTEM VALUE VALUES (4, 'Ramunda Mariana Almeida', 'FISICA', '6136037970', 'raimunda@email', 'Asa Sul', '685', 'Quadra S 402 Bloco L', '70236120', 5);


--
-- TOC entry 3041 (class 0 OID 16439)
-- Dependencies: 206
-- Data for Name: estado; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.estado (codigo, nome, sigla) OVERRIDING SYSTEM VALUE VALUES (1, 'MATO GROSSO', 'MT');
INSERT INTO public.estado (codigo, nome, sigla) OVERRIDING SYSTEM VALUE VALUES (2, 'SÃO PAULO', 'SP');
INSERT INTO public.estado (codigo, nome, sigla) OVERRIDING SYSTEM VALUE VALUES (3, 'RONDÔNIA', 'RO');
INSERT INTO public.estado (codigo, nome, sigla) OVERRIDING SYSTEM VALUE VALUES (4, 'SANTA CATARINA', 'SC');
INSERT INTO public.estado (codigo, nome, sigla) OVERRIDING SYSTEM VALUE VALUES (5, 'DISTRITO FEDERAL', 'DF');
INSERT INTO public.estado (codigo, nome, sigla) OVERRIDING SYSTEM VALUE VALUES (6, 'AMAZONIA', 'AM');


--
-- TOC entry 3045 (class 0 OID 16454)
-- Dependencies: 210
-- Data for Name: estilo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.estilo (codigo, nome) OVERRIDING SYSTEM VALUE VALUES (1, 'Pilsen');
INSERT INTO public.estilo (codigo, nome) OVERRIDING SYSTEM VALUE VALUES (2, 'Munich Helles');
INSERT INTO public.estilo (codigo, nome) OVERRIDING SYSTEM VALUE VALUES (3, 'Vienna Lager');
INSERT INTO public.estilo (codigo, nome) OVERRIDING SYSTEM VALUE VALUES (4, 'Altbier.');
INSERT INTO public.estilo (codigo, nome) OVERRIDING SYSTEM VALUE VALUES (5, 'Puro Malte');


--
-- TOC entry 3039 (class 0 OID 16430)
-- Dependencies: 204
-- Data for Name: grupo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.grupo (codigo, nome) OVERRIDING SYSTEM VALUE VALUES (1, 'VENDEDOR INTERNO');
INSERT INTO public.grupo (codigo, nome) OVERRIDING SYSTEM VALUE VALUES (2, 'GERENTE');
INSERT INTO public.grupo (codigo, nome) OVERRIDING SYSTEM VALUE VALUES (3, 'ADMINISTRADOR');


--
-- TOC entry 3038 (class 0 OID 16427)
-- Dependencies: 203
-- Data for Name: grupo_permissao; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.grupo_permissao (codigo_grupo, codigo_permissao) VALUES (1, 1);
INSERT INTO public.grupo_permissao (codigo_grupo, codigo_permissao) VALUES (1, 2);
INSERT INTO public.grupo_permissao (codigo_grupo, codigo_permissao) VALUES (2, 3);


--
-- TOC entry 3046 (class 0 OID 16457)
-- Dependencies: 211
-- Data for Name: item_venda; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.item_venda (codigo, quantidade, valor_unitario, codigo_cerveja, codigo_venda) OVERRIDING SYSTEM VALUE VALUES (1, 3, 3.00, 2, 2);
INSERT INTO public.item_venda (codigo, quantidade, valor_unitario, codigo_cerveja, codigo_venda) OVERRIDING SYSTEM VALUE VALUES (2, 10, 1.75, 4, 3);
INSERT INTO public.item_venda (codigo, quantidade, valor_unitario, codigo_cerveja, codigo_venda) OVERRIDING SYSTEM VALUE VALUES (3, 15, 2.50, 1, 4);
INSERT INTO public.item_venda (codigo, quantidade, valor_unitario, codigo_cerveja, codigo_venda) OVERRIDING SYSTEM VALUE VALUES (4, 10, 2.50, 1, 5);
INSERT INTO public.item_venda (codigo, quantidade, valor_unitario, codigo_cerveja, codigo_venda) OVERRIDING SYSTEM VALUE VALUES (5, 4, 2.50, 1, 6);
INSERT INTO public.item_venda (codigo, quantidade, valor_unitario, codigo_cerveja, codigo_venda) OVERRIDING SYSTEM VALUE VALUES (6, 12, 3.00, 2, 7);


--
-- TOC entry 3037 (class 0 OID 16424)
-- Dependencies: 202
-- Data for Name: permissao; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.permissao (codigo, nome) OVERRIDING SYSTEM VALUE VALUES (1, 'FAZER VENDA');
INSERT INTO public.permissao (codigo, nome) OVERRIDING SYSTEM VALUE VALUES (2, 'CANCELAR VENDA');
INSERT INTO public.permissao (codigo, nome) OVERRIDING SYSTEM VALUE VALUES (3, 'EDITAR PREÇO DO PRODUTO NA VENDA');


--
-- TOC entry 3042 (class 0 OID 16445)
-- Dependencies: 207
-- Data for Name: schema_version; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3059 (class 0 OID 16746)
-- Dependencies: 224
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usuario (codigo, nome, email, senha, ativo, data_nascimento) OVERRIDING SYSTEM VALUE VALUES (1, 'EWERTON', 'usermail1@hotmail.com', '123', 1, '1992-07-07');
INSERT INTO public.usuario (codigo, nome, email, senha, ativo, data_nascimento) OVERRIDING SYSTEM VALUE VALUES (2, 'PATRICIA', 'usermail2@hotmail.com', '123', 1, '1956-05-11');
INSERT INTO public.usuario (codigo, nome, email, senha, ativo, data_nascimento) OVERRIDING SYSTEM VALUE VALUES (3, 'POLIANE', 'usermail2@hotmail.com', '123', 1, '1994-05-07');
INSERT INTO public.usuario (codigo, nome, email, senha, ativo, data_nascimento) OVERRIDING SYSTEM VALUE VALUES (4, 'WANDERSON', 'wan@email.com', '123', 1, '1956-05-15');


--
-- TOC entry 3040 (class 0 OID 16433)
-- Dependencies: 205
-- Data for Name: usuario_grupo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usuario_grupo (codigo_grupo, codigo_usuario) VALUES (3, 1);
INSERT INTO public.usuario_grupo (codigo_grupo, codigo_usuario) VALUES (2, 2);
INSERT INTO public.usuario_grupo (codigo_grupo, codigo_usuario) VALUES (1, 3);
INSERT INTO public.usuario_grupo (codigo_grupo, codigo_usuario) VALUES (1, 4);


--
-- TOC entry 3044 (class 0 OID 16451)
-- Dependencies: 209
-- Data for Name: venda; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.venda (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario) OVERRIDING SYSTEM VALUE VALUES (2, '2021-01-17 12:36:00', 0.00, 0.00, 9.00, 'EFE', NULL, '2021-01-17 00:00:00', 4, 3);
INSERT INTO public.venda (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario) OVERRIDING SYSTEM VALUE VALUES (3, '2021-01-17 13:38:00', 0.00, 0.00, 17.50, 'EFE', NULL, '2021-01-18 00:00:00', 4, 3);
INSERT INTO public.venda (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario) OVERRIDING SYSTEM VALUE VALUES (4, '2021-01-18 12:36:00', 0.00, 0.00, 37.50, 'PEN', 'LEVAR PARA O CLIENTE 18H', NULL, 5, 3);
INSERT INTO public.venda (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario) OVERRIDING SYSTEM VALUE VALUES (5, '2021-01-18 16:02:00', 5.00, 5.00, 25.00, 'EFE', 'NENHUMA', '2021-01-19 08:00:00', 5, 2);
INSERT INTO public.venda (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario) OVERRIDING SYSTEM VALUE VALUES (6, '2021-02-18 16:02:00', 0.00, 0.00, 10.00, 'EFE', 'NADA', '2021-02-18 17:02:00', 3, 3);
INSERT INTO public.venda (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario) OVERRIDING SYSTEM VALUE VALUES (7, '2021-07-18 16:02:00', 0.00, 0.00, 36.00, 'EFE', NULL, '2021-07-18 16:02:00', 5, 4);


--
-- TOC entry 3060 (class 0 OID 16761)
-- Dependencies: 225
-- Data for Name: vendas_auditoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.vendas_auditoria (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario, tipo_evento, data_evento) VALUES (2, '2021-01-17 12:36:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.vendas_auditoria (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario, tipo_evento, data_evento) VALUES (3, '2021-01-17 13:38:00', 0.00, 0.00, 17.50, 'EFE', NULL, '2021-01-18 00:00:00', 4, 3, 'UPDATE', '2021-01-17 19:52:16.768835');
INSERT INTO public.vendas_auditoria (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario, tipo_evento, data_evento) VALUES (4, '2021-01-18 12:36:00', 0.00, 0.00, 37.50, 'PEN', 'LEVAR PARA O CLIENTE', NULL, 5, 3, 'UPDATE', '2021-01-17 19:55:32.823555');
INSERT INTO public.vendas_auditoria (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario, tipo_evento, data_evento) VALUES (4, '2021-01-18 12:36:00', 0.00, 0.00, 37.50, 'PEN', 'LEVAR PARA O CLIENTE 18H', NULL, 5, 3, 'UPDATE', '2021-01-17 20:01:13.050648');
INSERT INTO public.vendas_auditoria (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario, tipo_evento, data_evento) VALUES (5, '2021-01-18 16:02:00', 5.00, 5.00, 25.00, 'EFE', 'NADA ', '2021-01-19 08:00:00', 5, 3, 'INSERT', '2021-01-17 20:03:48.342614');
INSERT INTO public.vendas_auditoria (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario, tipo_evento, data_evento) VALUES (5, '2021-01-18 16:02:00', 5.00, 5.00, 25.00, 'EFE', 'NENHUMA', '2021-01-19 08:00:00', 5, 3, 'UPDATE', '2021-01-17 20:06:08.098701');
INSERT INTO public.vendas_auditoria (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario, tipo_evento, data_evento) VALUES (5, '2021-01-18 16:02:00', 5.00, 5.00, 25.00, 'EFE', 'NENHUMA', '2021-01-19 08:00:00', 5, 2, 'UPDATE', '2021-01-20 00:14:47.716238');
INSERT INTO public.vendas_auditoria (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario, tipo_evento, data_evento) VALUES (6, '2021-02-18 16:02:00', 0.00, 0.00, 10.00, 'EFE', 'NADA', '2021-08-18 17:02:00', 3, 3, 'INSERT', '2021-01-20 00:21:45.000002');
INSERT INTO public.vendas_auditoria (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario, tipo_evento, data_evento) VALUES (6, '2021-02-18 16:02:00', 0.00, 0.00, 10.00, 'EFE', 'NADA', '2021-02-18 17:02:00', 3, 3, 'UPDATE', '2021-01-20 00:22:59.042418');
INSERT INTO public.vendas_auditoria (codigo, data_criacao, valor_frete, valor_desconto, valor_total, status, observacao, data_hora_entrega, codigo_cliente, codigo_usuario, tipo_evento, data_evento) VALUES (7, '2021-07-18 16:02:00', 0.00, 0.00, 36.00, 'EFE', NULL, '2021-07-18 16:02:00', 5, 4, 'INSERT', '2021-01-20 00:34:52.489977');


--
-- TOC entry 3068 (class 0 OID 0)
-- Dependencies: 217
-- Name: cerveja_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cerveja_codigo_seq', 4, true);


--
-- TOC entry 3069 (class 0 OID 0)
-- Dependencies: 221
-- Name: cidade_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cidade_codigo_seq', 6, true);


--
-- TOC entry 3070 (class 0 OID 0)
-- Dependencies: 216
-- Name: cliente_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cliente_codigo_seq', 5, true);


--
-- TOC entry 3071 (class 0 OID 0)
-- Dependencies: 213
-- Name: estado_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.estado_codigo_seq', 6, true);


--
-- TOC entry 3072 (class 0 OID 0)
-- Dependencies: 218
-- Name: estilo_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.estilo_codigo_seq', 5, true);


--
-- TOC entry 3073 (class 0 OID 0)
-- Dependencies: 215
-- Name: grupo_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grupo_codigo_seq', 3, true);


--
-- TOC entry 3074 (class 0 OID 0)
-- Dependencies: 220
-- Name: item_venda_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.item_venda_codigo_seq', 6, true);


--
-- TOC entry 3075 (class 0 OID 0)
-- Dependencies: 214
-- Name: permissao_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.permissao_codigo_seq', 3, true);


--
-- TOC entry 3076 (class 0 OID 0)
-- Dependencies: 223
-- Name: usuario_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_codigo_seq', 4, true);


--
-- TOC entry 3077 (class 0 OID 0)
-- Dependencies: 219
-- Name: venda_codigo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.venda_codigo_seq', 7, true);


--
-- TOC entry 2888 (class 2606 OID 16612)
-- Name: cerveja pk_cerveja; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cerveja
    ADD CONSTRAINT pk_cerveja PRIMARY KEY (codigo);


--
-- TOC entry 2890 (class 2606 OID 16722)
-- Name: cidade pk_cidade; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cidade
    ADD CONSTRAINT pk_cidade PRIMARY KEY (codigo);


--
-- TOC entry 2880 (class 2606 OID 16598)
-- Name: cliente pk_cliente; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT pk_cliente PRIMARY KEY (codigo);


--
-- TOC entry 2876 (class 2606 OID 16471)
-- Name: grupo pk_codigo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupo
    ADD CONSTRAINT pk_codigo PRIMARY KEY (codigo) INCLUDE (codigo);


--
-- TOC entry 2878 (class 2606 OID 16508)
-- Name: estado pk_estado; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado
    ADD CONSTRAINT pk_estado PRIMARY KEY (codigo);


--
-- TOC entry 2884 (class 2606 OID 16605)
-- Name: estilo pk_estilo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estilo
    ADD CONSTRAINT pk_estilo PRIMARY KEY (codigo);


--
-- TOC entry 2886 (class 2606 OID 16647)
-- Name: item_venda pk_itemVenda; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_venda
    ADD CONSTRAINT "pk_itemVenda" PRIMARY KEY (codigo);


--
-- TOC entry 2874 (class 2606 OID 16464)
-- Name: permissao pk_permissao; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissao
    ADD CONSTRAINT pk_permissao PRIMARY KEY (codigo);


--
-- TOC entry 2892 (class 2606 OID 16750)
-- Name: usuario pk_usuario; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT pk_usuario PRIMARY KEY (codigo);


--
-- TOC entry 2882 (class 2606 OID 16629)
-- Name: venda pk_venda; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venda
    ADD CONSTRAINT pk_venda PRIMARY KEY (codigo);


--
-- TOC entry 2904 (class 2620 OID 24958)
-- Name: venda venda_auditoria; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER venda_auditoria AFTER INSERT OR DELETE OR UPDATE ON public.venda FOR EACH ROW EXECUTE FUNCTION public.venda_auditoria();


--
-- TOC entry 2900 (class 2606 OID 16648)
-- Name: item_venda fk_cerveja; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_venda
    ADD CONSTRAINT fk_cerveja FOREIGN KEY (codigo_cerveja) REFERENCES public.cerveja(codigo) NOT VALID;


--
-- TOC entry 2897 (class 2606 OID 16739)
-- Name: cliente fk_cidade; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT fk_cidade FOREIGN KEY (codigo_cidade) REFERENCES public.cidade(codigo) NOT VALID;


--
-- TOC entry 2898 (class 2606 OID 16631)
-- Name: venda fk_cliente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venda
    ADD CONSTRAINT fk_cliente FOREIGN KEY (codigo_cliente) REFERENCES public.cliente(codigo) NOT VALID;


--
-- TOC entry 2895 (class 2606 OID 16502)
-- Name: usuario_grupo fk_codigoGrupo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_grupo
    ADD CONSTRAINT "fk_codigoGrupo" FOREIGN KEY (codigo_grupo) REFERENCES public.grupo(codigo) NOT VALID;


--
-- TOC entry 2896 (class 2606 OID 16751)
-- Name: usuario_grupo fk_codigoUsuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_grupo
    ADD CONSTRAINT "fk_codigoUsuario" FOREIGN KEY (codigo_usuario) REFERENCES public.usuario(codigo) NOT VALID;


--
-- TOC entry 2894 (class 2606 OID 16472)
-- Name: grupo_permissao fk_codigo_grupo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupo_permissao
    ADD CONSTRAINT fk_codigo_grupo FOREIGN KEY (codigo_grupo) REFERENCES public.grupo(codigo) NOT VALID;


--
-- TOC entry 2893 (class 2606 OID 16465)
-- Name: grupo_permissao fk_codigo_permissao; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupo_permissao
    ADD CONSTRAINT fk_codigo_permissao FOREIGN KEY (codigo_permissao) REFERENCES public.permissao(codigo) NOT VALID;


--
-- TOC entry 2903 (class 2606 OID 16723)
-- Name: cidade fk_estado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cidade
    ADD CONSTRAINT fk_estado FOREIGN KEY (codigo_estado) REFERENCES public.estado(codigo);


--
-- TOC entry 2902 (class 2606 OID 16618)
-- Name: cerveja fk_estilo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cerveja
    ADD CONSTRAINT fk_estilo FOREIGN KEY (codigo_estilo) REFERENCES public.estilo(codigo) NOT VALID;


--
-- TOC entry 2899 (class 2606 OID 16756)
-- Name: venda fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venda
    ADD CONSTRAINT fk_usuario FOREIGN KEY (codigo_usuario) REFERENCES public.usuario(codigo) NOT VALID;


--
-- TOC entry 2901 (class 2606 OID 16653)
-- Name: item_venda fk_venda; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_venda
    ADD CONSTRAINT fk_venda FOREIGN KEY (codigo_venda) REFERENCES public.venda(codigo) NOT VALID;


--
-- TOC entry 3067 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE "4) ESTILO_CLIENTES_VENDAS"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public."4) ESTILO_CLIENTES_VENDAS" TO usr_relatorio;


--
-- TOC entry 3061 (class 0 OID 25006)
-- Dependencies: 228 3063
-- Name: 4) ESTILO_CLIENTES_VENDAS; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public."4) ESTILO_CLIENTES_VENDAS";


-- Completed on 2021-01-31 17:34:56 UTC

--
-- PostgreSQL database dump complete
--

