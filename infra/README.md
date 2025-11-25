# Docker Compose Setup

This directory contains the Docker Compose configuration for running the entire application stack.

## Services

- **db**: PostgreSQL database
- **backend**: Django REST API
- **frontend**: React frontend (served via nginx)
- **minio**: MinIO object storage (optional, for file storage)

## Quick Start

1. **Start all services:**
   ```bash
   cd infra
   docker compose up
   ```

2. **Start in detached mode (background):**
   ```bash
   docker compose up -d
   ```

3. **Stop all services:**
   ```bash
   docker compose down
   ```

4. **View logs:**
   ```bash
   docker compose logs -f
   ```

5. **Rebuild containers:**
   ```bash
   docker compose up --build
   ```

## Access Points

- **Frontend**: http://localhost:80
- **Backend API**: http://localhost:8000
- **Django Admin**: http://localhost:8000/admin/
- **MinIO Console**: http://localhost:9001 (minioadmin/minioadmin)

## Database

The database is automatically initialized when the `db` service starts. Migrations are run automatically when the backend starts.

## Environment Variables

Database connection is configured via environment variables in `docker-compose.yml`:
- `DATABASE_HOST=db`
- `DATABASE_PORT=5432`
- `DATABASE_NAME=django`
- `DATABASE_USER=django_admin`
- `DATABASE_PASSWORD=123iki123`

## Volumes

- `postgres_data`: Persistent database storage
- `static_volume`: Django static files
- `media_volume`: User-uploaded media files
- `minio_data`: MinIO object storage

## Troubleshooting

1. **Port conflicts**: Make sure ports 80, 8000, 5432, 9000, 9001 are not in use
2. **Database connection errors**: Wait for the database to be healthy before backend starts
3. **Build errors**: Run `docker compose build --no-cache` to rebuild from scratch

