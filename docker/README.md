# Docker Compose quick reference

Run these commands from the directory containing `compose.yaml` or
`docker-compose.yml`. Replace `<service>` with a service name from the Compose
file.

## Start services

```bash
# Start services in the foreground. Press Ctrl+C to stop them.
docker compose up

# Start services in the background.
docker compose up -d

# Rebuild images before starting services.
docker compose up --build

# Remove containers from older Compose configurations if they are reported as
# orphans.
docker compose up --remove-orphans
```

## Inspect services

```bash
# List services and their current state.
docker compose ps

# Follow logs for all services.
docker compose logs -f

# Follow logs for one service.
docker compose logs -f <service>
```

## Stop and restart

```bash
# Stop containers without removing them.
docker compose stop

# Start stopped containers.
docker compose start

# Restart containers.
docker compose restart
```

## Run one-off commands

```bash
# Open a shell in a running service.
docker compose exec <service> sh

# Run a command in a temporary container and remove it afterwards.
docker compose run --rm <service> <command>
```

`exec` requires a running container. `run --rm` creates a temporary container
for the command and removes it when the command finishes.

## Remove resources

```bash
# Stop and remove containers and the Compose network.
docker compose down

# Also remove named volumes declared by the Compose file.
docker compose down --volumes

# Also remove images used by the services.
docker compose down --rmi local
```

Use `down --volumes` carefully: it deletes data stored in named volumes.