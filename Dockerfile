# Stage 1: Dependency builder
FROM python:3.13-slim AS builder

# Define variáveis de ambiente
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.8.0 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# Adiciona o poetry e o venv ao PATH
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Instala dependências do sistema necessárias
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential \
        libpq-dev \
        gcc \
    && rm -rf /var/lib/apt/lists/*

# Instala o Poetry
RUN curl -sSL https://install.python-poetry.org | python -

# Define o diretório de trabalho e copia os arquivos de dependência
WORKDIR $PYSETUP_PATH
COPY pyproject.toml poetry.lock ./

# Instala as dependências do projeto
RUN poetry install --no-root

# Stage 2: Final image with your application code
FROM python:3.13-slim

# Define as variáveis de ambiente novamente
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_HOME="/opt/poetry" \
    VENV_PATH="/opt/pysetup/.venv"

# Adiciona o poetry e o venv ao PATH
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Copia o ambiente virtual do estágio de build e o diretório do Poetry
COPY --from=builder /opt/poetry /opt/poetry
COPY --from=builder /opt/pysetup/.venv /opt/pysetup/.venv

# Define o diretório de trabalho para o código da aplicação
WORKDIR /app

# Copia todo o código da sua aplicação para o contêiner
COPY . .

# Expor a porta que o servidor irá rodar
EXPOSE 8000

# Define a variável de ambiente para o Django
ENV DJANGO_SETTINGS_MODULE=bookstore.settings

# Comando para iniciar o servidor
CMD ["poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]