# src/script/utils.py
import os
import sys
from datetime import datetime

LOG_FILE = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "cache", "workflow.log")


def ensure_log_dir():
    """Ensure the log directory exists"""
    log_dir = os.path.dirname(LOG_FILE)
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)


def log(level, message):
    """Log a message to the log file"""
    ensure_log_dir()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, 'a', encoding='utf-8') as f:
        f.write(f"[{timestamp}] [{level}] {message}\n")


def log_info(message):
    """Log an info message"""
    log("INFO", message)


def log_error(message):
    """Log an error message"""
    log("ERROR", message)


def log_debug(message):
    """Log a debug message"""
    log("DEBUG", message)


def safe_get(dictionary, key, default=None):
    """Safely get a value from a dictionary"""
    try:
        return dictionary.get(key, default)
    except (AttributeError, TypeError):
        return default


def normalize_text(text):
    """Normalize text for searching"""
    if not text:
        return ""
    return str(text).strip().lower()


def create_alfred_item(uid, title, subtitle="", arg="", icon_path="", valid=True, **kwargs):
    """Create a standardized Alfred item dictionary"""
    item = {
        "uid": str(uid),
        "title": str(title),
        "subtitle": str(subtitle),
        "arg": str(arg),
        "valid": valid
    }

    if icon_path:
        item["icon"] = {"path": icon_path}

    item.update(kwargs)

    return item
