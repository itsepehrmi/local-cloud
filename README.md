# Local Cloud

A local simulation of AWS EC2 + deployment pipeline using Docker, Kubernetes (Kind), and Ingress.

## What this project demonstrates

- **Infrastructure as Code**: Everything defined in Dockerfile, docker-compose.yml, and Kubernetes manifests.
- **SSH-based server access**: Simulating AWS EC2 key pairs.
- **Application deployment**: Flask app running under gunicorn.
- **Reverse proxy**: Nginx in front of the app (Docker Compose) and Ingress-Nginx (Kubernetes).
- **Automated setup**: One command brings up the entire stack.
- **Reproducibility**: Anyone can clone and run this in seconds.

## Architecture (Docker Compose)

    +---------------------------------------------------------+
    |  Your Laptop                                            |
    |                                                         |
    |  +---------------------------------------------------+  |
    |  |  Docker Compose                                   |  |
    |  |                                                   |  |
    |  |  +---------------------------------------------+  |  |
    |  |  |  Container: local-ec2 (Ubuntu 22.04)        |  |  |
    |  |  |                                             |  |  |
    |  |  |  +---------+      +--------------+          |  |  |
    |  |  |  |  Nginx  |----->|  gunicorn    |          |  |  |
    |  |  |  |  :80    |      |  :5000       |          |  |  |
    |  |  |  +---------+      +------+-------+          |  |  |
    |  |  |                          |                  |  |  |
    |  |  |                          v                  |  |  |
    |  |  |                    +----------+             |  |  |
    |  |  |                    |  Flask   |             |  |  |
    |  |  |                    |  app.py  |             |  |  |
    |  |  |                    +----------+             |  |  |
    |  |  |                                             |  |  |
    |  |  |  SSH server :22                             |  |  |
    |  |  +---------------------------------------------+  |  |
    |  |                                                   |  |
    |  |  Ports mapped to host:                            |  |
    |  |    8090 -> 80    (HTTP)                           |  |
    |  |    2222 -> 22    (SSH)                            |  |
    |  +---------------------------------------------------+  |
    +---------------------------------------------------------+

## Architecture (Kubernetes)

    [User] -> [Ingress (Nginx)] -> [Flask Service] -> [Flask Pods]

## AWS Concept Mapping

| AWS Concept          | This Project                    |
|----------------------|---------------------------------|
| IAM Key Pair         | ssh/id_ec2                      |
| EC2 Instance         | Docker container (local-ec2)    |
| AMI                  | local-ec2:latest image          |
| Security Group       | Docker port mappings            |
| Elastic IP           | localhost:8090                  |
| SSH to EC2           | ssh local-cloud                 |
| User Data script     | docker/entrypoint.sh            |
| EBS Volume           | Docker volume mount             |

## Quick Start (Docker Compose)

### Prerequisites
- Docker
- Docker Compose
- SSH client

### Steps

    git clone https://github.com/itsepehrmi/local-cloud.git
    cd local-cloud
    ./scripts/generate-keys.sh
    docker-compose up -d --build
    docker-compose logs -f

### Access

- **Web**: http://localhost:8090
- **SSH**: ssh -p 2222 deploy@localhost -i ./ssh/id_ec2

## Quick Start (Kubernetes with Kind)

### Prerequisites
- Docker
- Kind
- kubectl
- Ingress-Nginx Controller installed on the cluster

### Steps

1. Build the Flask image:

       docker build -t my-flask-app:v1 -f Dockerfile.flask .

2. Load the image into Kind:

       kind load docker-image my-flask-app:v1 --name my-cluster

3. Apply Kubernetes manifests:

       kubectl apply -f flask-deployment.yaml
       kubectl apply -f flask-service.yaml
       kubectl apply -f local-cloud-ingress.yaml

4. Test the application:

       kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8888:80
       curl -H "Host: local-cloud.local" http://localhost:8888

## API Endpoints

| Endpoint   | Description                          |
|------------|--------------------------------------|
| /          | Welcome message with hostname        |
| /health    | Health check (returns 200 if OK)     |
| /info      | Application and environment info     |

## Project Structure

    local-cloud/
    |-- app/                    # Flask application
    |-- docker/                 # Docker configuration
    |-- nginx/                  # Nginx configuration
    |-- ssh/                    # SSH keys and config
    |-- Dockerfile.flask        # Flask app image for K8s
    |-- flask-deployment.yaml   # K8s Deployment
    |-- flask-service.yaml      # K8s Service
    |-- local-cloud-ingress.yaml # K8s Ingress rules
    |-- docker-compose.yml
    |-- README.md

## License

MIT
