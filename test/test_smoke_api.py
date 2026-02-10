import os
import sys

import pytest


# Make the `extract` directory importable and import the modules under test
ROOT = os.path.dirname(os.path.dirname(__file__))
EXTRACT_DIR = os.path.join(ROOT, "extract")
sys.path.insert(0, EXTRACT_DIR)

import hackernews_api


def test_hackernews_api_smoke_non_persistent():
    """Non-persistent end-to-end smoke test:

    - Fetches 10 top story IDs from the public HackerNews API
    - Picks one ID and fetches its details
    - Does not write any files to disk
    """

    # Fetch 10 top story ids; skip the test if network/API is unavailable
    try:
        ids = hackernews_api.fetch_top_stories_ids(limit=10)
    except Exception as exc:  # network / API errors -> skip smoke test
        pytest.skip(f"Skipping smoke test; API/network unavailable: {exc}")

    assert isinstance(ids, list) and len(ids) == 10

    # Pick the first story id and fetch details
    story_id = ids[0]
    try:
        details = hackernews_api.fetch_story_details(story_id)
    except Exception as exc:
        pytest.skip(f"Skipping smoke test; failed to fetch story details: {exc}")

    assert isinstance(details, dict)
    assert 'id' in details and int(details['id']) == int(story_id)
