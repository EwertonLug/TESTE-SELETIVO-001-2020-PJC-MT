 SELECT a.codigo,
    a.nome AS cerveja,
    COALESCE(( SELECT sum(b.quantidade) AS sum
           FROM item_venda b
          WHERE (b.codigo_cerveja = a.codigo)), (0)::bigint) AS quantidade
   FROM cerveja a
  ORDER BY COALESCE(( SELECT sum(b.quantidade) AS sum
           FROM item_venda b
          WHERE (b.codigo_cerveja = a.codigo)), (0)::bigint) DESC;