# AI Maintenance Assistant - DevOps Infrastructure

---

## 1. System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PRODUCTION ENVIRONMENT                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              CDN (Cloudflare)                               │
│                         Static Assets + SSL/TLS                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           LOAD BALANCER (Nginx)                             │
│                    ┌─────────────┬─────────────┬─────────────┐             │
│                    │   Port 80   │  Port 443   │  Port 8080  │             │
│                    │   HTTP      │  HTTPS      │  Admin       │             │
│                    └─────────────┴─────────────┴─────────────┘             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DOCKER CONTAINERS                                │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│  │   FastAPI App   │  │   FastAPI App   │  │   FastAPI App   │            │
│  │   (Replica 1)   │  │   (Replica 2)   │  │   (Replica 3)   │            │
│  │   Port: 8000    │  │   Port: 8000    │  │   Port: 8000    │            │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘            │
│           │                    │                    │                       │
│           └────────────────────┼────────────────────┘                       │
│                                │                                            │
│  ┌─────────────────┐  ┌────────┴────────┐  ┌─────────────────┐            │
│  │     Redis       │  │   PostgreSQL    │  │   MinIO         │            │
│  │   (Cache)       │  │   (Database)    │  │   (File Store)  │            │
│  │   Port: 6379    │  │   Port: 5432    │  │   Port: 9000    │            │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Monitoring    │  │     Logging     │  │    Backups      │
│  (Prometheus)   │  │     (Loki)      │  │   (Velero)      │
│  Port: 9090     │  │   Port: 3100    │  │   Daily         │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

---

## 2. Docker Configuration

### 2.1 Docker Compose (Production)

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  # Nginx Load Balancer
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - api
    networks:
      - frontend
    restart: always
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

  # FastAPI Application
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    environment:
      - DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@postgres:5432/aimaintenance
      - REDIS_URL=redis://redis:6379/0
      - JWT_SECRET_KEY=${JWT_SECRET_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - MINIO_ENDPOINT=minio:9000
      - MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}
      - MINIO_SECRET_KEY=${MINIO_SECRET_KEY}
    depends_on:
      - postgres
      - redis
      - minio
    networks:
      - frontend
      - backend
    restart: always
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=aimaintenance
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./postgres/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    networks:
      - backend
    restart: always
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis Cache
  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes --maxmemory 1gb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    networks:
      - backend
    restart: always
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 1G
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # MinIO Object Storage
  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    environment:
      - MINIO_ROOT_USER=${MINIO_ACCESS_KEY}
      - MINIO_ROOT_PASSWORD=${MINIO_SECRET_KEY}
    volumes:
      - minio_data:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    networks:
      - backend
    restart: always
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 2G

  # Prometheus Monitoring
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - monitoring
    restart: always

  # Grafana Dashboard
  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/var/lib/grafana/dashboards
    ports:
      - "3000:3000"
    networks:
      - monitoring
    restart: always

  # Loki Log Aggregation
  loki:
    image: grafana/loki:latest
    volumes:
      - ./monitoring/loki.yml:/etc/loki/local-config.yaml
      - loki_data:/loki
    ports:
      - "3100:3100"
    networks:
      - monitoring
    restart: always

volumes:
  postgres_data:
  redis_data:
  minio_data:
  prometheus_data:
  grafana_data:
  loki_data:

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
  monitoring:
    driver: bridge
```

### 2.2 Dockerfile (FastAPI)

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

---

## 3. Nginx Configuration

### 3.1 Nginx Config

```nginx
# nginx/nginx.conf
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;

    # Performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Gzip
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript;

    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

    # Upstream
    upstream api_backend {
        least_conn;
        server api:8000;
        keepalive 32;
    }

    # HTTP Server
    server {
        listen 80;
        server_name api.aimaintenance.com;

        # Redirect to HTTPS
        return 301 https://$server_name$request_uri;
    }

    # HTTPS Server
    server {
        listen 443 ssl http2;
        server_name api.aimaintenance.com;

        # SSL
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # Security Headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # API Routes
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            
            proxy_pass http://api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_connect_timeout 30s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # Health Check
        location /health {
            proxy_pass http://api_backend/health;
            access_log off;
        }

        # File Upload
        location /upload {
            client_max_body_size 10M;
            proxy_pass http://api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

---

## 4. Deployment Strategy

### 4.1 Deployment Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DEPLOYMENT PIPELINE                                │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Developer  │
│  Push Code  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   GitHub    │
│   Actions   │
└──────┬──────┘
       │
       ├─────────────────────────────────────────────────┐
       │                                                 │
       ▼                                                 ▼
┌─────────────┐                                   ┌─────────────┐
│    Test     │                                   │   Build     │
│   (Unit/    │                                   │   Docker    │
│ Integration)│                                   │   Image     │
└──────┬──────┘                                   └──────┬──────┘
       │                                                 │
       │ Pass?                                           │
       ├──── Yes ────────────────────────────────────────┤
       │                                                 │
       │                                                 ▼
       │                                          ┌─────────────┐
       │                                          │    Push     │
       │                                          │    to       │
       │                                          │  Docker Hub │
       │                                          └──────┬──────┘
       │                                                 │
       │                                                 ▼
       │                                          ┌─────────────┐
       │                                          │   Deploy    │
       │                                          │  Staging    │
       │                                          └──────┬──────┘
       │                                                 │
       │                                                 │ Test?
       │                                                 ├──── Pass ──┐
       │                                                 │            │
       │                                                 │            ▼
       │                                                 │     ┌─────────────┐
       │                                                 │     │   Deploy    │
       │                                                 │     │ Production  │
       │                                                 │     │  (Manual)   │
       │                                                 │     └──────┬──────┘
       │                                                 │            │
       │ Fail?                                           │            ▼
       ├──── No ────────────────────────────────────────┤     ┌─────────────┐
       │                                                 │     │  Verify     │
       │                                                 │     │  + Monitor  │
       ▼                                                 │     └─────────────┘
┌─────────────┐                                          │
│   Notify    │◀─────────────────────────────────────────┘
│  (Slack)    │
└─────────────┘
```

### 4.2 GitHub Actions CI/CD

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # Test Job
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: test_db
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: test_password
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest pytest-cov

      - name: Run tests
        env:
          DATABASE_URL: postgresql://postgres:test_password@localhost:5432/test_db
          REDIS_URL: redis://localhost:6379/0
        run: |
          pytest tests/ -v --cov=app --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml

  # Build Job
  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha
            type=ref,event=branch
            type=semver,pattern={{version}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # Deploy to Staging
  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - name: Deploy to Staging
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.STAGING_HOST }}
          username: ${{ secrets.STAGING_USER }}
          key: ${{ secrets.STAGING_SSH_KEY }}
          script: |
            cd /opt/aimaintenance
            docker-compose -f docker-compose.staging.yml pull
            docker-compose -f docker-compose.staging.yml up -d
            docker system prune -f

  # Deploy to Production (Manual)
  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - name: Deploy to Production
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.PRODUCTION_HOST }}
          username: ${{ secrets.PRODUCTION_USER }}
          key: ${{ secrets.PRODUCTION_SSH_KEY }}
          script: |
            cd /opt/aimaintenance
            docker-compose -f docker-compose.prod.yml pull
            docker-compose -f docker-compose.prod.yml up -d --remove-orphans
            docker system prune -f
            # Run migrations
            docker exec api alembic upgrade head
```

---

## 5. Backup Strategy

### 5.1 Backup Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BACKUP ARCHITECTURE                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐
│   PostgreSQL    │
│   Database      │
└────────┬────────┘
         │
         │ pg_dump
         ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Local Backup  │────▶│  Remote Backup  │────▶│  Cloud Backup   │
│   /backups/db/  │     │  (NAS/S3)       │     │  (AWS S3)       │
│   Daily         │     │  Weekly         │     │  Monthly        │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                    │
                                    │
┌─────────────────┐                 │
│   MinIO Files   │─────────────────┤
│   (Uploads)     │                 │
└─────────────────┘                 │
                                    │
┌─────────────────┐                 │
│   Redis Data    │─────────────────┤
│   (Cache)       │                 │
└─────────────────┘                 │
                                    ▼
                         ┌─────────────────┐
                         │   Backup        │
                         │   Notification  │
                         │   (Slack/Email) │
                         └─────────────────┘
```

### 5.2 Backup Script

```bash
#!/bin/bash
# scripts/backup.sh

set -e

# Configuration
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30
S3_BUCKET="aimaintenance-backups"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Create backup directory
mkdir -p ${BACKUP_DIR}/{db,files,redis}

# PostgreSQL Backup
log "Starting PostgreSQL backup..."
docker exec postgres pg_dump -U postgres aimaintenance | gzip > ${BACKUP_DIR}/db/aimaintenance_${DATE}.sql.gz

if [ $? -eq 0 ]; then
    log "PostgreSQL backup completed: ${BACKUP_DIR}/db/aimaintenance_${DATE}.sql.gz"
else
    error "PostgreSQL backup failed"
fi

# MinIO Files Backup
log "Starting MinIO files backup..."
docker exec minio tar -czf - /data > ${BACKUP_DIR}/files/minio_${DATE}.tar.gz

if [ $? -eq 0 ]; then
    log "MinIO backup completed: ${BACKUP_DIR}/files/minio_${DATE}.tar.gz"
else
    error "MinIO backup failed"
fi

# Redis Backup
log "Starting Redis backup..."
docker exec redis redis-cli BGSAVE
sleep 5
docker cp redis:/data/dump.rdb ${BACKUP_DIR}/redis/dump_${DATE}.rdb

if [ $? -eq 0 ]; then
    log "Redis backup completed"
else
    error "Redis backup failed"
fi

# Upload to S3
log "Uploading backups to S3..."
aws s3 sync ${BACKUP_DIR}/ s3://${S3_BUCKET}/backup_${DATE}/ \
    --storage-class STANDARD_IA \
    --sse AES256

if [ $? -eq 0 ]; then
    log "S3 upload completed"
else
    error "S3 upload failed"
fi

# Cleanup old backups
log "Cleaning up old backups..."
find ${BACKUP_DIR}/db -name "*.sql.gz" -mtime +${RETENTION_DAYS} -delete
find ${BACKUP_DIR}/files -name "*.tar.gz" -mtime +${RETENTION_DAYS} -delete
find ${BACKUP_DIR}/redis -name "*.rdb" -mtime +${RETENTION_DAYS} -delete

# Upload retention on S3
aws s3 ls s3://${S3_BUCKET}/ | while read -r line; do
    createDate=$(echo $line | awk '{print $1" "$2}')
    createDate=$(date -d "$createDate" +%s)
    olderDate=$(date -d "-${RETENTION_DAYS} days" +%s)
    if [[ $createDate -lt $olderDate ]]; then
        fileName=$(echo $line | awk '{print $4}')
        if [ ! -z "$fileName" ]; then
            aws s3 rm s3://${S3_BUCKET}/$fileName --recursive
        fi
    fi
done

log "Backup process completed successfully!"
```

### 5.3 Cron Schedule

```bash
# /etc/crontab

# Daily backup at 2:00 AM
0 2 * * * /opt/aimaintenance/scripts/backup.sh >> /var/log/backup.log 2>&1

# Weekly cleanup at 3:00 AM Sunday
0 3 * * 0 /opt/aimaintenance/scripts/cleanup.sh >> /var/log/cleanup.log 2>&1

# Monthly backup verification
0 4 1 * * /opt/aimaintenance/scripts/verify-backup.sh >> /var/log/verify.log 2>&1
```

---

## 6. Monitoring Architecture

### 6.1 Monitoring Stack

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MONITORING ARCHITECTURE                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   FastAPI App   │     │   PostgreSQL    │     │   Redis         │
│   /metrics      │     │   Exporter      │     │   Exporter      │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                                 ▼
                         ┌─────────────────┐
                         │   Prometheus    │
                         │   (Metrics)     │
                         │   Port: 9090    │
                         └────────┬────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
                    ▼             ▼             ▼
           ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
           │   Grafana   │ │  AlertManager│ │   Loki      │
           │  (Dashboard)│ │  (Alerts)    │ │  (Logs)     │
           │  Port: 3000 │ │  Port: 9093  │ │  Port: 3100 │
           └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
                  │               │               │
                  │               ▼               │
                  │        ┌─────────────┐        │
                  │        │   Slack     │        │
                  │        │  (Notify)   │        │
                  │        └─────────────┘        │
                  │                               │
                  ▼                               ▼
           ┌─────────────┐                ┌─────────────┐
           │  Grafana    │                │  Grafana    │
           │  Dashboard  │                │  Explore    │
           └─────────────┘                └─────────────┘
```

### 6.2 Prometheus Configuration

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'fastapi'
    static_configs:
      - targets: ['api:8000']
    metrics_path: '/metrics'

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:9113']

  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']

rule_files:
  - 'alerts.yml'

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

### 6.3 Alert Rules

```yaml
# monitoring/alerts.yml
groups:
  - name: application_alerts
    rules:
      # High Error Rate
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} per second"

      # High Response Time
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time"
          description: "95th percentile response time is {{ $value }}s"

      # Service Down
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "{{ $labels.instance }} has been down for more than 1 minute"

      # High Memory Usage
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value | humanizePercentage }}"

      # High CPU Usage
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is {{ $value }}%"

      # Database Connection Pool
      - alert: HighDBConnections
        expr: pg_stat_activity_count > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High database connections"
          description: "Active connections: {{ $value }}"

      # Disk Space
      - alert: LowDiskSpace
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) < 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space"
          description: "Disk space is {{ $value | humanizePercentage }} free"

  - name: backup_alerts
    rules:
      # Backup Failed
      - alert: BackupFailed
        expr: backup_last_status != 1
        for: 1h
        labels:
          severity: critical
        annotations:
          summary: "Backup failed"
          description: "Last backup was not successful"

      # Backup Too Old
      - alert: BackupTooOld
        expr: time() - backup_last_success_timestamp_seconds > 86400
        for: 1h
        labels:
          severity: warning
        annotations:
          summary: "Backup is too old"
          description: "Last successful backup was {{ $value | humanizeDuration }} ago"
```

---

## 7. Grafana Dashboards

### 7.1 Application Dashboard

```json
{
  "dashboard": {
    "title": "AI Maintenance Assistant",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{status}}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "singlestat",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~'5..'}[5m]) / rate(http_requests_total[5m]) * 100",
            "legendFormat": "Error %"
          }
        ]
      },
      {
        "title": "Active Users",
        "type": "singlestat",
        "targets": [
          {
            "expr": "active_users_total",
            "legendFormat": "Users"
          }
        ]
      },
      {
        "title": "AI Analysis Count",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(ai_analysis_total[5m])",
            "legendFormat": "Analysis/sec"
          }
        ]
      },
      {
        "title": "AI Accuracy",
        "type": "singlestat",
        "targets": [
          {
            "expr": "ai_feedback_helpful_total / ai_feedback_total * 100",
            "legendFormat": "Accuracy %"
          }
        ]
      }
    ]
  }
}
```

---

## 8. Logging Architecture

### 8.1 Logging Stack

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          LOGGING ARCHITECTURE                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   FastAPI App   │     │   PostgreSQL    │     │   Nginx         │
│   (stdout)      │     │   (log)         │     │   (access.log)  │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PROMTAIL (Log Shipper)                           │
│                     Collects logs from all containers                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────┐
│      LOKI       │
│  (Log Storage)  │
│  Port: 3100     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    GRAFANA      │
│   (Explore)     │
│  Port: 3000     │
└─────────────────┘
```

### 8.2 Promtail Configuration

```yaml
# monitoring/promtail.yml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: fastapi
    static_configs:
      - targets:
          - localhost
        labels:
          job: fastapi
          __path__: /var/log/containers/*api*.log

  - job_name: postgres
    static_configs:
      - targets:
          - localhost
        labels:
          job: postgres
          __path__: /var/log/containers/*postgres*.log

  - job_name: nginx
    static_configs:
      - targets:
          - localhost
        labels:
          job: nginx
          __path__: /var/log/containers/*nginx*.log
```

---

## 9. Security

### 9.1 Security Checklist

| Category | Item | Status |
|----------|------|--------|
| Network | Firewall enabled | ✓ |
| Network | Only ports 80, 443 open | ✓ |
| Network | Internal ports not exposed | ✓ |
| SSL | Valid SSL certificate | ✓ |
| SSL | TLS 1.2+ only | ✓ |
| Auth | JWT token expiration | ✓ |
| Auth | Password hashing (bcrypt) | ✓ |
| Auth | Rate limiting enabled | ✓ |
| Data | Database encryption at rest | ✓ |
| Data | Backup encryption | ✓ |
| Container | Non-root user | ✓ |
| Container | Read-only filesystem | ✓ |
| Container | No privileged mode | ✓ |
| Secrets | No secrets in code | ✓ |
| Secrets | Docker secrets used | ✓ |

### 9.2 Docker Security

```yaml
# docker-compose.prod.yml (security options)
services:
  api:
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
```

---

## 10. Disaster Recovery

### 10.1 Recovery Procedures

| Scenario | RTO | RPO | Procedure |
|----------|-----|-----|-----------|
| App Crash | 5 min | 0 | Auto-restart by Docker |
| Database Corruption | 1 hour | 1 hour | Restore from backup |
| Server Failure | 4 hours | 1 hour | Restore to new server |
| Full Data Loss | 8 hours | 24 hours | Restore from S3 backup |

### 10.2 Recovery Steps

```bash
# Database Recovery
docker exec postgres pg_restore -U postgres -d aimaintenance /backups/db/latest.sql

# Full System Recovery
1. Provision new server
2. Install Docker
3. Clone repository
4. Restore backups from S3
5. Start services
6. Verify functionality
```
