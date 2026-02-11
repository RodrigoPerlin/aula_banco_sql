-- ============================================
-- QUERIES PARA DEMONSTRAÇÃO
-- Execute estas queries para ver os conceitos em ação!
-- ============================================

-- ============================================
-- PARTE 1: CONSULTANDO AS VIEWS
-- ============================================

-- Query 1: Ver todas as vendas com informações completas
-- (usando a VIEW que criamos)
SELECT * FROM view_vendas_completo;

-- Query 2: Ver resumo de vendas por cliente
-- Mostra quantas compras cada cliente fez e quanto gastou
SELECT * FROM view_vendas_por_cliente;

-- Query 3: Ver produtos mais vendidos
SELECT * FROM view_produtos_mais_vendidos;

-- Query 4: Ver valor do estoque
SELECT * FROM view_estoque_valorizado;

-- ============================================
-- PARTE 2: SUBCONSULTAS (SUBQUERIES)
-- ============================================
-- Subconsultas são queries dentro de outras queries.
-- Úteis para filtros complexos e comparações.

-- SUBCONSULTA 1: Clientes que gastaram acima da média
SELECT 
    c.nome,
    SUM(v.valor_total) AS total_gasto
FROM clientes c
JOIN vendas v ON c.id = v.cliente_id
GROUP BY c.id, c.nome
HAVING SUM(v.valor_total) > (
    -- Subconsulta: calcula a média de gastos
    SELECT AVG(total) FROM (
        SELECT SUM(valor_total) AS total
        FROM vendas
        GROUP BY cliente_id
    ) AS medias
)
ORDER BY total_gasto DESC;

-- SUBCONSULTA 2: Produtos com preço acima da média da categoria
SELECT 
    p.nome,
    p.categoria,
    p.preco,
    ROUND((
        SELECT AVG(preco)
        FROM produtos p2
        WHERE p2.categoria = p.categoria
    ), 2) AS media_categoria
FROM produtos p
WHERE p.preco > (
    SELECT AVG(preco)
    FROM produtos p2
    WHERE p2.categoria = p.categoria
)
ORDER BY p.categoria, p.preco DESC;

-- SUBCONSULTA 3: Clientes que nunca compraram produtos da categoria 'Móveis'
SELECT nome, cidade
FROM clientes
WHERE id NOT IN (
    -- Subconsulta: IDs de clientes que compraram móveis
    SELECT DISTINCT v.cliente_id
    FROM vendas v
    JOIN produtos p ON v.produto_id = p.id
    WHERE p.categoria = 'Móveis'
);

-- SUBCONSULTA 4: Produtos mais caros que todos os produtos de 'Eletrônicos'
SELECT nome, preco, categoria
FROM produtos
WHERE preco > (
    SELECT MAX(preco)
    FROM produtos
    WHERE categoria = 'Eletrônicos'
);

-- SUBCONSULTA 5: Vendas em valores acima do ticket médio
SELECT 
    v.id AS venda_id,
    c.nome AS cliente,
    p.nome AS produto,
    v.valor_total
FROM vendas v
JOIN clientes c ON v.cliente_id = c.id
JOIN produtos p ON v.produto_id = p.id
WHERE v.valor_total > (SELECT AVG(valor_total) FROM vendas)
ORDER BY v.valor_total DESC;

-- SUBCONSULTA 6: Cidades com vendas totais acima de 1000
SELECT 
    c.cidade,
    COUNT(v.id) AS num_vendas,
    SUM(v.valor_total) AS total_vendido
FROM clientes c
JOIN vendas v ON c.id = v.cliente_id
GROUP BY c.cidade
HAVING SUM(v.valor_total) > (
    SELECT 1000  -- Valor fixo como exemplo
)
ORDER BY total_vendido DESC;

-- SUBCONSULTA 7: Usar EXISTS para encontrar clientes com compras
SELECT c.nome, c.cidade
FROM clientes c
WHERE EXISTS (
    SELECT 1
    FROM vendas v
    WHERE v.cliente_id = c.id
    AND v.valor_total > 1000
);

-- ============================================
-- PARTE 3: TESTANDO OS TRIGGERS
-- ============================================

-- TESTE 1: Ver estoque atual dos produtos
SELECT id, nome, estoque FROM produtos ORDER BY id;

-- TESTE 2: Inserir nova venda (vai acionar TRIGGER de estoque e cálculo)
-- Observe que NÃO precisamos informar o valor_total - o trigger calcula!
INSERT INTO vendas (cliente_id, produto_id, quantidade)
VALUES (1, 2, 5);

-- TESTE 3: Ver estoque atualizado (deve ter diminuído)
SELECT id, nome, estoque FROM produtos WHERE id = 2;

-- TESTE 4: Ver a nova venda com valor calculado automaticamente
SELECT * FROM vendas ORDER BY id DESC LIMIT 1;

-- TESTE 5: Tentar inserir venda com quantidade inválida (vai dar erro!)
-- Descomente a linha abaixo para testar:
-- INSERT INTO vendas (cliente_id, produto_id, quantidade) VALUES (1, 1, -5);

-- TESTE 6: Atualizar uma venda (vai acionar o TRIGGER de auditoria)
UPDATE vendas 
SET valor_total = 200.00
WHERE id = 2;

-- TESTE 7: Ver registros de auditoria criados
SELECT * FROM auditoria_vendas;

-- TESTE 8: Deletar uma venda (também registra na auditoria)
DELETE FROM vendas WHERE id = 3;

-- TESTE 9: Ver auditoria novamente
SELECT 
    id,
    venda_id,
    acao,
    valor_antigo,
    valor_novo,
    data_auditoria
FROM auditoria_vendas
ORDER BY data_auditoria DESC;

-- ============================================
-- PARTE 4: QUERIES AVANÇADAS COM SUBCONSULTAS
-- ============================================

-- QUERY AVANÇADA 1: Ranking de clientes com subconsulta
SELECT 
    c.nome,
    c.cidade,
    (SELECT COUNT(*) FROM vendas v WHERE v.cliente_id = c.id) AS num_compras,
    (SELECT COALESCE(SUM(valor_total), 0) FROM vendas v WHERE v.cliente_id = c.id) AS total_gasto,
    CASE 
        WHEN (SELECT COALESCE(SUM(valor_total), 0) FROM vendas v WHERE v.cliente_id = c.id) > 5000 THEN 'VIP'
        WHEN (SELECT COALESCE(SUM(valor_total), 0) FROM vendas v WHERE v.cliente_id = c.id) > 2000 THEN 'Gold'
        WHEN (SELECT COALESCE(SUM(valor_total), 0) FROM vendas v WHERE v.cliente_id = c.id) > 0 THEN 'Silver'
        ELSE 'Novo'
    END AS categoria_cliente
FROM clientes c
ORDER BY total_gasto DESC;

-- QUERY AVANÇADA 2: Produtos que nunca foram vendidos
SELECT 
    p.id,
    p.nome,
    p.preco,
    p.estoque,
    p.categoria
FROM produtos p
WHERE NOT EXISTS (
    SELECT 1 FROM vendas v WHERE v.produto_id = p.id
);

-- QUERY AVANÇADA 3: Comparação de vendas por estado
SELECT 
    c.estado,
    COUNT(v.id) AS total_vendas,
    SUM(v.valor_total) AS receita_total,
    AVG(v.valor_total) AS ticket_medio,
    ROUND(
        (SUM(v.valor_total) * 100.0 / (SELECT SUM(valor_total) FROM vendas)),
        2
    ) AS percentual_receita
FROM clientes c
JOIN vendas v ON c.id = v.cliente_id
GROUP BY c.estado
ORDER BY receita_total DESC;

-- ============================================
-- PARTE 5: RELATÓRIOS COMBINANDO TUDO
-- ============================================

-- RELATÓRIO FINAL: Dashboard Completo
-- Combina VIEWs, SUBQUERies e dados originais
SELECT 
    'Total de Clientes' AS metrica,
    COUNT(*)::TEXT AS valor
FROM clientes
UNION ALL
SELECT 
    'Total de Produtos',
    COUNT(*)::TEXT
FROM produtos
UNION ALL
SELECT 
    'Total de Vendas',
    COUNT(*)::TEXT
FROM vendas
UNION ALL
SELECT 
    'Receita Total',
    'R$ ' || ROUND(SUM(valor_total), 2)::TEXT
FROM vendas
UNION ALL
SELECT 
    'Ticket Médio',
    'R$ ' || ROUND(AVG(valor_total), 2)::TEXT
FROM vendas
UNION ALL
SELECT 
    'Produto Mais Vendido',
    produto
FROM view_produtos_mais_vendidos
LIMIT 1
UNION ALL
SELECT 
    'Melhor Cliente',
    cliente
FROM view_vendas_por_cliente
LIMIT 1;

-- ============================================
-- DICA: Explorando a Estrutura
-- ============================================

-- Ver todas as VIEWs criadas
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Ver todos os TRIGGERs criados
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- Ver todas as FUNÇÕEs criadas
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_type = 'FUNCTION'
ORDER BY routine_name;
