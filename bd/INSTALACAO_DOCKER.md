# 🐋 Tutorial de Instalação do Docker e Docker Compose

## 📋 Índice
- [Windows](#-instalação-no-windows)
- [Linux (Ubuntu/Debian)](#-instalação-no-linux-ubuntudebian)
- [Verificar Instalação](#-verificar-instalação)
- [Primeiros Passos](#-primeiros-passos)

---

## 🪟 Instalação no Windows

### Pré-requisitos
- Windows 10/11 64-bit (versão Pro, Enterprise ou Education)
- Virtualização habilitada na BIOS
- Pelo menos 4GB de RAM

### Passo 1: Verificar Requisitos

1. **Pressione** `Win + R` e digite `msinfo32`
2. Verifique se aparece "Virtualização habilitada" ou "Hyper-V"
3. Se não estiver habilitado, você precisa habilitar na BIOS

### Passo 2: Baixar o Docker Desktop

1. Acesse o site oficial: **https://www.docker.com/products/docker-desktop/**
2. Clique em **"Download for Windows"**
3. Aguarde o download do instalador (**Docker Desktop Installer.exe**)

### Passo 3: Instalar o Docker Desktop

1. **Execute o instalador** `Docker Desktop Installer.exe`
2. **Marque a opção**: "Use WSL 2 instead of Hyper-V" (recomendado)
3. Clique em **"Ok"**
4. Aguarde a instalação (pode demorar alguns minutos)
5. Clique em **"Close and restart"** quando terminar

### Passo 4: Configurar após reinicialização

1. Após reiniciar, o **Docker Desktop** abrirá automaticamente
2. Aceite os termos de serviço
3. Você pode pular o tutorial (Skip tutorial)
4. **Aguarde** o Docker iniciar (ícone da baleia na bandeja do sistema)

### Passo 5: Verificar a instalação

Abra o **PowerShell** ou **CMD** e execute:

```bash
docker --version
docker compose version
```

**Resultado esperado:**
```
Docker version 24.x.x, build xxxxx
Docker Compose version v2.x.x
```

### ✅ Pronto! Docker instalado no Windows

---

## 🐧 Instalação no Linux (Ubuntu/Debian)

### Método 1: Instalação via Script Oficial (Recomendado)

### Passo 1: Atualizar o sistema

```bash
sudo apt update
sudo apt upgrade -y
```

### Passo 2: Remover versões antigas (se existirem)

```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

### Passo 3: Instalar dependências

```bash
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

### Passo 4: Adicionar chave GPG oficial do Docker

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

### Passo 5: Adicionar repositório do Docker

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Passo 6: Instalar o Docker Engine

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Passo 7: Adicionar seu usuário ao grupo docker (importante!)

```bash
sudo usermod -aG docker $USER
```

### Passo 8: Aplicar as mudanças

```bash
newgrp docker
```

**OU** faça logout e login novamente para aplicar as permissões.

### Passo 9: Habilitar Docker na inicialização

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

### Passo 10: Verificar instalação

```bash
docker --version
docker compose version
```

**Resultado esperado:**
```
Docker version 24.x.x, build xxxxx
Docker Compose version v2.x.x
```

### ✅ Pronto! Docker instalado no Linux

---

## 🔧 Método 2: Instalação via Snap (Alternativa para Linux)

### ⚠️ Nota sobre Snap
Se você instalou via Snap, o comando é ligeiramente diferente:

```bash
# Instalar via Snap
sudo snap install docker

# O comando será:
docker compose up -d  # COM ESPAÇO (não docker-compose)
```

Esta é a versão que você provavelmente tem se instalou pelo comando:
```bash
sudo snap install docker
```

---

## ✅ Verificar Instalação

### Testar se o Docker está funcionando

Execute este comando em ambos os sistemas:

```bash
docker run hello-world
```

**Resultado esperado:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### Verificar versões

```bash
# Ver versão do Docker
docker --version

# Ver versão do Docker Compose
docker compose version

# Ver informações detalhadas
docker info
```

### Testar Docker Compose

```bash
# Verificar se o comando funciona
docker compose --help
```

---

## 🚀 Primeiros Passos

### 1. Testar com um exemplo simples

Crie um arquivo `docker-compose.yml`:

```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
```

Execute:

```bash
docker compose up -d
```

Acesse no navegador: **http://localhost:8080**

Para parar:

```bash
docker compose down
```

### 2. Comandos básicos do Docker

```bash
# Listar containers rodando
docker ps

# Listar todos os containers
docker ps -a

# Listar imagens
docker images

# Parar um container
docker stop <container_id>

# Remover um container
docker rm <container_id>

# Remover uma imagem
docker rmi <image_id>

# Ver logs de um container
docker logs <container_id>

# Entrar em um container rodando
docker exec -it <container_id> bash
```

### 3. Comandos básicos do Docker Compose

```bash
# Subir containers
docker compose up -d

# Parar containers
docker compose down

# Ver logs
docker compose logs

# Ver status
docker compose ps

# Rebuild e subir
docker compose up -d --build

# Parar e remover volumes
docker compose down -v
```

---

## 🎯 Usar a Aula de SQL

Agora você pode usar o projeto desta aula!

```bash
# Navegue até a pasta do projeto
cd /caminho/para/bd

# Suba os containers
docker compose up -d

# Aguarde 10 segundos e acesse
# http://localhost:8080
```

---

## 🔧 Problemas Comuns

### Windows: "Docker não inicia"

**Solução 1:** Habilitar WSL 2
```powershell
# No PowerShell como Administrador
wsl --install
wsl --set-default-version 2
```

**Solução 2:** Habilitar virtualização na BIOS
- Reinicie o PC
- Entre na BIOS (geralmente F2, DEL ou F12)
- Procure por "Virtualization Technology" ou "VT-x"
- Habilite e salve

### Linux: "Permission denied"

```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Fazer logout e login novamente
# OU
newgrp docker
```

### Linux: "Cannot connect to Docker daemon"

```bash
# Iniciar o serviço
sudo systemctl start docker

# Verificar status
sudo systemctl status docker
```

### "Command 'docker-compose' not found"

Use **`docker compose`** (com espaço) em vez de `docker-compose` (com hífen).

A versão nova do Docker Compose é um plugin e usa espaço:
```bash
docker compose up -d    # ✅ Correto
docker-compose up -d    # ❌ Versão antiga
```

### Porta 8080 já está em uso

```bash
# Ver o que está usando a porta
# Windows:
netstat -ano | findstr :8080

# Linux:
sudo lsof -i :8080

# Matar o processo ou mudar a porta no docker-compose.yml
```

---

## 📚 Recursos Adicionais

### Documentação Oficial
- **Docker:** https://docs.docker.com/
- **Docker Compose:** https://docs.docker.com/compose/

### Tutoriais
- **Docker Getting Started:** https://docs.docker.com/get-started/
- **Docker Compose Tutorial:** https://docs.docker.com/compose/gettingstarted/

### Comandos Úteis
- **Docker Cheat Sheet:** https://docs.docker.com/get-started/docker_cheatsheet.pdf

---

## 🎓 Próximos Passos

Depois de instalar o Docker:

1. ✅ Execute `docker run hello-world` para testar
2. ✅ Clone ou crie o projeto da aula de SQL
3. ✅ Execute `docker compose up -d` na pasta do projeto
4. ✅ Acesse http://localhost:8080 e comece a aprender!

---

## 💡 Dicas Importantes

### Para Desenvolvedores

1. **Sempre use `-d`** para rodar em background
   ```bash
   docker compose up -d
   ```

2. **Ver logs em tempo real**
   ```bash
   docker compose logs -f
   ```

3. **Rebuild após mudanças**
   ```bash
   docker compose up -d --build
   ```

4. **Limpar tudo (cuidado!)**
   ```bash
   docker compose down -v
   docker system prune -a
   ```

### Performance

- **Windows:** Docker Desktop usa bastante memória (2-4GB)
- **Linux:** Mais leve e performático
- **Limite recursos** nas configurações do Docker Desktop se necessário

### Segurança

- Não execute containers como root em produção
- Use imagens oficiais quando possível
- Mantenha Docker atualizado

---

## ✅ Checklist Final

Após a instalação, verifique:

- [ ] `docker --version` funciona
- [ ] `docker compose version` funciona
- [ ] `docker run hello-world` funciona
- [ ] `docker ps` funciona (mesmo que vazio)
- [ ] Consegue acessar http://localhost após `docker compose up`

---

**Instalação concluída! Agora você está pronto para usar Docker! 🐋🚀**
