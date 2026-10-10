# RoteiroCare

A Phoenix LiveView application for managing educational courses with interactive content including videos, forms, and PDF materials.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [Development](#development)
- [Deployment](#deployment)

---

## Prerequisites

Before you begin, ensure you have the following installed on your machine:

- **Erlang 24.3+** (recommended: 25.3)
- **Elixir 1.14.0+**
- **Docker** (for PostgreSQL database)
- **Git**

### Installing Erlang and Elixir with asdf (Recommended)

The easiest way to manage Erlang and Elixir versions is using [asdf](https://asdf-vm.com/):

1. Install asdf:
   ```bash
   brew install asdf
   ```

2. Add required plugins:
   ```bash
   asdf plugin-add erlang
   asdf plugin-add elixir
   ```

3. Install the recommended versions:
   ```bash
   asdf install erlang 25.3
   asdf install elixir 1.14.0
   ```

4. Set them as global versions:
   ```bash
   asdf global erlang 25.3
   asdf global elixir 1.14.0
   ```

5. Verify installation:
   ```bash
   elixir --version
   ```

---

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd RoteiroCare
```

### 2. Install Dependencies

Install Elixir dependencies and set up the project:

```bash
mix deps.get
```

Install Node.js dependencies for assets:

```bash
cd assets && npm install && cd ..
```

### 3. Configure Environment Variables

Create a `.env.local` file in the project root with the necessary environment variables:

```bash
# OpenAI Configuration
export OPENAI_API_URL="https://api.openai.com/v1"
export OPENAI_API_KEY="your_openai_api_key_here"

# Database Configuration
export DATABASE_URL="postgresql://postgres:postgres@localhost:5432/app_dev"

# Secret Key Base (generate with: mix phx.gen.secret)
export SECRET_KEY_BASE="your_secret_key_base_here"
```

**Important:** Always load the environment variables before starting the server:

```bash
source .env.local
```

---

## Database Setup

### Start PostgreSQL with Docker

Run a PostgreSQL container using Docker:

```bash
docker run -p 5432:5432 \
  --name db-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -d postgres
```

**Note:** The container will persist until you explicitly stop and remove it.

### Create and Migrate Database

Create the database and run migrations:

```bash
mix ecto.setup
```

This command will:
- Create the database
- Run all migrations
- Run seed data (if available)

If the database already exists, you can run migrations separately:

```bash
mix ecto.migrate
```

### Database Configuration

The default development database configuration is:

- **Host:** localhost
- **Port:** 5432
- **Username:** postgres
- **Password:** postgres
- **Database:** app_dev

You can modify these settings in `config/dev.exs` if needed.

---

## Running the Application

### Start the Phoenix Server

**Important:** Always load environment variables first:

```bash
source .env.local
mix phx.server
```

Or run it inside IEx (Interactive Elixir) for debugging:

```bash
source .env.local
iex -S mix phx.server
```

### Access the Application

Open your browser and navigate to:

**[http://localhost:4000](http://localhost:4000)**

The application will automatically reload when you make changes to the code.

---

## Development

### Project Structure

```
lib/
├── app/              # Business logic and contexts
├── app_web/          # Web interface (controllers, views, LiveViews)
│   ├── live/         # LiveView modules
│   │   ├── course/   # Course management
│   │   └── home/     # Public pages
│   └── router.ex     # Route definitions
priv/
├── repo/             # Database migrations and seeds
└── static/           # Static assets
assets/
├── css/              # Stylesheets
└── js/               # JavaScript and LiveView hooks
```

### Useful Commands

```bash
# Run tests
mix test

# Run tests with coverage
mix test --cover

# Format code
mix format

# Check code quality
mix credo

# Start interactive shell
iex -S mix

# Reset database (drop, create, migrate, seed)
mix ecto.reset

# Create a new migration
mix ecto.gen.migration migration_name
```

### Managing the Database Container

```bash
# Stop the container
docker stop db-postgres

# Start the container
docker start db-postgres

# Remove the container
docker rm -f db-postgres

# View container logs
docker logs db-postgres
```

---

## Deployment

### Deploy to Fly.io

1. Install the Fly CLI:
   ```bash
   brew install flyctl
   ```

2. Login to Fly.io:
   ```bash
   fly auth login
   ```

3. Deploy the application:
   ```bash
   fly deploy
   ```

### Accessing Production Database

**Option 1: SSH into the database machine**
```bash
# Connect to the database machine
fly ssh console -a roteirocare-db

# Once connected, access PostgreSQL
psql -U postgres -d roteirocare
```

**Option 2: Create a secure tunnel (proxy)**
```bash
# Create a local tunnel to the database
fly proxy 5432:5432 -a roteirocare-db

# In another terminal, connect using psql
psql "postgresql://roteirocare:PASSWORD@localhost:5432/roteirocare"
```

**Option 3: Get connection string**
```bash
# View database connection info
fly postgres connect -a roteirocare-db

# Or check secrets to get the password
fly secrets list -a roteirocare
```

**Option 4: Use a database GUI (recommended)**
```bash
# Start proxy (keeps running)
fly proxy 5432:5432 -a roteirocare-db

# Then connect with your favorite tool (DBeaver, pgAdmin, TablePlus, etc.)
# Settings:
#   Host: localhost
#   Port: 5432
#   Database: roteirocare
#   User: roteirocare
#   Password: (get from: fly secrets list -a roteirocare | grep DATABASE_URL)
```

**Running migrations in production:**
```bash
# Migrations run automatically on deploy via release_command
# Or manually:
fly ssh console -a roteirocare -C "/app/bin/migrate"
```

4. (Optional) View app logs:
   ```bash
   fly logs -a roteirocare
   ```

### Production Considerations

For production deployment, consult the official [Phoenix deployment guide](https://hexdocs.pm/phoenix/deployment.html).

Key production steps:
- Set proper environment variables
- Use a production-ready database
- Configure proper secret management
- Enable SSL/HTTPS
- Set up monitoring and logging

---

## Features

- **Course Management**: Create and manage educational courses
- **File Uploads**: Support for images and PDF materials
- **Interactive Forms**: Multi-step forms with conditional rendering
- **Video Integration**: Embed and manage video content
- **Responsive Design**: Mobile-friendly interface with Tailwind CSS
- **Real-time Updates**: Phoenix LiveView for interactive experiences

---

## Technology Stack

- **Phoenix Framework 1.7.11** - Web framework
- **Phoenix LiveView 0.20.2** - Real-time interactive UI
- **Ecto 3.10** - Database wrapper and query generator
- **PostgreSQL** - Relational database
- **Tailwind CSS** - Utility-first CSS framework
- **Alpine.js** - Lightweight JavaScript framework
- **Heroicons** - Beautiful hand-crafted SVG icons

---

## License

[Add your license information here]

---

## Contributing

[Add contribution guidelines here]

---

# PostgreSQL no Fly.io - roteirocare-db

Este diretório contém a configuração do banco de dados PostgreSQL do projeto.

## ⚠️ Importante

**NÃO use `fly deploy`** para apps PostgreSQL! O banco usa uma imagem pré-construída e não tem Dockerfile.

## Comandos Úteis

### Ver status do banco
```bash
fly status -a roteirocare-db
```

### Listar máquinas
```bash
fly machine list -a roteirocare-db
```

### Atualizar tamanho da máquina
Para mudar o tamanho de CPU/memória da máquina:

```bash
fly machine update <MACHINE_ID> -a roteirocare-db --vm-size <size> --vm-memory <mb>
```

Exemplo (mudando para shared-cpu-1x com 512MB):
```bash
fly machine update 4d8946d6a20738 -a roteirocare-db --vm-size shared-cpu-1x --vm-memory 512
```

**Tamanhos disponíveis:**
- `shared-cpu-1x` (1 CPU compartilhada)
- `shared-cpu-2x` (2 CPUs compartilhadas)
- `shared-cpu-4x` (4 CPUs compartilhadas)
- `shared-cpu-8x` (8 CPUs compartilhadas)
- `performance-1x`, `performance-2x`, etc. (CPUs dedicadas)

### Escalar (adicionar réplicas)
```bash
fly scale -a roteirocare-db count 2
```

### Reiniciar máquina
```bash
fly machine restart <MACHINE_ID> -a roteirocare-db
```

### Ver logs
```bash
fly logs -a roteirocare-db
```

### Conectar ao banco via SSH
```bash
fly ssh console -a roteirocare-db
```

Dentro do container:
```bash
# Conectar ao PostgreSQL
psql -U postgres

# Ver databases
\l

# Conectar a um database específico
\c nome_do_database
```

### Fazer backup
```bash
fly ssh console -a roteirocare-db -C "pg_dump -U postgres nome_do_database" > backup.sql
```

### Ver métricas e monitoramento
```bash
fly dashboard -a roteirocare-db
```

## Configuração Atual

- **App**: roteirocare-db
- **Região**: gru (São Paulo)
- **Imagem**: flyio/postgres-flex:17.2
- **Tamanho**: shared-cpu-1x (1 CPU)
- **Memória**: 512MB
- **Volume**: pg_data (montado em /data)

## Arquivo fly.toml

O arquivo `fly.toml` neste diretório serve apenas como **referência** da configuração atual. Mudanças nele não são aplicadas automaticamente. Use os comandos `fly machine update` para modificar a infraestrutura.

## Links Úteis

- [Documentação Fly.io PostgreSQL](https://fly.io/docs/postgres/)
- [Dashboard do App](https://fly.io/apps/roteirocare-db)
- [Métricas](https://fly.io/apps/roteirocare-db/metrics)


## Support

For issues and questions, please [open an issue](link-to-issues) on GitHub.

