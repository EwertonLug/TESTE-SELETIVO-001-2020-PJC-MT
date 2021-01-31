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
   FROM (venda a
     JOIN usuario b ON ((b.codigo = a.codigo_usuario)))
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