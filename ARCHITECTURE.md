# Architecture Template

Use this as a standard architecture document for ETL projects. Replace placeholders with project-specific details.

## Summary
**Problem:**  
**Solution overview:**  
**Key constraints:**  

## Data Flow
```
<source> -> <ingestion> -> <raw> -> <transform> -> <curated> -> <warehouse> -> <consumers>
```

## Components
- **Sources:**  
- **Ingestion:**  
- **Orchestration:**  
- **Storage (raw):**  
- **Transformations:**  
- **Catalog / Metadata:**  
- **Query / BI:**  
- **Warehouse:**  

## Data Storage & Layout
- Raw:  
- Curated:  
- Serving:  
- Partitioning strategy:  
- Retention policy:  

## Security & Access
- Secrets management:  
- IAM and permissions:  
- Network boundaries:  
- PII handling:  

## Reliability & Scalability
- Failure modes:  
- Retry strategy:  
- Scaling approach:  
- Backfill approach:  

## Operational Notes
- Deployment model:  
- Infra provisioning:  
- Key assumptions:  
