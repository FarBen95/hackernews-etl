# HackerNews Data Engineering Pipeline

A data engineering ETL project that extracts, transforms, and loads HackerNews data using Apache Airflow orchestration.

## Overview

This project implements a data pipeline to collect and process data from HackerNews using Apache Airflow with a Celery executor for distributed task processing.

## Architecture

The project uses a dockerized Apache Airflow setup with the following components:

- **Apache Airflow 3.1.1** - Workflow orchestration
- **PostgreSQL 17.5** - Metadata and data storage
- **Redis 8.2.2** - Message broker for Celery
- **Celery** - Distributed task execution
- **Python 3.12** - Runtime environment

### Services

- `airflow-apiserver` - Web UI and REST API (port 8080)
- `airflow-scheduler` - Task scheduling
- `airflow-dag-processor` - DAG parsing and processing
- `airflow-worker` - Celery workers for task execution
- `airflow-triggerer` - Event-based trigger handling
- `flower` - Celery monitoring (port 5555, debug profile)
- `postgres` - Database backend
- `redis` - Message queue

## Prerequisites

- Docker
- Docker Compose
- At least 4GB of available RAM

## Project Structure

```
de-hackernews/
├── dags/                    # Airflow DAG definitions
├── config/                 # Airflow configuration files
├── docker-compose.yaml     # Docker services definition
├── Dockerfile              # Custom Airflow image
├── requirements.txt        # Python dependencies
└── .env                    # Environment variables
```

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd de-hackernews
   ```

2. **Configure environment variables**
   
   The project uses environment variables defined in `.env` file. Default values are already set for local development:
   - PostgreSQL credentials
   - Airflow admin username/password
   - Airflow UID (set to 1000)

3. **Build the custom Airflow image**
   ```bash
   docker build -t custom-airflow:3.1.1-python3.12 .
   ```

4. **Initialize Airflow**
   ```bash
   docker-compose up airflow-init
   ```

5. **Start all services**
   ```bash
   docker-compose up -d
   ```

## Usage

### Accessing the Airflow UI

1. Open your browser and navigate to `http://localhost:8080`
2. Login with default credentials:
   - Username: `airflow`
   - Password: `airflow`

### Monitoring with Flower (Optional)

To enable Celery monitoring with Flower:

```bash
docker-compose --profile debug up -d flower
```

Access Flower at `http://localhost:5555`

### Running DAGs

1. Navigate to the Airflow UI
2. Find your DAG in the list
3. Toggle the DAG to "On"
4. Trigger manually or wait for scheduled runs

### Viewing Logs

Logs are stored in the `logs/` directory and are also accessible through the Airflow UI.

## Development

### Adding New DAGs

1. Create a new Python file in the `dags/` directory
2. Define your DAG using Airflow's DAG API
3. Airflow will automatically detect and load the new DAG

### Adding Dependencies

1. Add the package to `requirements.txt`
2. Rebuild the Docker image:
   ```bash
   docker build -t custom-airflow:3.1.1-python3.12 .
   ```
3. Restart services:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### CLI Access

To run Airflow CLI commands:

```bash
docker-compose run --rm airflow-cli <command>
```

Or use the debug profile for an interactive shell:

```bash
docker-compose --profile debug run --rm airflow-cli bash
```

## Stopping Services

```bash
docker-compose down
```

To remove volumes (including database data):

```bash
docker-compose down -v
```

## Troubleshooting

### Services won't start

1. Check Docker logs:
   ```bash
   docker-compose logs
   ```

2. Ensure ports 8080 and 5432 are not already in use

3. Verify you have enough disk space and memory

### DAGs not appearing

1. Check for Python syntax errors in DAG files
2. Review logs in `logs/` directory
3. Ensure DAG files are in the `dags/` directory

### Permission issues

If you encounter permission issues with volumes:

```bash
echo "AIRFLOW_UID=$(id -u)" > .env
docker-compose down
docker-compose up -d
```

## Configuration

Airflow configuration can be customized by:
1. Setting environment variables in the `.env` file
2. Placing custom `airflow.cfg` in the `config/` directory
3. Using Airflow's UI Admin > Configuration menu

## Security Notes

- Default credentials are set for development only
- Change default passwords in production
- The `secrets/` directory is gitignored for sensitive data
- Never commit `.env` files with production credentials

## License

[Add your license here]

## Contributing

[Add contribution guidelines here]

## Contact

[Add contact information here]
