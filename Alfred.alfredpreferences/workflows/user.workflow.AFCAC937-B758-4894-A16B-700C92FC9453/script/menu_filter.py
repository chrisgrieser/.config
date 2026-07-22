#!/usr/bin/env python3

import argparse
import json
import os

from urllib.parse import quote_plus

GMAIL_BASE_URL = "https://mail.google.com/mail/u/{account}/#search/{query}"
GMAIL_BASE_URL2 = "https://mail.google.com/mail/u/{account}/#search/{turl}{query}"
GMAIL_BASE_URL_UNREAD = "https://mail.google.com/mail/u/{account}/#search/label:unread+{turl}{query}"
GMAIL_BASE_URL_UNREAD2 = "https://mail.google.com/mail/u/{account}/#search/label:unread+{turl}+{query}"
GMAIL_SETTING_URL = "https://mail.google.com/mail/u/{account}/{query}"
STATIC_ICONS = {
    "gms-any-star": "any-star.png",
    "gms-red-bang": "red-bang.png",
    "gms-yellow-bang": "yellow-bang.png",
    "gms-purple-question": "purple-question.png",
    "gms-blue-info": "blue-info.png",
    "gms-blue-star": "blue-star.png",
    "gms-orange-guillemet": "orange-guillemet.png",
    "gms-yellow-star": "yellow-star.png",
    "gms-orange-star": "orange-star.png",
    "gms-red-star": "red-star.png",
    "gms-purple-star": "purple-star.png",
    "gms-green-check": "green-check.png",
    "gms-green-star": "green-star.png",
    "gmu-main": "unread.png",
    "gmu-promotions": "green-money.png",
    "gmu-purchases": "green-money.png",
    "gmu-reservations": "reservations.png",
    "gmo-social": "social.png",
    "gmo-forums": "forums.png",
    "gmu-search-unread": "unread.png",
    "gmo-from": "mailfrom.png",
    "gmo-to": "mailto.png",
    "gmo-cc": "mailcc.png",
    "gmo-bcc": "mailbcc.png",
    "gmo-exclude": "exclude.png",
    "gmo-label": "labels.png",
    "gmo-attachments": "attachment.png",
    "gmo-drive-link": "gdrive.png",
    "gmo-document": "document.png",
    "gmo-spreadsheet": "spreadsheet.png",
    "gmo-presentation": "presentation.png",
    "gmo-youtube": "video.png",
    "gmo-filename": "filename.png",
    "gmo-important": "important.png",
    "gmo-draft": "drafts.png",
    "gmo-sent": "sent.png",
    "gmo-anywhere": "anywhere.png",
    "gmo-spam": "spam.png",
    "gmo-trash": "trash.png",
    "gmo-scheduled": "scheduled.png",
    "gmo-snoozed": "snoozed.png",
    "gmo-user-label": "labels-any.png",
    "gmo-no-user-labels": "labels-none.png",
    "gmo-after": "date.png",
    "gmo-before": "date.png",
    "gmo-older": "date.png",
    "gmo-newer": "date.png",
    "gmo-older-than": "date.png",
    "gmo-chat": "chat.png",
    "gmo-reservations": "reservations.png",

    # Menu Items To Other Searching Tools/Keywords
    "gmm-config": "settings.png",
    "gmm-diagnostic": "settings.png",
    "gmm-forum": "link.png",
    "gmm-github": "link.png",
    "gmm-unread": "unread.png",
    "gmm-operators": "date.png",
    "gmm-labels": "labels.png",
    "gmm-user": "next.png",
    "gmm-account": "account.png",
    "gmm-back": "back.png",
    "gmm-settings": "settings.png",
}

# Currency icon mapping
CURRENCY_ICONS = {
    "dollar": "green-dollar.png",
    "pound": "green-pound.png",
    "euro": "green-euro.png",
    "yen": "green-yen.png",
}

def get_currency_icon():
    """Get the current currency icon based on Alfred environment variable"""
    currency = os.environ.get("currency", "dollar")
    return CURRENCY_ICONS.get(currency, CURRENCY_ICONS["dollar"])


def get_icon_for_uid(uid):
    """Get icon file for an uid, including currency-based icons"""
    if uid in STATIC_ICONS:
        return STATIC_ICONS[uid]
    if uid in ("gmu-promotions", "gmu-purchases", "gmo-promotions-category", "gmo-purchases-category"):
        return get_currency_icon()
    return None

# Gmail can have multiple accounts logged in at a time. The account number is used to differentiate the accounts.
def account_number():
    return os.environ.get("userNumber") or os.environ.get("gmail_account") or "0"

def current_account_email():
    return os.environ.get(f"email_{account_number()}") or ""

def user_labels():
    # Get user labels from Alfred environment variable
    labels = os.environ.get("labels") or ""
    # Split labels by comma and remove any leading or trailing spaces
    labels = [label.strip() for label in labels.split(",")]
    return labels

def user_accounts():
    accounts = []
    # Gather all account variables email_0 - email_9.
    for i in range(10):
        email = os.environ.get(f"email_{i}") or ""
        if email and email not in accounts:
            accounts.append(email)

    return accounts

def turl_info():
    return os.environ.get("turl") or ""

def url_info():
    return os.environ.get("url") or ""

def ticon_info():
    return os.environ.get("ticon") or ""


def gmail_url(query):
    return GMAIL_BASE_URL.format(account=account_number(), query=quote_plus(query))

def gmail_url2(query, turl):
    return GMAIL_BASE_URL2.format(account=account_number(), query=quote_plus(query), turl=quote_plus(turl))

def gmail_url_unread(query, turl):
    return GMAIL_BASE_URL_UNREAD.format(account=account_number(), query=quote_plus(query), turl=quote_plus(turl))

def gmail_url_unread2(query, turl):
    return GMAIL_BASE_URL_UNREAD.format(account=account_number(), query=quote_plus(query), turl=quote_plus(turl))

def gmail_url_settings(query):
    return GMAIL_SETTING_URL.format(account=account_number(), query=query)

def gmail_arg(query):
    return query

# Set Alfred Variable turl to quote_plus(query)
def set_turl(query):
    return f"setvar turl \"{quote_plus(query)}\""

def item(uid, title, subtitle, arg=None, route: str = "", url: str = "", valid=True, order=True,  icon: str = ""):
    if order:
        result = {
            "title": title,
            "subtitle": subtitle,
            "valid": valid,
            "arg": arg,
            "skipknowledge": True,  #Useful for keeping the order of the items uid cannot be used at the same time
            "maintainOrder": order,
            "icon": {"path": icon},
            "variables": {"account": account_number(), "route": route if route else "", "url": url if url else "", "ticon": icon},
        }
    else:
        result = {
            "title": title,
            "subtitle": subtitle,
            "valid": valid,
            "uid": uid, # Items will be sorted by usage in Alfred
            "arg": arg,
            "maintainOrder": order,
            "icon": {"path": icon},
            "variables": {"account": account_number(), "route": route if route else "", "url": url if url else "", "ticon": icon},
        }
    if arg is not None:
        result["arg"] = arg
    icon_file = get_icon_for_uid(uid)
    if icon_file:
        result["icon"] = {"path": icon_file}
        result["variables"]["ticon"] = icon_file
    return result

# Gmail Search Filterable List - Keep in this order
def gms_items():
    items = [
        item("gmo-search-options","Search Stars Info","⌘|⌥|⌃|⌘⇧|⌥⇧|⌃⇧ FastPhrases -- ⌘⌥ Clipboard","",valid=True),
        item("gms-any-star", "Any Star", "Show mail with Any Star", gmail_arg("is:starred ")),
        item("gms-red-bang", "Red Bang", "Show mail with red-bang star", gmail_arg("has:red-bang ")),
        item("gms-yellow-bang","Yellow Bang","Show mail with yellow-bang star",gmail_arg("has:yellow-bang ")),
        item("gms-purple-question","Purple Question","Show mail with purple-question star",gmail_arg("has:purple-question ")),
        item("gms-blue-info","Blue Info","Show mail with blue-info star",gmail_arg("has:blue-info ")),
        item("gms-blue-star", "Blue Star", "Show mail with blue-star", gmail_arg("has:blue-star ")),
        item("gms-orange-guillemet","Orange Guillemet","Show mail with orange-guillemet",gmail_arg("has:orange-guillemet ")),
        item("gms-yellow-star", "Yellow Star", "Show mail with yellow-star", gmail_arg("has:yellow-star ")),
        item("gms-orange-star", "Orange Star", "Show mail with orange-star", gmail_arg("has:orange-star ")),
        item("gms-red-star", "Red Star", "Show mail with red-star", gmail_arg("has:red-star ")),
        item("gms-purple-star", "Purple Star", "Show mail with purple-star", gmail_arg("has:purple-star ")),
        item("gms-green-star", "Green Star", "Show mail with green-star", gmail_arg("has:green-star ")),
        item("gms-green-check","Green Checkmark","Show mail with green-check",gmail_arg("has:green-check "), icon="checkmark.png"),
        item("gmo-important", "Important", "Ex. is:important", gmail_arg("is:important ")),
        item("gmo-draft", "Drafts", "Ex. in:draft", gmail_arg("in:draft ")),
        item("gmo-sent", "Sent", "Ex. in:sent", gmail_arg("in:sent ")),
        item("gmo-anywhere","Anywhere (include Spam & Trash)","Ex. in:anywhere",gmail_arg("in:anywhere ")),
        item("gmo-spam","Spam","Ex. in:spam",gmail_arg("in:spam ")),
        item("gmo-trash","Trash","Ex. in:trash",gmail_arg("in:trash ")),
        # Menu Items To Other Searching Tools/Keywords
        item("gms-search-arg", "→ Gmail Search With Argument (gmss)", "Fast Custom Search", "", route="main2"),
        item("gmm-unread","→ Gmail Search Unread (gmu)","Search Un-Read Gmail Messages","", route="unread"),
        item("gmm-operators", "→ Gmail Search Operators (gmo)", "Learn Power Searches", "", route="operators"),
        item("gmm-labels", "→ Gmail Search Labels (gml)", "Label Searches", "", route="labels"),
        item("gmm-settings", "→ Settings", "Open workflow configuration", "", route="settings"),
    ]
    return items

# Un-Read Mail Filterable List - Keep in this order
def gmu_items():
    items = [
        item("gmo-search-options","Search Un-Read Info","⌘|⌥|⌃|⌘⇧|⌥⇧|⌃⇧ FastPhrases -- ⌘⌥ Clipboard","",valid=True),
        item("gmu-search-unread","Search Un-Read","Search All Un-Read Messages",gmail_arg("is:unread ")),
        item("gmu-primary","Primary Unread","Unread in Primary",gmail_arg("category:primary label:unread ")),
        item("gmo-social", "Social Category", "Ex. category:social", gmail_arg("category:social label:unread ")),
        item("gmu-updates","Updates UnRead","Unread in Updates",gmail_arg("category:updates label:unread ")),
        item("gmu-promotions","Promotions UnRead","Unread in Promotions",gmail_arg("category:promotions label:unread ")),
        item("gmo-forums","Forums UnRead","Unread in Forums",gmail_arg("category:forums label:unread ")),
        item("gmu-reservations","Reservations UnRead","Reservations category",gmail_arg("category:reservations label:unread ")),
        item("gmu-purchases", "Purchases UnRead", "Purchases category", gmail_arg("category:purchases label:unread ")),
        # Menu Items To Other Searching Tools/Keywords
        item("gmm-unread-arg", "→ Un-Read Search With Argument (gmuu)", "Fast Custom Un-Read Search", "", route="unread2"),
        item("gmm-operators", "→ Gmail Search Operators (gmo)", "Learn Power Searches", "", route="operators"),
        item("gmm-labels", "→ Gmail Search Labels (gml)", "Label Searches", "", route="labels"),
        item("gmm-settings", "→ Settings", "Open workflow configuration", "", route="settings"),
        item("gmm-back", "→ Start Over", "Return to the main menu", "", route="main"),
    ]
    return items

# Search Operators Filterable List - Keep in this order
def gmo_items():
    items = [
        item("gmm-operators","Search Operators Info","⌘|⌥|⌃|⌘⇧|⌥⇧|⌃⇧ FastPhrases -- ⌘⌥ Clipboard","",valid=True),
        item("gmo-from", "From", "Ex. from:bob", gmail_arg("from:")),
        item("gmo-to", "To", "Ex. to:bob", gmail_arg("to:")),
        item("gmo-cc", "CC", "Ex. cc:bob", gmail_arg("cc:")),
        item("gmo-bcc", "BCC", "Ex. bcc:bob", gmail_arg("bcc:")),
        item("gmo-subject", "Subject", "Ex. subject:what about bob", gmail_arg("subject:")),
        # TODO: Add OR operator with argument support needs 2 arguments
        item("gmo-or", "OR", "Ex. from:bob OR from:bam", "OR", valid=False),
        item("gmo-exclude", "Exclude", "Ex. bam -rock", gmail_arg("-")),
        # TODO: Add AROUND operator with argument support needs 2 arguments
        item("gmo-around", "AROUND", "Ex. flight AROUND 10 airport", "AROUND", valid=False),
        item("gmo-label", "Label", "Ex. label:builders", gmail_arg("label:")),
        item("gmo-attachments", "Attachments", "Ex. has:attachment", gmail_arg("has:attachment ")),
        item("gmo-drive-link", "Drive Link", "Ex. has:drive", gmail_arg("has:drive ")),
        item("gmo-document", "Document", "Ex. has:document", gmail_arg("has:document ")),
        item("gmo-spreadsheet", "Spreadsheet", "Ex. has:spreadsheet", gmail_arg("has:spreadsheet ")),
        item("gmo-presentation", "Presentation", "Ex. has:presentation", gmail_arg("has:presentation ")),
        item("gmo-youtube", "YouTube", "Ex. has:youtube", gmail_arg("has:youtube ")),
        item("gmo-list", "List", "Ex. list:info@example.org", gmail_arg("list:")),
        item("gmo-filename", "Filename", "Ex. filename:wishlist.txt", gmail_arg("filename:")),
        # TODO: Fix issue with placement
        item("gmo-exact-word-or-phrase","Exact Word or Phrase",'Ex. "bob the builder"',gmail_arg("\"\"")),
        # TODO: Fix issue with placement
        item("gmo-group-search-terms", "Group Search Terms", "Ex. (bob builder)", gmail_arg("()")), # Needs Submenu
        item("gmo-anywhere","Anywhere (include Spam & Trash)","Ex. in:anywhere",gmail_arg("in:anywhere ")),
        item("gmo-spam","Spam","Ex. in:spam",gmail_arg("in:spam ")),
        item("gmo-trash","Trash","Ex. in:trash",gmail_arg("in:trash ")),
        item("gmo-important", "Important", "Ex. is:important", gmail_arg("is:important ")),
        item("gmo-scheduled", "Scheduled", "Ex. is:scheduled", gmail_arg("is:scheduled ")),
        item("gmo-draft", "Drafts", "Ex. in:draft", gmail_arg("in:draft ")),
        item("gmo-sent", "Sent", "Ex. in:sent", gmail_arg("in:sent ")),
        item("gmo-snoozed", "Snoozed", "Ex. in:snoozed", gmail_arg("in:snoozed ")),
        item("gmo-after", "After", "Ex. after:08/28/2024", gmail_arg("after:")),
        item("gmo-before", "Before", "Ex. before:08/28/2004", gmail_arg("before:")),
        item("gmo-older", "Older", "Ex. older:08/28/2004", gmail_arg("older:")),
        item("gmo-newer", "Newer", "Ex. newer:08/28/2004", gmail_arg("newer:")),
        item("gmo-older-than","Older Than (d=Day m=Mnth y=Yr)","Ex. older_than:2d",gmail_arg("older_than:")),
        item("gmo-chat", "Chat", "Ex. is:chat", gmail_arg("is:chat ")),
        item("gmo-delivered-to","Delivered To","Ex. deliveredto:username@gmail.com",gmail_arg("deliveredto:")),
        item("gmo-primary-category", "Primary Category", "Ex. category:primary", gmail_arg("category:primary ")),
        item("gmo-social", "Social Category", "Ex. category:social", gmail_arg("category:social ")),
        item("gmo-promotions-category","Promotions Category","Ex. category:promotions",gmail_arg("category:promotions ")),
        item("gmo-updates-category", "Updates Category", "Ex. category:updates", gmail_arg("category:updates ")),
        item("gmo-forums-category", "Forums Category", "category:forums", gmail_arg("category:forums ")),
        item("gmo-reservations","Reservations Category","Ex. category:reservations",gmail_arg("category:reservations ")),
        item("gmo-purchases-category","Purchases Category","Ex. category:purchases",gmail_arg("category:purchases ")),
        item("gmo-size-larger", "Size (Larger)", "Ex. size:1000000 (bytes / K / M)", gmail_arg("size:")),
        item("gmo-larger-size", "Larger Size", "Ex. larger:10M", gmail_arg("larger:")),
        item("gmo-smaller-size", "Smaller Size", "Ex. smaller:1M", gmail_arg("smaller:")),
        item("gmo-exact-word-match", "Exact Word Match", "Ex. +unicorn", gmail_arg("+")),
        item("gmo-user-label","User Label (Has Any User Label)","Ex. has:userlabels",gmail_arg("has:userlabels ")),
        item("gmo-no-user-labels", "No User Labels", "Ex. has:nouserlabels", gmail_arg("has:nouserlabels ")),
        # Menu Items To Other Searching Tools/Keywords
        item("gmm-operators-arg", "Gmail Operators With Argument (gmoo)", "Fast Operator Search", "", route="operators2"),
        item("gmm-unread", "→ Gmail Un-Read Mail (gmu)", "Un-Read quick link menu", "", route="unread"),
        item("gmm-labels", "→ Gmail Search Labels (gml)", "Label Searches", "", route="labels"),
        item("gmm-settings", "→ Settings", "Open workflow configuration", "", route="settings"),
        item("gmm-back", "→ Start Over", "Return to the main menu", "", route="main"),
    ]
    return items

# Search Labels Filterable List - Keep in this order
def gml_items(query):
    q = query.strip()
    # take "labels" Config variable using user_labels() and create a list of items for each label. 1 item per label (comma-separated list)
    labels = user_labels()
    items = [
        item("gmo-search-options","Search Labels","⌘|⌥|⌃|⌘⇧|⌥⇧|⌃⇧ FastPhrases -- ⌘⌥ Clipboard","",valid=True),
    ]
    # add a menu item for each label
    for label in labels:
        items.append(item("gmo-label-"+label,"Label: "+label,"Messages with label: "+label,gmail_arg(f"label:{label} {q} "),valid=True))
    return items

# Gmail Star Search with Qurey
def gmss_items(query):
    q = query.strip()
    items = [
        item("gmo-search-options",f'Search Gmail: "{q}"' if q else "Gmail Search Tools",
             "⌘|⌥|⌃|⌘⇧|⌥⇧|⌃⇧ FastPhrases -- ⌘⌥ Clipboard",gmail_url(q),valid=True),
        item("gms-search",f'Search Gmail: "{q}"' if q else "Search Gmail","Search all Gmail messages",gmail_url(q)),
        item("gms-search-unread",f'Search Un-Read: "{q}"' if q else "Search Unread",
             "Search unread Gmail messages",gmail_url2(q,"label:unread ")),
        item("gms-red-bang", f'Red Bang: "{q}"' if q else "Red Bang",
             "Show mail with red-bang star", gmail_url2(q,"has:red-bang ")),
        item("gms-yellow-bang",f'Yellow Bang: "{q}"' if q else "Yellow Bang",
             "Show mail with yellow-bang star",gmail_url2(q,"has:yellow-bang ")),
        item("gms-purple-question",f'Purple Question: "{q}"' if q else "Purple Question",
             "Show mail with purple-question star",gmail_url2(q,"has:purple-question ")),
        item("gms-blue-info",f'Blue Info: "{q}"' if q else "Blue Info",
             "Show mail with blue-info star",gmail_url2(q,"has:blue-info ")),
        item("gms-blue-star", f'Blue Star: "{q}"' if q else "Blue Star",
             "Show mail with blue-star", gmail_url2(q,"has:blue-star ")),
        item("gms-orange-guillemet",f'Orange Guillemet: "{q}"' if q else "Orange Guillemet",
             "Show mail with orange-guillemet",gmail_url2(q,"has:orange-guillemet ")),
        item("gms-yellow-star", f'Yellow Star: "{q}"' if q else "Yellow Star",
             "Show mail with yellow-star", gmail_url2(q,"has:yellow-star ")),
        item("gms-orange-star", f'Orange Star: "{q}"' if q else "Orange Star",
             "Show mail with orange-star", gmail_url2(q,"has:orange-star ")),
        item("gms-red-star", f'Red Star: "{q}"' if q else "Red Star",
             "Show mail with red-star", gmail_url2(q,"has:red-star ")),
        item("gms-purple-star", f'Purple Star: "{q}"' if q else "Purple Star",
             "Show mail with purple-star", gmail_url2(q,"has:purple-star ")),
        item("gms-green-star", f'Green Star: "{q}"' if q else "Green Star",
             "Show mail with green-star", gmail_url2(q,"has:green-star ")),
        item("gms-green-check", f'Green Checkmark: "{q}"' if q else "Green Checkmark",
             "Show mail with green-check",gmail_url2(q,"has:green-check ")),
        item("gmo-anywhere",f'Anywhere (include Spam & Trash): "{q}"' if q else "Anywhere (include Spam & Trash)",
             "Ex. in:anywhere",gmail_url(f"in:anywhere {q}".strip()) if q else "in:anywhere"),
        item("gmo-spam",f'Spam: "{q}"' if q else "Spam",
             "Ex. in:spam",gmail_url(f"in:spam {q}".strip()) if q else "in:spam"),
        item("gmo-trash",f'Trash: "{q}"' if q else "Trash",
             "Ex. in:trash",gmail_url(f"in:trash {q}".strip()) if q else "in:trash"),
        item("gmo-important", f'Important: "{q}"' if q else "Important",
             "Ex. is:important", gmail_url(f"is:important {q}".strip())),
        item("gmo-scheduled", f'Scheduled: "{q}"' if q else "Scheduled",
             "Ex. is:scheduled", gmail_url(f"is:scheduled {q}".strip())),
        item("gmo-draft", f'Drafts: "{q}"' if q else "Drafts",
             "Ex. in:draft", gmail_url(f"in:draft {q}".strip())),
        item("gmo-sent", f'Sent: "{q}"' if q else "Sent",
             "Ex. in:sent", gmail_url(f"in:sent {q}".strip())),
        # Menu Items To Other Searching Tools/Keywords
        item("gmm-operators", "→ Gmail Search Operators (gmo)", "Learn Power Searches", "", route="operators"),
        item("gmm-unread", "→ Gmail Un-Read Mail (gmu)", "Un-Read Quick Links Menu", "", route="unread"),
        item("gmm-settings", "→ Settings", "Open workflow configuration", "", route="settings"),
        item("gmm-back", "→ Start Over", "Return to the main menu", "", route="main"),
    ]
    return items



# Un-Read Mail Search With Query
def gmuu_items(query):
    q = query.strip()
    items = [
        item("gmo-search-options",f'Search Gmail: "{q}"' if q else "Search Un-Read",
             "⌘|⌥|⌃|⌘⇧|⌥⇧|⌃⇧ FastPhrases -- ⌘⌥ Clipboard",gmail_url_unread(q,""),valid=True),
        item("gmu-search-unread",f'Search Un-Read Gmail: "{q}"' if q else "Search Un-Read Gmail",
             "Search all Un-Read",gmail_url_unread(q,"label:unread ")),
        item("gmu-primary",f'Primary Un-Read: "{q}"' if q else "Primary Un-Read",
             "Un-Read in Primary",gmail_url_unread(q,"category:primary ")),
        item("gmu-updates",f'Updates Un-Read: "{q}"' if q else "Updates Un-Read",
             "Un-Read in Updates",gmail_url_unread(q,"category:updates ")),
        item("gmu-promotions",f'Promotions Un-Read: "{q}"' if q else "Promotions Un-Read",
             "Unread in Promotions",gmail_url_unread(q,"category:promotions ")),
        item("gmo-forums",f'Forums Un-Read: "{q}"' if q else "Forums Un-Read",
             "Unread in Forums",gmail_url_unread(q,"category:forums ")),
        item("gmu-reservations",f'Reservations Un-Read: "{q}"' if q else "Reservations Un-Read",
             "Reservations category",gmail_url_unread(q,"category:reservations ")),
        item("gmu-purchases",f'Purchases Un-Read: "{q}"' if q else "Purchases Un-Read",
             "Purchases category", gmail_url_unread(q,"category:purchases ")),
        # Menu Items To Other Searching Tools/Keywords
        item("gmm-operators", "→ Gmail Search Operators (gmo)", "Learn Power Searches", "", route="operators"),
        item("gmm-unread", "→ Un-Read Mail (gmu)", "Un-Read Quick Links Menu", "", route="unread"),
        item("gmm-settings", "→ Settings", "Open workflow configuration", "", route="settings"),
        item("gmm-back", "→ Start Over", "Return to the main menu", "", route="main"),
    ]
    return items


# Search Operators with Argument
def gmoo_items(query):
    q = query.strip()
    items = [
        item("gmo-search-options",f'Search Gmail: "{q}"' if q else "Search Operators",
             "⌘|⌥|⌃|⌘⇧|⌥⇧|⌃⇧ FastPhrases -- ⌘⌥ Clipboard",gmail_url(q),valid=True),
        item("gmo-from", f'From: "{q}"' if q else "From:", "Ex. from:bob", gmail_url(f"from:{q}".strip())),
        item("gmo-to", f'To: "{q}"' if q else "To:", "Ex. to:bob", gmail_url(f"to:{q}".strip())),
        item("gmo-cc", f'CC: "{q}"' if q else "CC", "Ex. cc:bob", gmail_url(f"cc:{q}".strip())),
        item("gmo-bcc", f'BCC: "{q}"' if q else "BCC", "Ex. bcc:bob", gmail_url(f"bcc:{q}".strip())),
        item("gmo-subject", f'Subject: "{q}"' if q else "Subject",
             "Ex. subject:what about bob", gmail_url(f"subject:{q}".strip())),
        # TODO: Add OR operator with argument support needs 2 arguments
        item("gmo-or", f'OR: "{q}"' if q else "OR",
             "Ex. from:bob OR from:bam", gmail_url(f"OR {q}".strip()) if q else "OR", valid=False),
        item("gmo-exclude", f'Exclude: "{q}"' if q else "Exclude",
             "Ex. bam -rock", gmail_url(f"-{q}".strip()) if q else "-"),
        # TODO: Add AROUND operator with argument support needs 2 arguments
        item("gmo-around", f'AROUND: "{q}"' if q else "AROUND",
             "Ex. flight AROUND 10 airport", gmail_url(f"{q} AROUND 10".strip()) if q else "AROUND", valid=False),
        item("gmo-label", f'Label: "{q}"' if q else "Label",
             "Ex. label:builders", gmail_url(f"label:{q}".strip())),
        item("gmo-attachments", f'Attachments: "{q}"' if q else "Attachments",
             "Ex. has:attachment", gmail_url(f"has:attachment {q}".strip())),
        item("gmo-drive-link", f'Drive Link: "{q}"' if q else "Drive Link",
             "Ex. has:drive", gmail_url(f"has:drive {q}".strip())),
        item("gmo-document", f'Document: "{q}"' if q else "Document",
             "Ex. has:document", gmail_url(f"has:document {q}".strip())),
        item("gmo-spreadsheet", f'Spreadsheet: "{q}"' if q else "Spreadsheet",
             "Ex. has:spreadsheet", gmail_url(f"has:spreadsheet {q}".strip())),
        item("gmo-presentation", f'Presentation: "{q}"' if q else "Presentation",
             "Ex. has:presentation", gmail_url(f"has:presentation {q}".strip())),
        item("gmo-youtube", f'YouTube: "{q}"' if q else "YouTube",
             "Ex. has:youtube", gmail_url(f"has:youtube {q}".strip())),
        item("gmo-list", f'List: "{q}"' if q else "List",
             "Ex. list:info@example.org", gmail_url(f"list:{q}".strip())),
        item("gmo-filename", f'Filename: "{q}"' if q else "Filename",
             "Ex. filename:wishlist.txt", gmail_url(f"filename:{q}".strip())),
        item("gmo-exact-word-or-phrase",f'Exact Word or Phrase: "{q}"' if q else "Exact Word or Phrase",
             'Ex. "bob the builder"',gmail_url(f'"{q}"') if q else '""'),
        item("gmo-group-search-terms", f'Group Search Terms: "{q}"' if q else "Group Search Terms",
             "Ex. (bob builder)", gmail_url(f"({q})") if q else "()"),
        item("gmo-anywhere",f'Anywhere (include Spam & Trash): "{q}"' if q else "Anywhere (include Spam & Trash)",
            "Ex. in:anywhere",gmail_url(f"in:anywhere {q}".strip()) if q else "in:anywhere"),
        item("gmo-spam",f'Spam: "{q}"' if q else "Spam",
             "Ex. in:spam",gmail_url(f"in:spam {q}".strip()) if q else "in:spam"),
        item("gmo-trash",f'Trash: "{q}"' if q else "Trash",
             "Ex. in:trash",gmail_url(f"in:trash {q}".strip()) if q else "in:trash"),
        item("gmo-important", f'Important: "{q}"' if q else "Important",
             "Ex. is:important", gmail_url(f"is:important {q}".strip())),
        item("gmo-scheduled", f'Scheduled: "{q}"' if q else "Scheduled",
             "Ex. is:scheduled", gmail_url(f"is:scheduled {q}".strip())),
        item("gmo-draft", f'Drafts: "{q}"' if q else "Drafts",
             "Ex. in:draft", gmail_url(f"in:draft {q}".strip())),
        item("gmo-sent", f'Sent: "{q}"' if q else "Sent",
             "Ex. in:sent", gmail_url(f"in:sent {q}".strip())),
        item("gmo-snoozed", f'Snoozed: "{q}"' if q else "Snoozed",
             "Ex. in:snoozed", gmail_url(f"in:snoozed {q}".strip())),
        item("gmo-after", f'After: "{q}"' if q else "After",
             "Ex. after:08/28/2024", gmail_url(f"after:{q}".strip())),
        item("gmo-before", f'Before: "{q}"' if q else "Before",
             "Ex. before:08/28/2004", gmail_url(f"before:{q}".strip())),
        item("gmo-older", f'Older: "{q}"' if q else "Older",
             "Ex. older:08/28/2004", gmail_url(f"older:{q}".strip())),
        item("gmo-newer", f'Newer: "{q}"' if q else "Newer",
             "Ex. newer:08/28/2004", gmail_url(f"newer:{q}".strip())),
        item("gmo-older-than",f'Older Than (d=Day m=Mnth y=Yr): "{q}"' if q else "Older Than (d=Day m=Mnth y=Yr)",
            "Ex. older_than:2d",gmail_url(f"older_than:{q}".strip())),
        item("gmo-chat", f'Chat: "{q}"' if q else "Chat",
             "Ex. is:chat", gmail_url(f"is:chat {q}".strip())),
        item("gmo-delivered-to",f'Delivered To: "{q}"' if q else "Delivered To",
            "Ex. deliveredto:username@gmail.com",gmail_url(f"deliveredto:{q}".strip())),
        item("gmo-primary-category", f'Primary Category: "{q}"' if q else "Primary Category",
             "Ex. category:primary", gmail_url(f"category:primary {q}".strip())),
        item("gmo-social", f'Social Category: "{q}"' if q else "Social Category",
             "Ex. category:social", gmail_url(f"category:social {q}".strip())),
        item("gmo-promotions-category",f'Promotions Category: "{q}"' if q else "Promotions Category",
            "Ex. category:promotions",gmail_url(f"category:promotions {q}".strip())),
        item("gmo-updates-category", f'Updates Category: "{q}"' if q else "Updates Category",
             "Ex. category:updates", gmail_url(f"category:updates {q}".strip())),
        item("gmo-forums-category", f'Forums Category: "{q}"' if q else "Forums Category",
             "Ex. category:forums", gmail_url(f"category:forums {q}".strip())),
        item("gmo-reservations",f'Reservations Category: "{q}"' if q else "Reservations Category",
            "Ex. category:reservations",gmail_url(f"category:reservations {q}".strip())),
        item("gmo-purchases-category",f'Purchases Category: "{q}"' if q else "Purchases Category",
            "Ex. category:purchases",gmail_url(f"category:purchases {q}".strip())),
        item("gmo-size-larger", f'Size (Larger): "{q}"' if q else "Size (Larger)",
             "Ex. size:1000000 (bytes / K / M)", gmail_url(f"size:{q}".strip())),
        item("gmo-larger-size", f'Larger Size: "{q}"' if q else "Larger Size",
             "Ex. larger:10M", gmail_url(f"larger:{q}".strip())),
        item("gmo-smaller-size", f'Smaller Size: "{q}"' if q else "Smaller Size",
             "Ex. smaller:1M", gmail_url(f"smaller:{q}".strip())),
        item("gmo-exact-word-match", f'Exact Word Match: "{q}"' if q else "Exact Word Match",
             "Ex. +unicorn", gmail_url(f"+{q}".strip()) if q else "+"),
        item("gmo-user-label",f'User Label (Has Any User Label): "{q}"' if q else "User Label (Has Any User Label)",
            "Ex. has:userlabels",gmail_url(f"has:userlabels {q}".strip())),
        item("gmo-no-user-labels", f'No User Labels: "{q}"' if q else "No User Labels",
             "Ex. has:nouserlabels", gmail_url(f"has:nouserlabels {q}".strip())),
        item("gmm-unread", f'Un-Read: "{q}"' if q else "Un-Read",
             "Un-Read quick link menu", gmail_url(f"is:unread {q}".strip())),
        # Menu Items To Other Searching Tools/Keywords
        item("gmm-operators", "→ Gmail Search Operators (gmo)", "Learn Power Searches", "", route="operators"),
        item("gmm-unread", "→ Un-Read Mail (gmu)", "Un-Read Quick Links Menu", "", route="unread"),
        item("gmm-settings", "→ Settings", "Open workflow configuration", "", route="settings"),
        item("gmm-back", "→ Start Over", "Return to the main menu", "", route="main"),
    ]
    return items

# Search by Labels with Argument
def gmll_items(query):
    q = query.strip()
    # take "labels" Config variable using user_labels() and create a list of items for each label. 1 item per label (comma-separated list)
    labels = user_labels()
    items = [
        item("gmo-search-options","Search Labels","⌘|⌥|⌃|⌘⇧|⌥⇧|⌃⇧ FastPhrases -- ⌘⌥ Clipboard","",valid=True),
    ]
    # add a menu item for each label
    for label in labels:
        items.append(item("gmo-label-"+label,f'{label} "{q}"' if q else label,"Messages with label: "+label,gmail_url(f"label:{label} {q} "),valid=True))
    return items

# Settings Menu
def gmsettings_items():
    return [
        item("gmm-config","Config →","Open workflow configuration in Alfred","", route="config"),
        item("gmm-diagnostic","Diagnostic →","Run workflow diagnostic","", route="diagnostic"),
        item("gmm-subscriptions","Manage Subscriptions →","Manage Your Subscriptions on Gmail",gmail_url_settings("#sub"), route="gmsetting"),
        item("gmo-label","Manage Labels →","Manage Your Labels on Gmail",gmail_url_settings("#settings/labels"), route="gmsetting"),
        item("gms-any-star","Manage Stars →","Enable Various Stars on Gmail",gmail_url_settings("#settings/general"), route="gmsetting"),
        item("gmm-user","Switch Account →","Quickly Switch Account","", route="user"),
        item("gmm-forum","Forum →","Open Alfred Forum page","", route="forum"),
        item("gmm-github","GitHub →","Open GitHub project page","", route="github"),
        item("gmm-back", "Start Over →", "Return to the main menu", "", route="back"),
    ]

# User Switching Menu
def gmuser_items():
    accounts = user_accounts()
    current = current_account_email()
    items = [
        item("gmo-search-options","Keep Current Account "+current,"Current User Account","", route="settings"),
    ]
    # Add a menu item for each account.
    i = 0
    for account in accounts:
        items.append(
            item(
                "gmm-account",account,
                f'Switch to: {i} : {account}' if account else "Search:",i,valid=True,
            )
        )
        i = i + 1

    # Settings Menu Link
    items.append(
        item("gmm-settings","→ Settings","Open workflow configuration","", route="settings")
    )
    return items


# Individual Search Query Prompt and Simple Menu
def gmz_items(query):
    q = query.strip()
    z = turl_info()
    i = ticon_info()
    return [
        item("gmz-search",f'Search: "{q}"' if q else "Search:",f'Route: "{z}"' if z else "Empty Route",gmail_url2(q,z),
             route=f'Route: "{z}"' if z else "Empty Route", url=gmail_url2(q,z), icon=i),
        item("gmz-search2",f'Un-Read + Search: "{q}"' if q else "Un-Read + Search:",f'Un-Read + Route: "{z}"' if z else "Empty Route",gmail_url2(q,z),
             route=f'Route: "{z}"' if z else "Empty Route", url=gmail_url_unread(q,z), icon=i),
        # Menu Items To Other Searching Tools/Keywords
        item("gmm-unread","→ Un-Read Mail (gmu)","Un-Read Quick Links Menu","", route="unread"),
        item("gmm-operators", "→ Gmail Search Operators (gmo)", "Learn Power Searches", "", route="operators"),
        item("gmm-settings","→ Settings","Open workflow configuration","", route="settings"),
        item("gmm-back", "→ Start Over", "Return to the main menu", "", route="main"),
    ]


def main():
    parser = argparse.ArgumentParser(description="Gmail menu script filter")
    parser.add_argument(
        "--mode",
        choices=["gms", "gmss", "gmu", "gmuu", "gmo", "gmoo", "gml", "gmll", "gmsettings", "gmuser", "gmz"],
        required=True,
    )
    parser.add_argument("--route", default="")
    parser.add_argument("query", nargs="*")
    args = parser.parse_args()

    query = " ".join(args.query).strip()
    if args.mode == "gmu":
        items = gmu_items()
    elif args.mode == "gmuu":
        items = gmuu_items(query)
    elif args.mode == "gmss":
        items = gmss_items(query)
    elif args.mode == "gmo":
        items = gmo_items()
    elif args.mode == "gmoo":
        items = gmoo_items(query)
    elif args.mode == "gml":
        items = gml_items(query)
    elif args.mode == "gmll":
        items = gmll_items(query)
    elif args.mode == "gmsettings":
        items = gmsettings_items()
    elif args.mode == "gmuser":
        items = gmuser_items()
    elif args.mode == "gmz":
        items = gmz_items(query)
    else:
        items = gms_items()
    print(json.dumps({"items": items}, ensure_ascii=False))


if __name__ == "__main__":
    main()
