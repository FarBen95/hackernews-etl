#!/bin/bash
set -euo pipefail
exec > /var/log/init-script.log 2>&1

S3_DOCKER_PATH="${s3_docker_path}"
S3_DAGS_PATH="${s3_dags_path}"
SSM_ENV_PARAM="${ssm_env_param}"
WORKDIR=/opt/app

dnf update -y
# Install docker, pip and jq
dnf install -y docker
# Try installing docker compose plugin for 'docker compose' support
dnf install -y docker-compose-plugin

# Install awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Start docker
systemctl enable --now docker

# Add common users to docker group
usermod -aG docker ec2-user

mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Fetch Dockerfile, docker-compose.yaml, requirements.txt from S3
aws s3 cp $S3_DOCKER_PATH . --recursive

# Fetch .env from SSM Parameter Store
aws ssm get-parameter --name "$SSM_ENV_PARAM" --with-decryption --query "Parameter.Value" --output text > .env

# use docker compose plugin
docker compose up -d

# Create DAG sync script that syncs from S3 to the instance
cat > /usr/local/bin/sync-dags.sh <<EOF
#!/bin/bash
set -euo pipefail
S3_DAGS_PATH="${S3_DAGS_PATH}"
TARGET_DIR="/opt/app/dags"
mkdir -p "$TARGET_DIR"
chown ec2-user:ec2-user "$TARGET_DIR" || true
aws s3 sync "$S3_DAGS_PATH" "$TARGET_DIR" --delete
EOF
chmod +x /usr/local/bin/sync-dags.sh

# Create systemd service for DAG sync
cat > /etc/systemd/system/sync-dags.service <<EOF
[Unit]
Description=Sync DAGs from S3

[Service]
Type=oneshot
ExecStart=/usr/local/bin/sync-dags.sh
EOF

# Create systemd timer to run the DAG sync periodically
cat > /etc/systemd/system/sync-dags.timer <<EOF
[Unit]
Description=Run sync-dags every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5m
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now sync-dags.timer

