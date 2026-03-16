COPY fact_stories
FROM 's3://hn-data-lake/gold/story_metrics/'
IAM_ROLE 'arn:aws:iam::account:role/redshiftRole'
FORMAT AS PARQUET;