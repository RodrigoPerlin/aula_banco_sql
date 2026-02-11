-- ============================================
-- AULA: TRIGGERS, VIEWS E SUBCONSULTAS (SQL)
-- ============================================

-- Limpar tabelas se existirem
DROP TABLE IF EXISTS auditoria_vendas CASCADE;
DROP TABLE IF EXISTS vendas CASCADE;
DROP TABLE IF EXISTS produtos CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

-- ============================================
-- 1. CRIAÇÃO DAS TABELAS
-- ============================================

-- Tabela de Clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(50),
    estado VARCHAR(2)
);

-- Tabela de Produtos
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    estoque INT NOT NULL DEFAULT 0,
    categoria VARCHAR(50)
);

-- Tabela de Vendas
CREATE TABLE vendas (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(id),
    produto_id INT REFERENCES produtos(id),
    quantidade INT NOT NULL,
    valor_total DECIMAL(10, 2),
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Auditoria (para demonstrar TRIGGERS)
CREATE TABLE auditoria_vendas (
    id SERIAL PRIMARY KEY,
    venda_id INT,
    acao VARCHAR(20),
    valor_antigo DECIMAL(10, 2),
    valor_novo DECIMAL(10, 2),
    data_auditoria TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(50)
);

-- ============================================
-- 2. INSERÇÃO DE DADOS DE EXEMPLO
-- ============================================

INSERT INTO clientes (nome, cidade, estado) VALUES
('João Silva', 'São Paulo', 'SP'),
('Maria Santos', 'Rio de Janeiro', 'RJ'),
('Pedro Oliveira', 'São Paulo', 'SP'),
('Ana Costa', 'Belo Horizonte', 'MG'),
('Carlos Souza', 'Rio de Janeiro', 'RJ'),
('Juliana Lima', 'Curitiba', 'PR'),
('Roberto Alves', 'São Paulo', 'SP');

INSERT INTO produtos (nome, preco, estoque, categoria) VALUES
('Notebook Dell', 3500.00, 10, 'Eletrônicos'),
('Mouse Logitech', 80.00, 50, 'Eletrônicos'),
('Teclado Mecânico', 350.00, 30, 'Eletrônicos'),
('Monitor LG 24"', 900.00, 15, 'Eletrônicos'),
('Cadeira Gamer', 1200.00, 8, 'Móveis'),
('Mesa Escritório', 800.00, 5, 'Móveis'),
('Webcam HD', 250.00, 25, 'Eletrônicos'),
('Headset', 180.00, 40, 'Eletrônicos');

INSERT INTO vendas (cliente_id, produto_id, quantidade, valor_total) VALUES
(1, 1, 1, 3500.00),
(2, 2, 2, 160.00),
(3, 3, 1, 350.00),
(1, 4, 2, 1800.00),
(4, 5, 1, 1200.00),
(5, 2, 3, 240.00),
(6, 7, 1, 250.00),
(7, 8, 2, 360.00),
(2, 1, 1, 3500.00),
(3, 5, 1, 1200.00);

-- ============================================
-- 3. VIEWS (VISÕES)
-- ============================================
-- Views são "tabelas virtuais" que armazenam consultas.
-- Úteis para simplificar consultas complexas e segurança.

-- VIEW 1: Relatório de Vendas Completo
CREATE OR REPLACE VIEW view_vendas_completo AS
SELECT 
    v.id AS venda_id,
    c.nome AS cliente,
    c.cidade,
    c.estado,
    p.nome AS produto,
    p.categoria,
    v.quantidade,
    p.preco AS preco_unitario,
    v.valor_total,
    v.data_venda
FROM vendas v
JOIN clientes c ON v.cliente_id = c.id
JOIN produtos p ON v.produto_id = p.id
ORDER BY v.data_venda DESC;

-- VIEW 2: Resumo de Vendas por Cliente
CREATE OR REPLACE VIEW view_vendas_por_cliente AS
SELECT 
    c.id AS cliente_id,
    c.nome AS cliente,
    COUNT(v.id) AS total_compras,
    SUM(v.valor_total) AS total_gasto,
    AVG(v.valor_total) AS ticket_medio
FROM clientes c
LEFT JOIN vendas v ON c.id = v.cliente_id
GROUP BY c.id, c.nome
ORDER BY total_gasto DESC;

-- VIEW 3: Produtos Mais Vendidos
CREATE OR REPLACE VIEW view_produtos_mais_vendidos AS
SELECT 
    p.id AS produto_id,
    p.nome AS produto,
    p.categoria,
    SUM(v.quantidade) AS quantidade_vendida,
    SUM(v.valor_total) AS receita_total,
    COUNT(v.id) AS numero_vendas
FROM produtos p
LEFT JOIN vendas v ON p.id = v.produto_id
GROUP BY p.id, p.nome, p.categoria
ORDER BY quantidade_vendida DESC;

-- VIEW 4: Estoque e Valor em Estoque
CREATE OR REPLACE VIEW view_estoque_valorizado AS
SELECT 
    id,
    nome,
    categoria,
    estoque,
    preco,
    (estoque * preco) AS valor_estoque
FROM produtos
WHERE estoque > 0
ORDER BY valor_estoque DESC;

-- ============================================
-- 4. TRIGGERS (GATILHOS)
-- ============================================
-- Triggers são procedimentos automáticos executados
-- quando eventos específicos ocorrem (INSERT, UPDATE, DELETE).

-- TRIGGER 1: Atualizar Estoque ao Inserir Venda
CREATE OR REPLACE FUNCTION atualizar_estoque()
RETURNS TRIGGER AS $$
BEGIN
    -- Diminui o estoque do produto vendido
    UPDATE produtos 
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.produto_id;
    
    -- Verifica se o estoque ficou negativo (alerta)
    IF (SELECT estoque FROM produtos WHERE id = NEW.produto_id) < 0 THEN
        RAISE NOTICE 'ALERTA: Estoque negativo para produto ID %', NEW.produto_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_estoque
AFTER INSERT ON vendas
FOR EACH ROW
EXECUTE FUNCTION atualizar_estoque();

-- TRIGGER 2: Calcular Valor Total Automaticamente
CREATE OR REPLACE FUNCTION calcular_valor_total()
RETURNS TRIGGER AS $$
BEGIN
    -- Calcula o valor total baseado no preço do produto
    SELECT preco * NEW.quantidade INTO NEW.valor_total
    FROM produtos
    WHERE id = NEW.produto_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calcular_valor
BEFORE INSERT ON vendas
FOR EACH ROW
EXECUTE FUNCTION calcular_valor_total();

-- TRIGGER 3: Auditoria de Alterações em Vendas
CREATE OR REPLACE FUNCTION auditar_vendas()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        INSERT INTO auditoria_vendas (venda_id, acao, valor_antigo, valor_novo, usuario)
        VALUES (NEW.id, 'UPDATE', OLD.valor_total, NEW.valor_total, current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria_vendas (venda_id, acao, valor_antigo, valor_novo, usuario)
        VALUES (OLD.id, 'DELETE', OLD.valor_total, NULL, current_user);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auditar_vendas
AFTER UPDATE OR DELETE ON vendas
FOR EACH ROW
EXECUTE FUNCTION auditar_vendas();

-- TRIGGER 4: Validar Quantidade Positiva
CREATE OR REPLACE FUNCTION validar_quantidade()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantidade <= 0 THEN
        RAISE EXCEPTION 'A quantidade deve ser maior que zero!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_quantidade
BEFORE INSERT OR UPDATE ON vendas
FOR EACH ROW
EXECUTE FUNCTION validar_quantidade();

-- ============================================
-- MENSAGEM DE SUCESSO
-- ============================================
DO $$ 
BEGIN 
    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Banco de dados inicializado com sucesso!';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Tabelas criadas: clientes, produtos, vendas, auditoria_vendas';
    RAISE NOTICE 'Views criadas: 4 views prontas para consulta';
    RAISE NOTICE 'Triggers criados: 4 triggers ativos';
    RAISE NOTICE '';
    RAISE NOTICE 'Execute as queries do arquivo queries.sql para testar!';
    RAISE NOTICE '==============================================';
END $$;
