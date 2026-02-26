# Technical Backlog (Portfolio Milestones, Detailed)

Aligned to architecture: `hackernews api -> airflow worker -> s3 (raw) -> glue catalog -> athena -> redshift`.

Each task is tagged as `required` or `optional`.

**Global Definition of Done**
- Everything is reproducible with Terraform.
- Each component has a minimal smoke test.
- Secrets stored in SSM Parameter Store.
- Data storage follows `raw/`, `config/` (curated is optional).

## Milestone 0: Project Scaffold
**Goal:** Make the repo legible and runnable from day one.

**Entry criteria**
- None.

**Tasks**
- [x] (`required`) Create a top-level `README.md` with goal, architecture diagram, and current status.
- [ ] (`required`) Add `.env.example` with required env vars and short descriptions.
- [x] (`required`) Add `Makefile` or `task` runner for: `init`, `plan`, `apply`, `destroy`, `lint`, `test`.
- [x] (`required`) Add `.gitignore` for Terraform, Python, Docker artifacts, logs, and local secrets.
- [~] (`required`) Decide and document AWS region and naming conventions.
- [~] (`optional`) Add `docs/` structure: `architecture.md`, `runbook.md`, `decisions.md`.
- [~] (`optional`) Add a minimal architecture diagram (draw.io or Mermaid).
- [ ] (`optional`) Add a `scripts/` folder for helper CLI scripts.

**Exit criteria**
- A new contributor can run the documented bootstrap steps without guesswork.

**Move to next milestone when**
- Repo has a clean onboarding path and the region choice is documented.

## Milestone 1: Core Infrastructure
**Goal:** Minimal AWS foundation with low-cost defaults.

**Entry criteria**
- Milestone 0 exit criteria met.

**Tasks**
- [ ] (`required`) Initialize Terraform backend (S3 + DynamoDB lock).
- [x] (`required`) Create base IAM roles for Terraform and runtime services.
- [x] (`required`) Create VPC with public/private subnets and NAT (minimal setup).
- [x] (`required`) Create security groups for EC2, Airflow, and Redshift.
- [x] (`required`) Create S3 buckets: `raw`, `config` with lifecycle rules.
- [x] (`required`) Add SSM Parameter Store path for secrets: `/hackernews-etl/*`.
- [ ] (`required`) Add outputs for bucket names, VPC, subnets, SG IDs.
- [~] (`optional`) Add VPC endpoints for S3/SSM to reduce NAT usage.
- [~] (`optional`) Enable S3 bucket encryption and versioning.
- [ ] (`optional`) Enforce S3 block public access and bucket policies.
- [ ] (`optional`) Add cost budget alarms to prevent surprises.
- [ ] (`optional`) Add standardized tagging (owner, env, project).

**Exit criteria**
- `terraform apply` creates all baseline resources and outputs key IDs.

**Move to next milestone when**
- You can `plan/apply/destroy` without manual console steps.

## Milestone 2: Data Contract (Raw)
**Goal:** Stable S3 layout and schema expectations for raw data.

**Entry criteria**
- Milestone 1 exit criteria met.

**Tasks**
- [ ] (`required`) Define S3 raw path conventions.
- [ ] (`required`) Create schema definitions for raw HN items.
- [ ] (`required`) Add a `config` folder in S3 for extraction settings.
- [ ] (`required`) Define partition strategy (date, item type, source).
- [ ] (`optional`) Add schema validation contracts (JSON Schema / Pydantic).
- [ ] (`optional`) Add data quality rules document (nullability, unique keys).

**Exit criteria**
- A written raw data contract exists and paths are created.

**Move to next milestone when**
- Raw layout is agreed and documented.

## Milestone 3: Batch Ingestion (HN API)
**Goal:** Pull raw HN data into S3 on demand.

**Entry criteria**
- Milestone 2 exit criteria met.

**Tasks**
- [~] (`required`) Implement HN API extractor (Python) with pagination and retries.
- [x] (`required`) Store raw JSON to S3.
- [ ] (`required`) Add idempotency logic (checkpoint by max item ID or timestamp).
- [ ] (`required`) Add a simple CLI entrypoint for local runs.
- [ ] (`required`) Add a smoke test: fetch 10 items and upload to S3.
- [ ] (`optional`) Add incremental backfill mode (range-based).
- [ ] (`optional`) Add structured logging and request timing metrics.
- [ ] (`optional`) Add rate-limit handling with exponential backoff.

**Exit criteria**
- Local run uploads data to S3 and passes smoke test.

**Move to next milestone when**
- Raw data appears in S3 with expected layout.

## Milestone 4: Orchestration (Airflow on EC2)
**Goal:** Schedule and run ingestion in production-like environment.

**Entry criteria**
- Milestone 3 exit criteria met.

**Tasks**
- [ ] (`required`) Provision EC2 instance with Docker and Docker Compose.
- [ ] (`required`) Deploy Airflow stack: webserver, scheduler, worker, redis, postgres.
- [ ] (`required`) Configure Airflow metadata DB and admin user.
- [ ] (`required`) Configure logs to S3 or local volume with retention.
- [ ] (`required`) Lock down Airflow UI with SG and optional basic auth.
- [ ] (`required`) Create a basic DAG to call the extractor.
- [ ] (`optional`) Add DAG retries and alerting callbacks.
- [ ] (`optional`) Add a dedicated service account/role for Airflow tasks.
- [ ] (`optional`) Add Airflow variables for bucket and prefixes.

**Exit criteria**
- DAG runs on schedule and loads raw data to S3.

**Move to next milestone when**
- Airflow is stable for 2 consecutive scheduled runs.

## Milestone 5: Glue Catalog & Athena
**Goal:** Enable serverless exploration for portfolio demos.

**Entry criteria**
- Milestone 4 exit criteria met.

**Tasks**
- [ ] (`required`) Create Glue database for HN datasets.
- [ ] (`required`) Create Glue tables for raw data.
- [ ] (`required`) Add a sample Athena query to validate raw data.
- [ ] (`optional`) Add partition projection for faster query discovery.
- [ ] (`optional`) Add a saved Athena query for demo.
- [ ] (`optional`) Add data lineage notes in `docs/architecture.md`.

**Exit criteria**
- Athena query returns expected results on raw dataset.

**Move to next milestone when**
- Query and output are captured in README or demo notes.

## Milestone 6: Analytics Warehouse (Redshift)
**Goal:** Show warehouse integration for full-stack data pipeline.

**Entry criteria**
- Milestone 5 exit criteria met.

**Tasks**
- [ ] (`required`) Provision Redshift (serverless or small cluster).
- [ ] (`required`) Create schema and target tables for raw or curated data.
- [ ] (`required`) Implement load from S3 to Redshift (COPY or Spectrum).
- [ ] (`required`) Add a sample analytic query and store results.
- [ ] (`optional`) Add staging tables and simple upsert strategy.
- [ ] (`optional`) Add a materialized view for trending stories.

**Exit criteria**
- Redshift query returns expected results using loaded data.

**Move to next milestone when**
- Warehouse results are captured in README or demo notes.

## Milestone 7: Optional Curated Layer
**Goal:** Convert raw data into analytics-ready parquet (if you want a richer demo).

**Entry criteria**
- Milestone 4 exit criteria met.

**Tasks**
- [ ] (`optional`) Define curated table models (e.g., `items`, `stories`, `comments`).
- [ ] (`optional`) Implement transformations from raw to curated (Python or SQL).
- [ ] (`optional`) Store curated data as parquet in S3 `curated/hn/`.
- [ ] (`optional`) Add a validation step (row counts, required fields).
- [ ] (`optional`) Add deduplication and late-arriving data handling.
- [ ] (`optional`) Update Glue tables to include curated datasets.

**Exit criteria**
- Curated parquet appears in S3 with validation results.

**Move to next milestone when**
- Validation passes on 2 consecutive runs.

## Milestone 8: Observability & Alerts
**Goal:** Demonstrate operational readiness.

**Entry criteria**
- Milestone 6 exit criteria met.

**Tasks**
- [ ] (`required`) Set CloudWatch metrics and logs for EC2 and Airflow.
- [ ] (`required`) Add basic alerting (failed DAG runs, EC2 health).
- [ ] (`required`) Create a small runbook for recovery steps.
- [ ] (`optional`) Add log-based alert for DAG duration spikes.
- [ ] (`optional`) Add cost anomaly alerts.
- [ ] (`optional`) Add audit logging for S3 and IAM (CloudTrail).

**Exit criteria**
- Alerts fire on a simulated failure.

**Move to next milestone when**
- Observability is documented and verified.

## Milestone 9: CI/CD (Minimal)
**Goal:** Add quality gates and safe deploy workflow.

**Entry criteria**
- Milestone 8 exit criteria met.

**Tasks**
- [ ] (`required`) Add GitHub Actions for lint/test and Terraform `plan` on PRs.
- [ ] (`required`) Add a manual release workflow for Terraform `apply`.
- [ ] (`optional`) Add format/lint checks for Terraform and Python.
- [ ] (`optional`) Add scheduled pipeline test workflow (nightly).
- [ ] (`optional`) Add a small security scan (Trivy or tfsec).

**Exit criteria**
- CI runs on PR and a manual apply workflow exists.

**Move to next milestone when**
- A sample PR passes CI and plan output is visible.

## Milestone 10: Documentation & Showcase
**Goal:** Portfolio-ready documentation and teardown guidance.

**Entry criteria**
- Milestone 9 exit criteria met.

**Tasks**
- [ ] (`required`) Update `README.md` with current architecture and usage.
- [ ] (`required`) Document how to run end-to-end: local, Airflow, and AWS.
- [ ] (`required`) Document teardown procedure to avoid cost leaks.
- [ ] (`required`) Capture screenshots or sample outputs for demo.
- [ ] (`optional`) Add a short demo video or GIF.
- [ ] (`optional`) Add a "lessons learned" section.

**Exit criteria**
- README is demo-ready with screenshots or sample outputs.

**Move to next milestone when**
- You can share the repo and a reviewer can follow the demo.


## Milestone 11: Security
**Goal:** Hardening security.

**Entry criteria**
- Milestone 10 exit criteria met.

**Tasks**
- [ ] (`required`) create trusted entity for cli user assume role.
- [ ] (`required`) reduce terraform permissions to least privilege for aws management.


**Exit criteria**

**Move to next milestone when**
