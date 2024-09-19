--
-- PostgreSQL database dump
--

-- Dumped from database version 14.12 (Ubuntu 14.12-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.12 (Ubuntu 14.12-0ubuntu0.22.04.1)

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
-- Name: alterar_status_entrega(integer, character varying); Type: PROCEDURE; Schema: public; Owner: zee
--

CREATE PROCEDURE public.alterar_status_entrega(IN p_id_entrega integer, IN p_novo_status character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE entrega
    SET status_entrega = p_novo_status
    WHERE id_entrega = p_id_entrega;
END;
$$;


ALTER PROCEDURE public.alterar_status_entrega(IN p_id_entrega integer, IN p_novo_status character varying) OWNER TO zee;

--
-- Name: atualizar_estoque_compras(integer); Type: PROCEDURE; Schema: public; Owner: zee
--

CREATE PROCEDURE public.atualizar_estoque_compras(IN p_id_pedido integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE produtos p
    SET estoque = estoque - i.quantidade
    FROM itens_pedido i
    WHERE i.id_pedido = p_id_pedido AND p.id_produto = i.id_produto;
END;
$$;


ALTER PROCEDURE public.atualizar_estoque_compras(IN p_id_pedido integer) OWNER TO zee;

--
-- Name: atualizar_estoque_trigger(); Type: FUNCTION; Schema: public; Owner: zee
--

CREATE FUNCTION public.atualizar_estoque_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE produtos
    SET estoque = estoque - NEW.quantidade
    WHERE id_produto = NEW.id_produto;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.atualizar_estoque_trigger() OWNER TO zee;

--
-- Name: atualizar_status_pedido_trigger(); Type: FUNCTION; Schema: public; Owner: zee
--

CREATE FUNCTION public.atualizar_status_pedido_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE pedidos
    SET status = 'Concluído'
    WHERE id_pedido = NEW.id_pedido;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.atualizar_status_pedido_trigger() OWNER TO zee;

--
-- Name: obter_estoque_produto(integer); Type: FUNCTION; Schema: public; Owner: zee
--

CREATE FUNCTION public.obter_estoque_produto(p_id_produto integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_estoque INT;
BEGIN
    SELECT estoque
    INTO v_estoque
    FROM produtos
    WHERE id_produto = p_id_produto;

    RETURN v_estoque;
END;
$$;


ALTER FUNCTION public.obter_estoque_produto(p_id_produto integer) OWNER TO zee;

--
-- Name: verificar_login_cliente(); Type: FUNCTION; Schema: public; Owner: zee
--

CREATE FUNCTION public.verificar_login_cliente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id_cliente = NEW.id_cliente) THEN
        RAISE EXCEPTION 'O cliente não possui um login associado!';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.verificar_login_cliente() OWNER TO zee;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categorias; Type: TABLE; Schema: public; Owner: zee
--

CREATE TABLE public.categorias (
    id_categoria integer NOT NULL,
    nome_categoria character varying(50) NOT NULL
);


ALTER TABLE public.categorias OWNER TO zee;

--
-- Name: categorias_id_categoria_seq; Type: SEQUENCE; Schema: public; Owner: zee
--

CREATE SEQUENCE public.categorias_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categorias_id_categoria_seq OWNER TO zee;

--
-- Name: categorias_id_categoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zee
--

ALTER SEQUENCE public.categorias_id_categoria_seq OWNED BY public.categorias.id_categoria;


--
-- Name: clientes; Type: TABLE; Schema: public; Owner: zee
--

CREATE TABLE public.clientes (
    id_cliente integer NOT NULL,
    nome character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    telefone character varying(20),
    endereco text
);


ALTER TABLE public.clientes OWNER TO zee;

--
-- Name: clientes_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: zee
--

CREATE SEQUENCE public.clientes_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clientes_id_cliente_seq OWNER TO zee;

--
-- Name: clientes_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zee
--

ALTER SEQUENCE public.clientes_id_cliente_seq OWNED BY public.clientes.id_cliente;


--
-- Name: entrega; Type: TABLE; Schema: public; Owner: zee
--

CREATE TABLE public.entrega (
    id_entrega integer NOT NULL,
    data_entrega timestamp without time zone,
    status_entrega character varying(50),
    id_envio integer
);


ALTER TABLE public.entrega OWNER TO zee;

--
-- Name: entrega_id_entrega_seq; Type: SEQUENCE; Schema: public; Owner: zee
--

CREATE SEQUENCE public.entrega_id_entrega_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.entrega_id_entrega_seq OWNER TO zee;

--
-- Name: entrega_id_entrega_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zee
--

ALTER SEQUENCE public.entrega_id_entrega_seq OWNED BY public.entrega.id_entrega;


--
-- Name: envio; Type: TABLE; Schema: public; Owner: zee
--

CREATE TABLE public.envio (
    id_envio integer NOT NULL,
    data_envio timestamp without time zone DEFAULT now(),
    metodo_envio character varying(50),
    id_pedido integer
);


ALTER TABLE public.envio OWNER TO zee;

--
-- Name: envio_id_envio_seq; Type: SEQUENCE; Schema: public; Owner: zee
--

CREATE SEQUENCE public.envio_id_envio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.envio_id_envio_seq OWNER TO zee;

--
-- Name: envio_id_envio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zee
--

ALTER SEQUENCE public.envio_id_envio_seq OWNED BY public.envio.id_envio;


--
-- Name: produtos; Type: TABLE; Schema: public; Owner: zee
--

CREATE TABLE public.produtos (
    id_produto integer NOT NULL,
    nome_produto character varying(100) NOT NULL,
    preco numeric(10,2) NOT NULL,
    estoque integer NOT NULL,
    id_categoria integer
);


ALTER TABLE public.produtos OWNER TO zee;

--
-- Name: estoque_produtos; Type: VIEW; Schema: public; Owner: zee
--

CREATE VIEW public.estoque_produtos AS
 SELECT p.nome_produto,
    p.estoque,
    c.nome_categoria
   FROM (public.produtos p
     JOIN public.categorias c ON ((p.id_categoria = c.id_categoria)));


ALTER TABLE public.estoque_produtos OWNER TO zee;

--
-- Name: itens_pedido; Type: TABLE; Schema: public; Owner: zee
--

CREATE TABLE public.itens_pedido (
    id_item integer NOT NULL,
    quantidade integer NOT NULL,
    preco_unitario numeric(10,2) NOT NULL,
    id_pedido integer,
    id_produto integer
);


ALTER TABLE public.itens_pedido OWNER TO zee;

--
-- Name: itens_pedido_id_item_seq; Type: SEQUENCE; Schema: public; Owner: zee
--

CREATE SEQUENCE public.itens_pedido_id_item_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.itens_pedido_id_item_seq OWNER TO zee;

--
-- Name: itens_pedido_id_item_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zee
--

ALTER SEQUENCE public.itens_pedido_id_item_seq OWNED BY public.itens_pedido.id_item;


--
-- Name: pagamentos; Type: TABLE; Schema: public; Owner: zee
--

CREATE TABLE public.pagamentos (
    id_pagamento integer NOT NULL,
    valor_pago numeric(10,2) NOT NULL,
    data_pagamento timestamp without time zone DEFAULT now(),
    metodo_pagamento character varying(50),
    id_pedido integer
);


ALTER TABLE public.pagamentos OWNER TO zee;

--
-- Name: pagamentos_id_pagamento_seq; Type: SEQUENCE; Schema: public; Owner: zee
--

CREATE SEQUENCE public.pagamentos_id_pagamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pagamentos_id_pagamento_seq OWNER TO zee;

--
-- Name: pagamentos_id_pagamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zee
--

ALTER SEQUENCE public.pagamentos_id_pagamento_seq OWNED BY public.pagamentos.id_pagamento;


--
-- Name: pedidos; Type: TABLE; Schema: public; Owner: zee
--

CREATE TABLE public.pedidos (
    id_pedido integer NOT NULL,
    data_pedido timestamp without time zone DEFAULT now(),
    status character varying(20) NOT NULL,
    id_cliente integer
);


ALTER TABLE public.pedidos OWNER TO zee;

--
-- Name: pedidos_id_pedido_seq; Type: SEQUENCE; Schema: public; Owner: zee
--

CREATE SEQUENCE public.pedidos_id_pedido_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pedidos_id_pedido_seq OWNER TO zee;

--
-- Name: pedidos_id_pedido_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zee
--

ALTER SEQUENCE public.pedidos_id_pedido_seq OWNED BY public.pedidos.id_pedido;


--
-- Name: produtos_id_produto_seq; Type: SEQUENCE; Schema: public; Owner: zee
--

CREATE SEQUENCE public.produtos_id_produto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.produtos_id_produto_seq OWNER TO zee;

--
-- Name: produtos_id_produto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zee
--

ALTER SEQUENCE public.produtos_id_produto_seq OWNED BY public.produtos.id_produto;


--
-- Name: relatorio_pedidos; Type: VIEW; Schema: public; Owner: zee
--

CREATE VIEW public.relatorio_pedidos AS
 SELECT p.id_pedido,
    c.nome,
    p.data_pedido,
    p.status,
    prod.nome_produto,
    i.quantidade,
    i.preco_unitario,
    pag.valor_pago
   FROM ((((public.pedidos p
     JOIN public.clientes c ON ((p.id_cliente = c.id_cliente)))
     JOIN public.itens_pedido i ON ((p.id_pedido = i.id_pedido)))
     JOIN public.produtos prod ON ((i.id_produto = prod.id_produto)))
     JOIN public.pagamentos pag ON ((p.id_pedido = pag.id_pedido)));


ALTER TABLE public.relatorio_pedidos OWNER TO zee;

--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: zee
--

CREATE TABLE public.usuarios (
    id_usuario integer NOT NULL,
    username character varying(50) NOT NULL,
    senha character varying(100) NOT NULL,
    id_cliente integer
);


ALTER TABLE public.usuarios OWNER TO zee;

--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: zee
--

CREATE SEQUENCE public.usuarios_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usuarios_id_usuario_seq OWNER TO zee;

--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: zee
--

ALTER SEQUENCE public.usuarios_id_usuario_seq OWNED BY public.usuarios.id_usuario;


--
-- Name: categorias id_categoria; Type: DEFAULT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.categorias ALTER COLUMN id_categoria SET DEFAULT nextval('public.categorias_id_categoria_seq'::regclass);


--
-- Name: clientes id_cliente; Type: DEFAULT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id_cliente SET DEFAULT nextval('public.clientes_id_cliente_seq'::regclass);


--
-- Name: entrega id_entrega; Type: DEFAULT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.entrega ALTER COLUMN id_entrega SET DEFAULT nextval('public.entrega_id_entrega_seq'::regclass);


--
-- Name: envio id_envio; Type: DEFAULT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.envio ALTER COLUMN id_envio SET DEFAULT nextval('public.envio_id_envio_seq'::regclass);


--
-- Name: itens_pedido id_item; Type: DEFAULT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.itens_pedido ALTER COLUMN id_item SET DEFAULT nextval('public.itens_pedido_id_item_seq'::regclass);


--
-- Name: pagamentos id_pagamento; Type: DEFAULT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.pagamentos ALTER COLUMN id_pagamento SET DEFAULT nextval('public.pagamentos_id_pagamento_seq'::regclass);


--
-- Name: pedidos id_pedido; Type: DEFAULT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.pedidos ALTER COLUMN id_pedido SET DEFAULT nextval('public.pedidos_id_pedido_seq'::regclass);


--
-- Name: produtos id_produto; Type: DEFAULT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.produtos ALTER COLUMN id_produto SET DEFAULT nextval('public.produtos_id_produto_seq'::regclass);


--
-- Name: usuarios id_usuario; Type: DEFAULT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuarios_id_usuario_seq'::regclass);


--
-- Data for Name: categorias; Type: TABLE DATA; Schema: public; Owner: zee
--

COPY public.categorias (id_categoria, nome_categoria) FROM stdin;
1	Eletrônicos
2	Livros
3	Vestuário
4	Brinquedos
5	Móveis
\.


--
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: zee
--

COPY public.clientes (id_cliente, nome, email, telefone, endereco) FROM stdin;
1	João da Silva	joao.silva@example.com	(11) 91234-5678	Rua das Flores, 123, São Paulo, SP
2	Maria Oliveira	maria.oliveira@example.com	(21) 99876-5432	Av. Brasil, 456, Rio de Janeiro, RJ
3	Carlos Souza	carlos.souza@example.com	(31) 91234-9876	Rua Ouro Preto, 789, Belo Horizonte, MG
4	Fernanda Almeida	fernanda.almeida@example.com	(85) 92345-6789	Rua das Palmeiras, 987, Fortaleza, CE
\.


--
-- Data for Name: entrega; Type: TABLE DATA; Schema: public; Owner: zee
--

COPY public.entrega (id_entrega, data_entrega, status_entrega, id_envio) FROM stdin;
1	2024-09-15 14:00:00	Entregue	1
2	2024-09-14 10:00:00	Entregue	2
3	2024-09-16 16:00:00	Em Trânsito	3
4	\N	Aguardando Entrega	4
\.


--
-- Data for Name: envio; Type: TABLE DATA; Schema: public; Owner: zee
--

COPY public.envio (id_envio, data_envio, metodo_envio, id_pedido) FROM stdin;
1	2024-09-19 11:02:32.096528	Correios	1
2	2024-09-19 11:02:32.096528	Transportadora X	2
3	2024-09-19 11:02:32.096528	Correios	3
4	2024-09-19 11:02:32.096528	Motoboy	4
\.


--
-- Data for Name: itens_pedido; Type: TABLE DATA; Schema: public; Owner: zee
--

COPY public.itens_pedido (id_item, quantidade, preco_unitario, id_pedido, id_produto) FROM stdin;
1	2	1999.90	1	1
2	1	49.90	2	2
3	3	89.90	3	3
4	4	29.90	4	4
\.


--
-- Data for Name: pagamentos; Type: TABLE DATA; Schema: public; Owner: zee
--

COPY public.pagamentos (id_pagamento, valor_pago, data_pagamento, metodo_pagamento, id_pedido) FROM stdin;
1	3999.80	2024-09-19 11:02:32.096528	Cartão de Crédito	1
2	49.90	2024-09-19 11:02:32.096528	Boleto	2
3	269.70	2024-09-19 11:02:32.096528	Pix	3
4	119.60	2024-09-19 11:02:32.096528	Cartão de Débito	4
\.


--
-- Data for Name: pedidos; Type: TABLE DATA; Schema: public; Owner: zee
--

COPY public.pedidos (id_pedido, data_pedido, status, id_cliente) FROM stdin;
1	2024-09-19 11:02:32.096528	Concluído	1
2	2024-09-19 11:02:32.096528	Concluído	2
3	2024-09-19 11:02:32.096528	Concluído	3
4	2024-09-19 11:02:32.096528	Concluído	4
\.


--
-- Data for Name: produtos; Type: TABLE DATA; Schema: public; Owner: zee
--

COPY public.produtos (id_produto, nome_produto, preco, estoque, id_categoria) FROM stdin;
5	Sofá de 3 Lugares	2499.90	50	5
1	Smartphone XYZ	1999.90	98	1
2	Livro de Ficção Científica	49.90	199	2
3	Camisa Polo	89.90	147	3
4	Boneca de Pano	29.90	296	4
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: zee
--

COPY public.usuarios (id_usuario, username, senha, id_cliente) FROM stdin;
1	joaosilva	senha123	1
2	mariaoliveira	senha456	2
3	carlossouza	senha789	3
4	fernandaalmeida	senha987	4
\.


--
-- Name: categorias_id_categoria_seq; Type: SEQUENCE SET; Schema: public; Owner: zee
--

SELECT pg_catalog.setval('public.categorias_id_categoria_seq', 5, true);


--
-- Name: clientes_id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: zee
--

SELECT pg_catalog.setval('public.clientes_id_cliente_seq', 4, true);


--
-- Name: entrega_id_entrega_seq; Type: SEQUENCE SET; Schema: public; Owner: zee
--

SELECT pg_catalog.setval('public.entrega_id_entrega_seq', 4, true);


--
-- Name: envio_id_envio_seq; Type: SEQUENCE SET; Schema: public; Owner: zee
--

SELECT pg_catalog.setval('public.envio_id_envio_seq', 4, true);


--
-- Name: itens_pedido_id_item_seq; Type: SEQUENCE SET; Schema: public; Owner: zee
--

SELECT pg_catalog.setval('public.itens_pedido_id_item_seq', 4, true);


--
-- Name: pagamentos_id_pagamento_seq; Type: SEQUENCE SET; Schema: public; Owner: zee
--

SELECT pg_catalog.setval('public.pagamentos_id_pagamento_seq', 4, true);


--
-- Name: pedidos_id_pedido_seq; Type: SEQUENCE SET; Schema: public; Owner: zee
--

SELECT pg_catalog.setval('public.pedidos_id_pedido_seq', 4, true);


--
-- Name: produtos_id_produto_seq; Type: SEQUENCE SET; Schema: public; Owner: zee
--

SELECT pg_catalog.setval('public.produtos_id_produto_seq', 5, true);


--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: zee
--

SELECT pg_catalog.setval('public.usuarios_id_usuario_seq', 4, true);


--
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id_categoria);


--
-- Name: clientes clientes_email_key; Type: CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_email_key UNIQUE (email);


--
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente);


--
-- Name: entrega entrega_pkey; Type: CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.entrega
    ADD CONSTRAINT entrega_pkey PRIMARY KEY (id_entrega);


--
-- Name: envio envio_pkey; Type: CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.envio
    ADD CONSTRAINT envio_pkey PRIMARY KEY (id_envio);


--
-- Name: itens_pedido itens_pedido_pkey; Type: CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.itens_pedido
    ADD CONSTRAINT itens_pedido_pkey PRIMARY KEY (id_item);


--
-- Name: pagamentos pagamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_pkey PRIMARY KEY (id_pagamento);


--
-- Name: pedidos pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (id_pedido);


--
-- Name: produtos produtos_pkey; Type: CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT produtos_pkey PRIMARY KEY (id_produto);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario);


--
-- Name: usuarios usuarios_username_key; Type: CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_username_key UNIQUE (username);


--
-- Name: itens_pedido trigger_atualizar_estoque; Type: TRIGGER; Schema: public; Owner: zee
--

CREATE TRIGGER trigger_atualizar_estoque AFTER INSERT ON public.itens_pedido FOR EACH ROW EXECUTE FUNCTION public.atualizar_estoque_trigger();


--
-- Name: pagamentos trigger_atualizar_status_pedido; Type: TRIGGER; Schema: public; Owner: zee
--

CREATE TRIGGER trigger_atualizar_status_pedido AFTER INSERT ON public.pagamentos FOR EACH ROW EXECUTE FUNCTION public.atualizar_status_pedido_trigger();


--
-- Name: pedidos trigger_verificar_login_cliente; Type: TRIGGER; Schema: public; Owner: zee
--

CREATE TRIGGER trigger_verificar_login_cliente BEFORE INSERT ON public.pedidos FOR EACH ROW EXECUTE FUNCTION public.verificar_login_cliente();


--
-- Name: entrega entrega_id_envio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.entrega
    ADD CONSTRAINT entrega_id_envio_fkey FOREIGN KEY (id_envio) REFERENCES public.envio(id_envio);


--
-- Name: envio envio_id_pedido_fkey; Type: FK CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.envio
    ADD CONSTRAINT envio_id_pedido_fkey FOREIGN KEY (id_pedido) REFERENCES public.pedidos(id_pedido);


--
-- Name: itens_pedido itens_pedido_id_pedido_fkey; Type: FK CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.itens_pedido
    ADD CONSTRAINT itens_pedido_id_pedido_fkey FOREIGN KEY (id_pedido) REFERENCES public.pedidos(id_pedido);


--
-- Name: itens_pedido itens_pedido_id_produto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.itens_pedido
    ADD CONSTRAINT itens_pedido_id_produto_fkey FOREIGN KEY (id_produto) REFERENCES public.produtos(id_produto);


--
-- Name: pagamentos pagamentos_id_pedido_fkey; Type: FK CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_id_pedido_fkey FOREIGN KEY (id_pedido) REFERENCES public.pedidos(id_pedido);


--
-- Name: pedidos pedidos_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


--
-- Name: produtos produtos_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT produtos_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categorias(id_categoria);


--
-- Name: usuarios usuarios_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: zee
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


--
-- PostgreSQL database dump complete
--

