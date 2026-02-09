# Decisions

Each decision should use this format:

```YYYY-MM-DD — Short title — Decision: <one-line decision>. Status: <Approved|Proposed>. Rationale: <one-line>.```

- 2026-02-09 — Adopt S3, Redshift, EC2 — Decision: Use S3 for storage; Redshift for analytics; EC2 for Airflow. Status: Approved. Rationale: S3 is durable; Redshift is columnar and scalable; EC2 provides flexible docker backend. 
