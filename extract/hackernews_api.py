import logging
import os
from typing import Dict, List, Any
import requests
import yaml

logger = logging.getLogger(__name__)

API_NAME = "hackernews"
REQUEST_TIMEOUT = 10  # seconds


def load_api_config(api_name: str) -> Dict[str, Any]:
    config_path = os.path.join(os.path.dirname(__file__), "api_config.yaml")
    try:
        with open(config_path, "r") as f:
            config = yaml.safe_load(f)
        if api_name not in config:
            raise KeyError(f"API '{api_name}' not found in config")
        logger.debug(f"Loaded config for {api_name}")
        return config[api_name]
    except FileNotFoundError:
        logger.error(f"Config file not found: {config_path}")
        raise
    except Exception as e:
        logger.error(f"Error loading config: {e}")
        raise


def fetch_top_stories_ids(limit: int = 10) -> List[int]:
    try:
        api_config = load_api_config(API_NAME)
        url = api_config['base_url'] + api_config['endpoints']['top_stories']
        response = requests.get(url, timeout=REQUEST_TIMEOUT)
        response.raise_for_status()
        logger.info(f"Fetched {limit} top story IDs")
        return response.json()[:limit]
    except requests.RequestException as e:
        logger.error(f"Failed to fetch top stories: {e}")
        raise


def fetch_story_details(story_id: int) -> Dict[str, Any]:
    try:
        api_config = load_api_config(API_NAME)
        url = api_config['base_url'] + api_config['endpoints']['item'].format(id=story_id)
        response = requests.get(url, timeout=REQUEST_TIMEOUT)
        response.raise_for_status()
        logger.debug(f"Fetched details for story {story_id}")
        return response.json()
    except requests.RequestException as e:
        logger.error(f"Failed to fetch story {story_id}: {e}")
        raise