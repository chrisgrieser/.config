#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
import os
import sys
from urllib.parse import quote_plus

# Add workflow directory to Python path so bundled modules can be found
WORKFLOW_DIR = os.environ.get("alfred_workflow_dir", os.getcwd())
SCRIPT_DIR = os.path.join(WORKFLOW_DIR, "script")

for path in [WORKFLOW_DIR, SCRIPT_DIR]:
    if path not in sys.path:
        sys.path.insert(0, path)

import utils

# Gmail search URL template
GMAIL_BASE_URL = "https://mail.google.com/mail/u/{account}/#search/{query}"

# Search type definitions: (prefix, label, description)
GENERAL_SEARCH_TYPES = [
    ("", "Search Gmail", "Search all messages in Gmail"),
    ("is:unread", "Search Unread", "Search only unread messages"),
    ("is:starred", "Search Starred", "Search starred messages"),
    ("in:sent", "Search Sent", "Search sent messages"),
    ("in:drafts", "Search Drafts", "Search draft messages"),
    ("is:important", "Search Important", "Search important messages"),
    ("in:spam", "Search Spam", "Search spam messages"),
    ("in:trash", "Search Trash", "Search trash messages"),
]

UNREAD_SEARCH_TYPES = [
    ("is:unread", "Search Unread Gmail", "Search all unread messages"),
    ("in:inbox is:unread", "Search Unread in Inbox", "Search unread messages in inbox"),
    ("is:unread is:important", "Search Unread Important", "Search unread important messages"),
    ("is:unread is:starred", "Search Unread Starred", "Search unread starred messages"),
]


def get_account():
    """Get the Gmail account index from environment variable"""
    return os.environ.get("userNumber") or os.environ.get("gmail_account", "0")


def build_gmail_url(query, prefix=""):
    """Build a Gmail search URL"""
    account = get_account()
    search_query = f"{prefix} {query}".strip() if prefix else query
    encoded_query = quote_plus(search_query)
    return GMAIL_BASE_URL.format(account=account, query=encoded_query)


def query_text(args):
    """Get query text from parsed args or environment fallbacks"""
    if args.query:
        return " ".join(args.query).strip()
    for key in ("alfred_query", "query"):
        v = os.environ.get(key)
        if v:
            return v.strip()
    try:
        if not sys.stdin.isatty():
            data = sys.stdin.read().strip()
            if data:
                return data
    except Exception:
        pass
    return ""


def build_search_items(query, unread_mode=False):
    """Build Alfred items for Gmail search.

    Args:
        query: The search query string.
        unread_mode: If True, return unread-focused search options.

    Returns:
        A list of Alfred item dictionaries.
    """
    search_types = UNREAD_SEARCH_TYPES if unread_mode else GENERAL_SEARCH_TYPES
    items = []

    for prefix, label, description in search_types:
        url = build_gmail_url(query, prefix)
        title = f"{label}: \"{query}\"" if query else label
        subtitle = f"{description}: \"{query}\"" if query else description

        item = {
            "uid": f"gmail-{prefix.replace(' ', '-') or 'all'}-{query}",
            "skipknowledge": True,
            "title": title,
            "subtitle": subtitle,
            "arg": url,
            "valid": True,
            "quicklookurl": url,
        }
        items.append(item)

    return items


def main():
    parser = argparse.ArgumentParser(description='Gmail Search Alfred Workflow')
    parser.add_argument('--unread', action='store_true',
                        help='Show unread-focused search options (used for gmu keyword)')
    parser.add_argument('query', nargs='*', help='Search query')

    args = parser.parse_args()

    try:
        q = query_text(args)
        utils.log_info(f"Gmail search query: '{q}', unread_mode: {args.unread}")

        items = build_search_items(q, unread_mode=args.unread)

        if not items:
            items = [{
                "title": "No search options available",
                "subtitle": "Please try again",
                "valid": False
            }]

        utils.log_info(f"Returning {len(items)} items to Alfred")
        print(json.dumps({"items": items}, ensure_ascii=False))

    except Exception as e:
        utils.log_error(f"Main execution failed: {str(e)}")
        error_items = [{
            "title": "Gmail Search Error",
            "subtitle": f"An error occurred: {str(e)}",
            "valid": False
        }]
        print(json.dumps({"items": error_items}, ensure_ascii=False))


if __name__ == "__main__":
    main()
