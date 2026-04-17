# Docker Setup (DB + Server)

This setup runs:
- `db`: MySQL 8 (`psme-mysql`)
- `app`: Tomcat 9 (`psme-tomcat`) serving `dist/PSME.war`
- `phpmyadmin`: phpMyAdmin UI (`psme-phpmyadmin`)

## 1. Prerequisites

- Docker Desktop

## 2. Configure environment

Create `.env` from `.env.example`:

```powershell
Copy-Item .env.example .env
```

Default values are usable for development.

## 3. Start from VS Code

Use `Terminal > Run Task`:
- `PSME: Docker Up`
- `PSME: Docker Logs`
- `PSME: Docker Down`

`PSME: Docker Up` runs Ant first, then starts the containers.

If you use plain Docker Compose instead, run:

```powershell
docker compose up --build -d
```

The app image now builds `PSME.war` from source during the Docker build, so a local Ant install is no longer required.

## 4. Access app

- Application: `http://localhost:8080/PSME`
- MySQL: `localhost:3306`
- phpMyAdmin: `http://localhost:8081`

phpMyAdmin login:
- Server: `db` (inside Docker) or `localhost` (if prompted with host from browser flow)
- Username: `root`
- Password: value of `MYSQL_ROOT_PASSWORD` in `.env`

## 5. Database notes

- `db/schema.sql` is auto-applied on first DB initialization only.
- To reset DB and re-run initialization:

```powershell
docker compose down -v
docker compose up -d
```

## 6. Why this works in containers

`DBConnection` supports env overrides:
- `DB_DRIVER`
- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`

`docker-compose.yml` sets these for the Tomcat container so no local-only DB host assumptions are required.
