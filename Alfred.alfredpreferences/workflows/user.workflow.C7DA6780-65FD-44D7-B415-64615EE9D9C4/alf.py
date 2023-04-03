#!/usr/bin/python3

import os

from Alfred3 import Items, Tools
from Workflows import Workflows


class KeywordFormatter(object):

    def __init__(self):
        """Formatted list of Alfred keyboard shortcuts
        """
        self.keywords = list()
        self.keyb_shortcuts = list()

    def has_keywords(self) -> bool:
        """
        Check if object has keyword entries

        Returns:
            boolean: true, if object has keywords otherwise false
        """
        return True if self.keywords else False

    def add_keyb(self, keyb: str) -> None:
        """Add Keyboard Shortcuts entry to Formatter

        Args:
            keyb (string): Keyboard shorcut item
        """
        if keyb != str():
            self.keyb_shortcuts.append([keyb])

    def add_keyword_title(self, keyword: str, title: str) -> None:
        """Add a alfred keyword, title pair

        Args:
            keyword (str): Alfred workflow step string
            title (str): Description
        """
        keyword = keyword if keyword else str()
        title = title if keyword else str()
        title = title.replace('{query}', 'QUERY')
        if keyword != str():
            self.keywords.append([keyword, title])

    def get_keywords_scriptfilter(self) -> str:
        """Generate Content for showing in Alfred scripfilter

        Returns:
            str: Formatted content
        """
        output_keywords = list()
        for i in self.keywords:
            output_keywords.append(i[0])
        return '; '.join(output_keywords) if len(output_keywords) > 0 else " (n/a)"

    def get_keywords_md(self) -> str:
        """Generate Markdown content for showing in Quicklook file

        Returns:
            string: Formatted MD content
        """
        formatted_keywords = list()
        result = str()
        for i in self.keywords:
            formatted_keywords.append(f"**{i[0]}** - {i[1]}")
        for i in formatted_keywords:
            result += f"* {i}\n"
        return result if self.keywords else "* n/a"

    def get_keyboard_shortcuts(self) -> list:
        """
        Return list of Keyboard shortcuts

        Returns:
            list: List with keyboard shortcuts
        """
        res = list()
        for k in self.keyb_shortcuts:
            if k[0]:
                res.append(k[0])
        return res

    def get_keyb_md(self) -> str:
        """Generate keyboard shortcut list

        Returns:
            string: formatted MD content
        """
        formatted_keyb = list()
        result = str()
        for k in self.get_keyboard_shortcuts():
            formatted_keyb.append(f"* {k}\n")
        for fk in formatted_keyb:
            result += f"{fk}\n"
        return result if len(self.keyb_shortcuts) > 0 else None


def clean_cache() -> None:
    """Remove all .md files in cache directory
    """
    cache_dir = get_cache_directory()
    file_list = os.listdir(cache_dir)
    for f in file_list:
        if f.endswith('.md'):
            f_path = os.sep.join([cache_dir, f])
            os.remove(f_path)


def get_cache_directory() -> str:
    """Get Alfreds Cache Directory, if not existent the directory will be created

    Returns:
        str: Cache Directory
    """
    target_dir = Tools.getEnv('alfred_workflow_cache')
    if not (os.path.isdir(target_dir)):
        os.mkdir(target_dir)
    return target_dir


def create_hint_file(wf_dir: str, content: str) -> str:
    """Creates hint file.md in workflow cache

    Args:
        wf_dir (str): Directory name of a specific workflow
        content (str): content to write into md file

    Returns:
        str: Target file path for quicklookurl
    """
    target_dir = get_cache_directory()
    spath = os.path.normpath(wf_dir).split(os.sep)
    wf_dir_name = ''.join(
        [i for i in spath if str(i).startswith('user.workflow')])
    if wf_dir_name != str():
        target_file = f"{target_dir}/{wf_dir_name}.md"
        with open(target_file, "wb+") as f:
            f.write(content)
            return target_file


Tools.logPyVersion()
Workflows = Workflows()
query = Tools.getArgv(1)
matches = Workflows.get_workflows() if query == str(
) else Workflows.search_in_workflows(query)

clean_cache()
alf = Items()
if len(matches) > 0:
    for m in matches:
        # init Keyword and Keyboard text formatter for markdown output
        kf = KeywordFormatter()
        # WF description
        description = m.get('description') if m.get('description') else ' - '
        # WF name
        name = m.get('name')
        # Read WF keyboard shortcuts
        keyb_list = m.get('keyb')
        for k in keyb_list:
            note = k.get('note')
            keyb = k.get('keyb')
            kf.add_keyb(f'{keyb} : {note}')
        # Get list of keywords
        keyword_list = m.get('keywords')
        info_plist_path = m.get('path')
        wf_path = os.path.dirname(info_plist_path)
        for kitem in keyword_list:
            keyword = kitem.get('keyword')
            text = kitem.get('text') if kitem.get('text') else str()
            title = kitem.get('title') if kitem.get('title') else text
            kf.add_keyword_title(keyword, title)
        # Create Content for md file
        content = ((
            "# %s\n"
            "\n"
            "### Description\n"
            "* %s\n"
            "\n"
            "### Keywords\n"
            "%s"
        ) % (name, description, kf.get_keywords_md())).encode('utf-8')
        # Add keyboard shortcuts if available to the md content
        if kf.get_keyb_md():
            # content += ("\n\n### Shortcuts\n%s" % (kf.get_keyb_md())).encode('utf-8')
            content += f"\n\n### Shortcuts\n{kf.get_keyb_md()}".encode('utf-8')

        # Quicklook file URL
        quicklook_url = create_hint_file(wf_path, content)
        ip = wf_path + "/icon.png"
        # use default icon in alf WF directory in case searched wf has not icon defined
        icon_path = ip if os.path.isfile(ip) else 'icon.png'
        keyword_text = kf.get_keywords_scriptfilter()
        valid = kf.has_keywords()
        subtitle = description + \
            u', Keywords: ' + \
            keyword_text if valid else description
        # if len(kf.get_keyboard_shortcuts()) > 0:
        #    subtitle += ", Keyboard: " + ",".join(kf.get_keyboard_shortcuts())
        arg = os.path.dirname(info_plist_path) + "|" + name
        alf.setItem(
            title=name,
            subtitle=subtitle,
            arg=arg,
            automcomplete=name,
            valid=valid,
            quicklookurl=quicklook_url
        )
        alf.setIcon(icon_path, m_type="image")
        alf.addMod(
            'cmd',
            subtitle='Choose Action...',
            arg=arg,
            icon_path='icons/start.png',
            icon_type='image',
            valid=True
        )
        alf.addItem()
else:
    alf.setItem(
        title='No Workflow matches the search query!',
        subtitle=f"...for query: \"{query}\"",
        valid=False
    )
    alf.addItem()
alf.write()
