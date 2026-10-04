# Local Cloud

A local simulation of AWS EC2 + deployment pipeline using Docker.

## What this project demonstrates

- **Infrastructure as Code**: Everything defined in Dockerfile and docker-compose.yml
- **SSH-based server access**: Simulating AWS EC2 key pairs
- **Application deployment**: Flask app running under gunicorn
- **Reverse proxy**: Nginx in front of the app (production pattern)
- **Automated setup**: One command brings up the entire stack
- **Reproducibility**: Anyone can clone and run this in seconds

## Architecture

```
┌─────────────────────────────────────────────────┐
│ Your Laptop │
│ │
│ ┌───────────────────────────────────────────┐ │
│ │ Docker Compose │ │
│ │ │ │
│ │ ┌─────────────────────────────────────┐ │ │
│ │ │ Container: local-ec2 (Ubuntu 22.04)│ │ │
│ │ │ │ │ │
│ │ │ ┌─────────┐ ┌──────────────┐ │ │ │
│ │ │ │ Nginx │─────▶│ gunicorn │ │ │ │
│ │ │ │ :80 │ │ :5000 │ │ │ │
│ │ │ └─────────┘ └──────┬───────┘ │ │ │
│ │ │ │ │ │ │
│ │ │ ▼ │ │ │
│ │ │ ┌──────────┐ │ │ │
│ │ │ │ Flask │ │ │ │
│ │ │ │ app.py │ │ │ │
│ │ │ └──────────┘ │ │ │
│ │ │ │ │ │
│ │ │ SSH server :22 │ │ │
│ │ └─────────────────────────────────────┘ │ │
│ │ │ │
│ │ Ports mapped to host: │ │
│ │ 8090 → 80 (HTTP) │ │
│ │ 2222 → 22 (SSH) │ │
│ └───────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

## AWS Concept Mapping

| AWS Concept | This Project |
|----------------------|---------------------------------|
| IAM Key Pair | `ssh/id_ec2` |
| EC2 Instance | Docker container (`local-ec2`) |
| AMI | `local-ec2:latest` image |
| Security Group | Docker port mappings |
| Elastic IP | `localhost:8090` |
| SSH to EC2 | `ssh local-cloud` |
| User Data script | `docker/entrypoint.sh` |
| EBS Volume | Docker volume mount |

## Quick Start

### Prerequisites

- Docker
- Docker Compose
- SSH client

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/itsepehrmi/local-cloud.git
cd local-cloud

# 2. Generate SSH key pair
./scripts/generate-keys.sh

# 3. Start everything
docker-compose up -d --build

# 4. Wait ~30 seconds for first-time setup
docker-compose logs -f
```

### Access

- **Web**: http://localhost:8090
- **SSH**: `ssh -p 2222 deploy@localhost -i ./ssh/id_ec2`

Optional: add the SSH config to `~/.ssh/config`:

```bash
cat ssh/ssh_config.example >> ~/.ssh/config
```

Then just:

```bash
ssh local-cloud
```

## API Endpoints

| Endpoint | Description |
|------------|--------------------------------------|
| `/` | Welcome message with hostname |
| `/health` | Health check (returns 200 if OK) |
| `/info` | Application and environment info |

## Project Structure

```
local-cloud/
├── app/ # Flask application
│ ├── app.py
│ └── requirements.txt
├── docker/
│ ├── Dockerfile # Container definition
│ └── entrypoint.sh # Startup script
├── nginx/
│ └── myapp.conf # Nginx reverse proxy config
├── ssh/
│ ├── generate-keys.sh # Key generation (gitignored output)
│ └── ssh_config.example # Sample SSH config
├── scripts/
│ └── setup-server.sh # Manual server setup script
├── docker-compose.yml
└── README.md
```

## How it works

1. `docker-compose up` builds the image and starts the container
2. `entrypoint.sh` runs on container start:
   - Starts SSH daemon
   - Creates Python venv (first run only)
   - Installs requirements
   - Configures and starts Nginx
   - Starts gunicorn (as PID 1)
3. Traffic flows: `browser → Nginx:80 → gunicorn:5000 → Flask`

## Useful commands

```bash
# View logs
docker-compose logs -f

# Restart container
docker-compose restart

# Stop everything
docker-compose down

# Rebuild image
docker-compose up -d --build

# SSH into container
ssh -p 2222 deploy@localhost -i ./ssh/id_ec2

# Run a command inside container
docker exec -it local-ec2 bash
```

## License

MIT
