CREATE TABLE fact_stories (
    story_id BIGINT,
    author_id INT,
    time_id INT,
    score INT,
    comment_count INT,
    rank_daily INT
)
DISTKEY(story_id)
SORTKEY(time_id);