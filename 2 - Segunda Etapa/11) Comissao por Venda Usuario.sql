 SELECT sum((((a.valor_total * ( SELECT sum(b.comissao) AS sum
           FROM (cerveja b
             JOIN item_venda c ON ((b.codigo = c.codigo_cerveja)))
          WHERE (c.codigo_venda = a.codigo))) / (100)::numeric))::numeric(10,2)) AS total_comissao
   FROM venda a
  WHERE (a.codigo_usuario = 3);