# 🎓 Aula de SQL: Triggers, Views e Subconsultas

## 📋 Sobre Este Projeto

Este é um projeto didático completo para ensinar e demonstrar três conceitos fundamentais de SQL:
- **VIEWS** (Visões)
- **TRIGGERS** (Gatilhos)
- **SUBCONSULTAS** (Subqueries)

Tudo está pronto para executar! Basta subir o Docker Compose e executar as queries.

## 🚀 Como Usar

### 1️⃣ Iniciar o Banco de Dados

```bash
docker compose up -d
```

Este comando vai:
- Baixar a imagem do PostgreSQL 15
- Baixar o Adminer (interface web)
- Criar os containers
- Executar automaticamente o script `init.sql`
- Criar todas as tabelas, views, triggers e dados de exemplo

**Aguarde 5-10 segundos** para o banco inicializar completamente.

### 2️⃣ Acessar a Interface Web (RECOMENDADO)

Abra seu navegador e acesse:

**🌐 http://localhost:8080**

Faça login com as credenciais:
- **Sistema:** PostgreSQL
- **Servidor:** postgres
- **Usuário:** aluno
- **Senha:** senha123
- **Base de dados:** aula_bd

![Tela de Login do Adminer](https://i.imgur.com/placeholder.png)

Agora você pode:
- ✅ Ver todas as tabelas, views e triggers
- ✅ Executar queries diretamente no navegador
- ✅ Ver os resultados em tabelas formatadas
- ✅ Exportar dados
- ✅ Ver a estrutura do banco visualmente

### 3️⃣ Executar Queries no Adminer (Interface Web)

**Passo a passo:**

1. **Acesse** http://localhost:8080 e faça login
2. No menu esquerdo, clique em **"Comando SQL"** (ou "SQL command")
3. Você verá um **grande campo de texto** onde pode escrever queries
4. **Cole ou escreva** sua query SQL (ex: `SELECT * FROM view_vendas_completo;`)
5. Clique no botão **"Executar"** (ou pressione Ctrl+Enter)
6. Os resultados aparecem em uma **tabela formatada** abaixo

**💡 Dicas:**
- ✅ Você pode executar **várias queries de uma vez** (separadas por `;`)
- ✅ Os resultados são mostrados em **tabelas clicáveis**
- ✅ Você pode **exportar** os resultados (CSV, JSON, etc)
- ✅ Tem **histórico** de queries executadas
- ✅ Autocomplete para tabelas e colunas

**📋 Queries para começar:**

Copie e cole estas queries no campo SQL:

```sql
-- Ver todas as vendas
SELECT * FROM view_vendas_completo;

-- Ver produtos mais vendidos
SELECT * FROM view_produtos_mais_vendidos;

-- Inserir nova venda (testa os TRIGGERS)
INSERT INTO vendas (cliente_id, produto_id, quantidade)
VALUES (1, 3, 2);

-- Ver estoque atualizado
SELECT id, nome, estoque FROM produtos WHERE id = 3;
```

**Opção B - Terminal (Linha de Comando):**

```bash
docker exec -it aula_sql psql -U aluno -d aula_bd
```

## 📚 Conceitos Ensinados

### 🔍 1. VIEWS (Visões)

**O que são?** Views são "tabelas virtuais" que armazenam consultas SQL. São úteis para:
- Simplificar consultas complexas
- Melhorar segurança (controlar acesso a dados)
- Reutilizar lógica de negócio

**Views criadas neste projeto:**

1. **view_vendas_completo** - Relatório completo de vendas com dados de clientes e produtos
2. **view_vendas_por_cliente** - Resumo de vendas agrupadas por cliente
3. **view_produtos_mais_vendidos** - Ranking dos produtos mais vendidos
4. **view_estoque_valorizado** - Valor total do estoque por produto

**Exemplo de uso:**
```sql
-- Ao invés de fazer um JOIN complexo toda vez:
SELECT * FROM view_vendas_completo;

-- É muito mais simples que:
SELECT v.id, c.nome, p.nome, v.quantidade, v.valor_total
FROM vendas v
JOIN clientes c ON v.cliente_id = c.id
JOIN produtos p ON v.produto_id = p.id;
```

### ⚡ 2. TRIGGERS (Gatilhos)

**O que são?** Triggers são procedimentos que são executados automaticamente quando eventos específicos ocorrem no banco (INSERT, UPDATE, DELETE).

**Triggers criados neste projeto:**

1. **trigger_atualizar_estoque** - Atualiza o estoque automaticamente quando uma venda é inserida
2. **trigger_calcular_valor** - Calcula o valor total da venda baseado no preço do produto
3. **trigger_auditar_vendas** - Registra todas as alterações e exclusões em vendas
4. **trigger_validar_quantidade** - Valida que a quantidade seja sempre positiva

**Exemplo prático:**
```sql
-- Quando você insere uma venda:
INSERT INTO vendas (cliente_id, produto_id, quantidade)
VALUES (1, 2, 5);

-- O trigger automaticamente:
-- 1. Calcula o valor_total (quantidade × preço)
-- 2. Diminui o estoque do produto
-- 3. Valida que a quantidade é positiva
```

### 🔗 3. SUBCONSULTAS (Subqueries)

**O que são?** Subconsultas são queries dentro de outras queries. Permitem fazer comparações e filtros complexos.

**Tipos demonstrados:**

1. **Subconsulta no WHERE** - Filtrar dados baseados em outra query
2. **Subconsulta no HAVING** - Filtrar grupos de dados
3. **Subconsulta no SELECT** - Calcular valores para cada linha
4. **EXISTS / NOT EXISTS** - Verificar existência de dados relacionados
5. **IN / NOT IN** - Verificar se valor está em uma lista de resultados

**Exemplos:**

```sql
-- Clientes que gastaram acima da média
SELECT nome, SUM(valor_total) AS total
FROM clientes c
JOIN vendas v ON c.id = v.cliente_id
GROUP BY c.nome
HAVING SUM(valor_total) > (
    SELECT AVG(total) FROM (
        SELECT SUM(valor_total) AS total
        FROM vendas
        GROUP BY cliente_id
    ) AS medias
);

-- Clientes que nunca compraram móveis
SELECT nome FROM clientes
WHERE id NOT IN (
    SELECT DISTINCT cliente_id
    FROM vendas v
    JOIN produtos p ON v.produto_id = p.id
    WHERE p.categoria = 'Móveis'
);
```

## 📊 Estrutura do Banco de Dados

### Tabelas

1. **clientes** - Dados dos clientes (id, nome, cidade, estado)
2. **produtos** - Catálogo de produtos (id, nome, preco, estoque, categoria)
3. **vendas** - Registro de vendas (id, cliente_id, produto_id, quantidade, valor_total, data_venda)
4. **auditoria_vendas** - Log de alterações em vendas (criada pelo trigger)

### Dados de Exemplo

- 7 clientes cadastrados
- 8 produtos em 2 categorias (Eletrônicos e Móveis)
- 10 vendas já registradas
- Valores reais em Reais (R$)

## 🎯 Roteiro Sugerido para a Aula

### Parte 1: Explorando VIEWS (15 min)
1. Mostrar as tabelas básicas
2. Executar queries com JOINs manualmente
3. Apresentar as views criadas
4. Demonstrar como as views simplificam as consultas

### Parte 2: Testando TRIGGERS (20 min)
1. Verificar estoque atual
2. Inserir uma nova venda
3. Mostrar como o estoque foi atualizado automaticamente
4. Mostrar como o valor foi calculado automaticamente
5. Tentar inserir dados inválidos (quantidade negativa)
6. Mostrar a auditoria funcionando

### Parte 3: Subconsultas (25 min)
1. Começar com subconsultas simples no WHERE
2. Mostrar subconsultas no HAVING
3. Demonstrar EXISTS e IN
4. Queries mais complexas combinando conceitos
5. Comparar performance quando relevante

## 🛠️ Comandos Úteis

### Ver todas as views criadas:
```sql
SELECT table_name FROM information_schema.views 
WHERE table_schema = 'public';
```

### Ver todos os triggers:
```sql
SELECT trigger_name, event_object_table 
FROM information_schema.triggers 
WHERE trigger_schema = 'public';
```

### Ver detalhes de uma view:
```sql
\d+ view_vendas_completo
```

### Reiniciar do zero:
```bash
docker compose down -v
docker compose up -d
```

## 📝 Exercícios Propostos

Após demonstrar os conceitos, proponha aos alunos:

### Exercício 1: Criar uma VIEW
Criar uma view que mostre produtos com estoque baixo (menos de 10 unidades).

<details>
<summary>Solução</summary>

```sql
CREATE VIEW view_estoque_baixo AS
SELECT id, nome, estoque, categoria
FROM produtos
WHERE estoque < 10
ORDER BY estoque;
```
</details>

### Exercício 2: Criar um TRIGGER
Criar um trigger que impeça a exclusão de produtos que já foram vendidos.

<details>
<summary>Solução</summary>

```sql
CREATE OR REPLACE FUNCTION impedir_exclusao_produto()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM vendas WHERE produto_id = OLD.id) THEN
        RAISE EXCEPTION 'Não é possível excluir produto que já foi vendido!';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_impedir_exclusao
BEFORE DELETE ON produtos
FOR EACH ROW
EXECUTE FUNCTION impedir_exclusao_produto();
```
</details>

### Exercício 3: Subconsulta
Listar produtos que nunca foram vendidos.

<details>
<summary>Solução</summary>

```sql
SELECT nome, preco, estoque
FROM produtos
WHERE id NOT IN (
    SELECT DISTINCT produto_id FROM vendas
);
```
</details>

## 🎓 Conceitos Importantes

### Por que usar VIEWS?
- ✅ Simplifica queries complexas
- ✅ Reutilização de código
- ✅ Segurança (usuários veem apenas o necessário)
- ✅ Abstração da estrutura do banco

### Por que usar TRIGGERS?
- ✅ Automatização de tarefas
- ✅ Validação de dados
- ✅ Auditoria automática
- ✅ Manutenção de integridade
- ⚠️ Cuidado: podem afetar performance

### Por que usar SUBCONSULTAS?
- ✅ Filtros complexos
- ✅ Comparações dinâmicas
- ✅ Queries mais expressivas
- ⚠️ Pode ser menos performático que JOINs

## 🔧 Troubleshooting

### Container não inicia?
```bash
docker compose logs
```

### Erro de conexão?
Aguarde alguns segundos após o `docker compose up` - o banco precisa de tempo para inicializar.

### Banco não tem dados?
Verifique se o arquivo `init.sql` está na mesma pasta do `docker-compose.yml`.

**Nota:** Se instalou Docker via snap, use `docker compose` (com espaço) em vez de `docker-compose` (com hífen).

### Resetar tudo:
```bash
docker compose down -v
docker compose up -d
```

## 📦 Arquivos do Projeto

- `docker-compose.yml` - Configuração do container Docker
- `init.sql` - Script de inicialização do banco (tabelas, dados, views, triggers)
- `queries.sql` - Queries prontas para demonstração
- `README.md` - Este arquivo

## 🎯 Objetivos de Aprendizado

Ao final desta aula, os alunos devem ser capazes de:
- ✅ Entender o conceito e uso de VIEWS
- ✅ Criar e modificar VIEWS
- ✅ Entender como TRIGGERS funcionam
- ✅ Criar TRIGGERS para diferentes eventos
- ✅ Usar subconsultas em diferentes contextos
- ✅ Combinar estes conceitos em queries complexas

## 💡 Dicas para o Professor

1. **Comece pelo simples** - Mostre primeiro as tabelas básicas
2. **Demonstre o problema** - Mostre queries complexas antes de apresentar views
3. **Interativo** - Deixe os alunos executarem as queries
4. **Erros propositais** - Mostre o que acontece quando regras são violadas
5. **Performance** - Discuta quando usar cada técnica
6. **Casos reais** - Relacione com sistemas do mundo real

## 📞 Suporte

Este é um projeto educacional. Sinta-se livre para modificar e adaptar conforme necessário!

---

**Bons estudos! 🚀**
