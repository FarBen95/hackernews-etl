CREATE TABLE dim_author (
    author_id INT IDENTITY(1,1),
    author_name VARCHAR(200),
    first_seen TIMESTAMP
)
DISTSTYLE ALL;