# Decisions

Each decision should use this format:

```YYYY-MM-DD — Short title — Decision: <one-line decision>. Status: <Approved|Proposed>. Rationale: <one-line>.```

- 2026-02-09 — Adopt S3, Redshift, EC2 — Decision: Use S3 for storage; Redshift for analytics; EC2 for Airflow. Status: Approved. Rationale: S3 is durable; Redshift is columnar and scalable; EC2 provides flexible docker backend. 

- 2026-02-10 — Use Glue Catalog for metadata — Decision: Use AWS Glue Catalog to manage metadata. Status: Approved. Rationale: Glue Catalog integrates well with Redshift and Athena, simplifying schema management.

- 2026-02-26 — Refactor S3 data lake structure — Decision: Refactor S3 data lake to use Medallion architecture (Bronze, Silver, Gold). Status: Approved. Rationale: Medalion architecture improves data quality and organization, facilitating better analytics and governance.