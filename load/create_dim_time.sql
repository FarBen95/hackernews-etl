CREATE TABLE dim_time (
    time_id INT,
    date DATE,
    day INT,
    month INT,
    year INT,
    weekday VARCHAR(10)
)
DISTSTYLE ALL;