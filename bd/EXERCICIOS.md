# 📚 Guia de Comandos e Exercícios SQL

## 🎯 Como usar este guia

**Copie e cole** os comandos diretamente no Adminer (http://localhost:8080 → Comando SQL)

---

## 1️⃣ COMANDOS BÁSICOS - SELECT e WHERE

### 📖 O que é WHERE?
Filtra registros baseado em condições.

### 🔥 Exemplos para executar:

```sql
-- Buscar todos os clientes
SELECT * FROM clientes;

-- Buscar clientes de São Paulo
SELECT * FROM clientes
WHERE cidade = 'São Paulo';

-- Buscar clientes de SP (estado)
SELECT * FROM clientes
WHERE estado = 'SP';

-- Buscar produtos com preço maior que 500
SELECT nome, preco, categoria
FROM produtos
WHERE preco > 500;

-- Buscar produtos entre 100 e 1000 reais
SELECT nome, preco
FROM produtos
WHERE preco BETWEEN 100 AND 1000;

-- Buscar múltiplas condições (E)
SELECT nome, cidade, estado
FROM clientes
WHERE cidade = 'São Paulo' AND estado = 'SP';

-- Buscar múltiplas condições (OU)
SELECT nome, categoria, preco
FROM produtos
WHERE categoria = 'Móveis' OR preco > 2000;
```

---

## 2️⃣ OPERADOR LIKE - Buscas Parciais

### 📖 O que é LIKE?
Permite buscar textos parciais usando curingas:
- `%` = qualquer sequência de caracteres
- `_` = um único caractere

### 🔥 Exemplos para executar:

```sql
-- Buscar clientes cujo nome começa com 'J'
SELECT nome FROM clientes
WHERE nome LIKE 'J%';

-- Buscar clientes cujo nome termina com 'a'
SELECT nome FROM clientes
WHERE nome LIKE '%a';

-- Buscar clientes com 'Silva' no nome
SELECT nome FROM clientes
WHERE nome LIKE '%Silva%';

-- Buscar produtos que contém 'Mouse' no nome
SELECT nome, preco FROM produtos
WHERE nome LIKE '%Mouse%';

-- Buscar produtos que começam com 'M' (case insensitive)
SELECT nome, preco FROM produtos
WHERE nome ILIKE 'm%';

-- Buscar cidades que contém 'Rio'
SELECT DISTINCT cidade FROM clientes
WHERE cidade LIKE '%Rio%';
```

---

## 3️⃣ VIEWS - Consultas Salvas

### 📖 O que são VIEWS?
Tabelas virtuais que salvam consultas complexas para reutilização.

### 🔥 Comandos das Views já criadas:

```sql
-- Ver todas as vendas com informações completas
SELECT * FROM view_vendas_completo;

-- Filtrar vendas de um cliente específico
SELECT * FROM view_vendas_completo
WHERE cliente = 'João Silva';

-- Filtrar vendas por categoria
SELECT * FROM view_vendas_completo
WHERE categoria = 'Eletrônicos';

-- Ver resumo de vendas por cliente
SELECT * FROM view_vendas_por_cliente;

-- Ver clientes que gastaram mais de 2000
SELECT * FROM view_vendas_por_cliente
WHERE total_gasto > 2000;

-- Ver produtos mais vendidos
SELECT * FROM view_produtos_mais_vendidos;

-- Ver estoque valorizado
SELECT * FROM view_estoque_valorizado;

-- Ver apenas produtos com valor alto em estoque
SELECT * FROM view_estoque_valorizado
WHERE valor_estoque > 1000;
```

### 🔧 Criar suas próprias VIEWS:

```sql
-- Criar view de clientes VIP (gastaram mais de 3000)
CREATE VIEW view_clientes_vip AS
SELECT 
    c.nome,
    c.cidade,
    COUNT(v.id) AS total_compras,
    SUM(v.valor_total) AS total_gasto
FROM clientes c
JOIN vendas v ON c.id = v.cliente_id
GROUP BY c.id, c.nome, c.cidade
HAVING SUM(v.valor_total) > 3000;

-- Usar a view criada
SELECT * FROM view_clientes_vip;

-- Criar view de produtos em falta (estoque baixo)
CREATE VIEW view_estoque_critico AS
SELECT id, nome, estoque, preco, categoria
FROM produtos
WHERE estoque < 10
ORDER BY estoque;

-- Ver produtos em falta
SELECT * FROM view_estoque_critico;
```

---

## 4️⃣ SUBCONSULTAS (Subqueries)

### 📖 O que são SUBCONSULTAS?
Queries dentro de outras queries. Permitem comparações complexas.

### 🔥 Exemplos para executar:

```sql
-- 1. Produtos mais caros que a média
SELECT nome, preco
FROM produtos
WHERE preco > (SELECT AVG(preco) FROM produtos);

-- 2. Clientes que gastaram acima da média
SELECT c.nome, SUM(v.valor_total) AS total
FROM clientes c
JOIN vendas v ON c.id = v.cliente_id
GROUP BY c.id, c.nome
HAVING SUM(v.valor_total) > (
    SELECT AVG(total) FROM (
        SELECT SUM(valor_total) AS total
        FROM vendas
        GROUP BY cliente_id
    ) AS medias
);

-- 3. Clientes que NUNCA compraram Móveis (NOT IN)
SELECT nome, cidade
FROM clientes
WHERE id NOT IN (
    SELECT DISTINCT cliente_id
    FROM vendas v
    JOIN produtos p ON v.produto_id = p.id
    WHERE p.categoria = 'Móveis'
);

-- 4. Produtos que JÁ foram vendidos (IN)
SELECT nome, preco
FROM produtos
WHERE id IN (
    SELECT DISTINCT produto_id FROM vendas
);

-- 5. Produtos NUNCA vendidos
SELECT nome, preco, estoque
FROM produtos
WHERE id NOT IN (
    SELECT DISTINCT produto_id FROM vendas
);

-- 6. Clientes que fizeram compras (EXISTS)
SELECT nome, cidade
FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM vendas v
    WHERE v.cliente_id = c.id
);

-- 7. Clientes que NUNCA compraram (NOT EXISTS)
SELECT nome, cidade
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1 FROM vendas v
    WHERE v.cliente_id = c.id
);

-- 8. Produtos mais caros que TODOS os produtos de uma categoria
SELECT nome, preco, categoria
FROM produtos
WHERE preco > (
    SELECT MAX(preco) FROM produtos
    WHERE categoria = 'Eletrônicos'
);

-- 9. Vendas acima do ticket médio
SELECT v.id, c.nome, p.nome, v.valor_total
FROM vendas v
JOIN clientes c ON v.cliente_id = c.id
JOIN produtos p ON v.produto_id = p.id
WHERE v.valor_total > (SELECT AVG(valor_total) FROM vendas);

-- 10. Quantidade de produtos por categoria (subconsulta no SELECT)
SELECT 
    c.nome AS cliente,
    (SELECT COUNT(*) FROM vendas v WHERE v.cliente_id = c.id) AS num_compras,
    (SELECT SUM(valor_total) FROM vendas v WHERE v.cliente_id = c.id) AS total_gasto
FROM clientes c
ORDER BY total_gasto DESC;
```

---

## 5️⃣ TRIGGERS - Ações Automáticas

### 📖 O que são TRIGGERS?
Procedimentos executados automaticamente em eventos (INSERT, UPDATE, DELETE).

### 🔥 Testando os TRIGGERS existentes:

```sql
-- 1. Ver estoque ANTES de inserir venda
SELECT id, nome, estoque FROM produtos WHERE id = 4;

-- 2. Inserir nova venda (TRIGGER vai calcular valor_total e diminuir estoque)
INSERT INTO vendas (cliente_id, produto_id, quantidade)
VALUES (2, 4, 1);

-- 3. Ver estoque DEPOIS (diminuiu automaticamente!)
SELECT id, nome, estoque FROM produtos WHERE id = 4;

-- 4. Ver a venda inserida (valor_total foi calculado automaticamente!)
SELECT * FROM vendas ORDER BY id DESC LIMIT 1;

-- 5. Atualizar uma venda (TRIGGER registra na auditoria)
UPDATE vendas 
SET valor_total = 1000.00
WHERE id = 5;

-- 6. Ver registro de auditoria criado
SELECT * FROM auditoria_vendas ORDER BY data_auditoria DESC;

-- 7. Tentar inserir quantidade inválida (TRIGGER impede!)
-- Esta query vai DAR ERRO de propósito:
INSERT INTO vendas (cliente_id, produto_id, quantidade)
VALUES (1, 1, -5);
-- Resultado: ERRO! Quantidade deve ser maior que zero

-- 8. Tentar inserir quantidade zero (também dá erro)
INSERT INTO vendas (cliente_id, produto_id, quantidade)
VALUES (1, 1, 0);
```

### 🔧 Criar seu próprio TRIGGER:

```sql
-- Criar trigger que impede deletar produtos vendidos
CREATE OR REPLACE FUNCTION impedir_exclusao_produto()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM vendas WHERE produto_id = OLD.id) THEN
        RAISE EXCEPTION 'Não pode deletar produto que já foi vendido!';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_proteger_produto
BEFORE DELETE ON produtos
FOR EACH ROW
EXECUTE FUNCTION impedir_exclusao_produto();

-- Testar o trigger (vai dar erro)
DELETE FROM produtos WHERE id = 1;
```

---

## 6️⃣ QUERIES COMBINADAS (WHERE + LIKE + Subconsultas)

```sql
-- 1. Clientes de cidades que começam com 'S' e gastaram mais de 1000
SELECT c.nome, c.cidade, SUM(v.valor_total) AS total
FROM clientes c
JOIN vendas v ON c.id = v.cliente_id
WHERE c.cidade LIKE 'S%'
GROUP BY c.id, c.nome, c.cidade
HAVING SUM(v.valor_total) > 1000;

-- 2. Produtos com nome contendo 'o' e preço acima da média
SELECT nome, preco
FROM produtos
WHERE nome LIKE '%o%'
  AND preco > (SELECT AVG(preco) FROM produtos);

-- 3. Vendas de clientes cujo nome começa com 'J' ou 'M'
SELECT c.nome, p.nome AS produto, v.valor_total
FROM vendas v
JOIN clientes c ON v.cliente_id = c.id
JOIN produtos p ON v.produto_id = p.id
WHERE c.nome LIKE 'J%' OR c.nome LIKE 'M%';

-- 4. Produtos de categoria 'Eletrônicos' que foram vendidos
SELECT DISTINCT p.nome, p.preco
FROM produtos p
WHERE p.categoria LIKE 'Eletr%'
  AND p.id IN (SELECT produto_id FROM vendas);
```

---

## 📝 EXERCÍCIOS PRÁTICOS

### ✏️ Exercício 1: SELECT e WHERE
**Tarefa:** Buscar todos os produtos da categoria "Eletrônicos" com preço menor que 500.

<details>
<summary>👁️ Ver Solução</summary>

```sql
SELECT nome, preco, categoria
FROM produtos
WHERE categoria = 'Eletrônicos' AND preco < 500;
```
</details>

---

### ✏️ Exercício 2: LIKE
**Tarefa:** Encontrar todos os clientes cujo nome contém "Silva" OU "Santos".

<details>
<summary>👁️ Ver Solução</summary>

```sql
SELECT nome, cidade
FROM clientes
WHERE nome LIKE '%Silva%' OR nome LIKE '%Santos%';
```
</details>

---

### ✏️ Exercício 3: Criar uma VIEW
**Tarefa:** Criar uma view chamada `view_vendas_sp` que mostre apenas vendas de clientes de São Paulo.

<details>
<summary>👁️ Ver Solução</summary>

```sql
CREATE VIEW view_vendas_sp AS
SELECT 
    v.id,
    c.nome AS cliente,
    p.nome AS produto,
    v.quantidade,
    v.valor_total,
    v.data_venda
FROM vendas v
JOIN clientes c ON v.cliente_id = c.id
JOIN produtos p ON v.produto_id = p.id
WHERE c.cidade = 'São Paulo';

-- Testar a view
SELECT * FROM view_vendas_sp;
```
</details>

---

### ✏️ Exercício 4: Subconsulta simples
**Tarefa:** Listar produtos com estoque MENOR que a média de estoque.

<details>
<summary>👁️ Ver Solução</summary>

```sql
SELECT nome, estoque
FROM produtos
WHERE estoque < (SELECT AVG(estoque) FROM produtos)
ORDER BY estoque;
```
</details>

---

### ✏️ Exercício 5: Subconsulta com NOT IN
**Tarefa:** Encontrar clientes que NUNCA compraram produtos da categoria "Eletrônicos".

<details>
<summary>👁️ Ver Solução</summary>

```sql
SELECT nome, cidade
FROM clientes
WHERE id NOT IN (
    SELECT DISTINCT v.cliente_id
    FROM vendas v
    JOIN produtos p ON v.produto_id = p.id
    WHERE p.categoria = 'Eletrônicos'
);
```
</details>

---

### ✏️ Exercício 6: Subconsulta com EXISTS
**Tarefa:** Listar produtos que já tiveram pelo menos uma venda com valor acima de 1000.

<details>
<summary>👁️ Ver Solução</summary>

```sql
SELECT p.nome, p.preco
FROM produtos p
WHERE EXISTS (
    SELECT 1 FROM vendas v
    WHERE v.produto_id = p.id
    AND v.valor_total > 1000
);
```
</details>

---

### ✏️ Exercício 7: WHERE + LIKE + Subconsulta
**Tarefa:** Buscar clientes de cidades que começam com "Rio" e que gastaram mais que a média geral.

<details>
<summary>👁️ Ver Solução</summary>

```sql
SELECT c.nome, c.cidade, SUM(v.valor_total) AS total_gasto
FROM clientes c
JOIN vendas v ON c.id = v.cliente_id
WHERE c.cidade LIKE 'Rio%'
GROUP BY c.id, c.nome, c.cidade
HAVING SUM(v.valor_total) > (
    SELECT AVG(total) FROM (
        SELECT SUM(valor_total) AS total
        FROM vendas
        GROUP BY cliente_id
    ) AS medias
);
```
</details>

---

### ✏️ Exercício 8: Criar VIEW complexa
**Tarefa:** Criar uma view que mostre produtos "populares" (vendidos mais de 2 vezes) com suas estatísticas.

<details>
<summary>👁️ Ver Solução</summary>

```sql
CREATE VIEW view_produtos_populares AS
SELECT 
    p.nome,
    p.categoria,
    p.preco,
    COUNT(v.id) AS vezes_vendido,
    SUM(v.quantidade) AS quantidade_total,
    SUM(v.valor_total) AS receita_total
FROM produtos p
JOIN vendas v ON p.id = v.produto_id
GROUP BY p.id, p.nome, p.categoria, p.preco
HAVING COUNT(v.id) > 2
ORDER BY vezes_vendido DESC;

-- Testar
SELECT * FROM view_produtos_populares;
```
</details>

---

### ✏️ Exercício 9: Criar TRIGGER
**Tarefa:** Criar um trigger que registre quando um produto tem seu preço alterado.

<details>
<summary>👁️ Ver Solução</summary>

```sql
-- Primeiro, criar tabela de auditoria de preços
CREATE TABLE IF NOT EXISTS auditoria_precos (
    id SERIAL PRIMARY KEY,
    produto_id INT,
    preco_antigo DECIMAL(10,2),
    preco_novo DECIMAL(10,2),
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar função do trigger
CREATE OR REPLACE FUNCTION auditar_preco()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.preco != NEW.preco THEN
        INSERT INTO auditoria_precos (produto_id, preco_antigo, preco_novo)
        VALUES (NEW.id, OLD.preco, NEW.preco);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger
CREATE TRIGGER trigger_auditar_preco
AFTER UPDATE ON produtos
FOR EACH ROW
EXECUTE FUNCTION auditar_preco();

-- Testar o trigger
UPDATE produtos SET preco = 400.00 WHERE id = 3;

-- Ver auditoria
SELECT * FROM auditoria_precos;
```
</details>

---

### ✏️ Exercício 10: Query Complexa
**Tarefa:** Criar um ranking dos 3 melhores clientes por estado, mostrando nome, estado, e total gasto.

<details>
<summary>👁️ Ver Solução</summary>

```sql
WITH ranking_por_estado AS (
    SELECT 
        c.nome,
        c.estado,
        SUM(v.valor_total) AS total_gasto,
        ROW_NUMBER() OVER (PARTITION BY c.estado ORDER BY SUM(v.valor_total) DESC) AS ranking
    FROM clientes c
    JOIN vendas v ON c.id = v.cliente_id
    GROUP BY c.id, c.nome, c.estado
)
SELECT nome, estado, total_gasto, ranking
FROM ranking_por_estado
WHERE ranking <= 3
ORDER BY estado, ranking;
```
</details>

---

## 🎯 DESAFIOS AVANÇADOS

### 🔥 Desafio 1
Criar uma view que mostre, para cada categoria de produto, quantos clientes diferentes compraram, a receita total, e o ticket médio.

### 🔥 Desafio 2
Criar um trigger que envie um alerta (RAISE NOTICE) quando o estoque de um produto ficar abaixo de 5 unidades.

### 🔥 Desafio 3
Escrever uma query com subconsulta que encontre o cliente que mais comprou de cada estado.

### 🔥 Desafio 4
Criar uma view que combine WHERE, LIKE e subconsultas para mostrar produtos "premium" (preço acima da média) cujo nome contém vogais.

---

## 📊 QUERIES ÚTEIS PARA EXPLORAR

```sql
-- Ver estrutura de uma tabela
\d vendas

-- Ver todas as views
SELECT table_name FROM information_schema.views 
WHERE table_schema = 'public';

-- Ver todos os triggers
SELECT trigger_name, event_object_table 
FROM information_schema.triggers 
WHERE trigger_schema = 'public';

-- Ver todas as funções
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public';

-- Estatísticas gerais
SELECT 
    'Clientes' AS tabela, COUNT(*) AS total FROM clientes
UNION ALL
SELECT 'Produtos', COUNT(*) FROM produtos
UNION ALL
SELECT 'Vendas', COUNT(*) FROM vendas;
```

---

## 💡 DICAS

1. **Teste incrementalmente** - Execute partes da query primeiro
2. **Use LIMIT** - Adicione `LIMIT 10` para ver apenas algumas linhas
3. **Comente suas queries** - Use `--` para comentários
4. **Salve suas queries** - Copie queries úteis para um arquivo
5. **Veja os erros** - Mensagens de erro ajudam a aprender!

---

**Bons estudos! 🚀**
