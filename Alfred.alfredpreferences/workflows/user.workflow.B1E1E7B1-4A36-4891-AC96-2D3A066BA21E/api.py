import requests
from bs4 import BeautifulSoup
import json
import sys
import os

KEYWORD = sys.argv[1]
CUSTOM_SUBTITLE = os.getenv("CUSTOM_SUBTITLE", "{0} | {1} | {2} | {3} | {4} | {5}")
LANGUAGES = os.getenv("LANGUAGES", None)  # Comma-separated list of languages
CUSTOM_SUBTITLE_VARIABLES = {
    "{0}": "authors",
    "{1}": "book_lang",
    "{2}": "book_filetype",
    "{3}": "book_source",
    "{4}": "book_size",
    "{5}": "book_content",
}
# fmt: off
AVAILABLE_LANGUAGES = [
    "en", "ru", "de", "es", "it", "zh", "fr", "hu", "ja", "pt", "la", "hi", 
    "nl", "lb", "bn", "ur", "id", "ar", "el", "he", "ko", "zxx", "bg", "pl", 
    "fa", "ta", "af", "tr", "uk", "kn", "sv", "da", "ro", "vi", "fil", "sa", 
    "ml", "mr", "cs", "hr", "grc", "sr", "ndl", "ga", "fi", "ca", "cy", "lv", 
    "jv", "bo", "lt", "cu", "be", "sce", "kk", "no", "mn", "ka", "sl", "eo", 
    "sk", "gl", "rw", "gu", "et", "az", "sve", "ms"
]
# fmt: on


def create_custom_subtitle(subtitle_format, variables, result):
    subtitle = subtitle_format
    for key, value in variables.items():
        if value in result:
            subtitle = subtitle.replace(key, result[value])
    return subtitle


def parse_sub_results(sub_results_text):
    parts = sub_results_text.split(",")
    if "[" in parts[0] and "]" in parts[0]:
        # The first element is the language
        book_lang = parts[0].strip()
        other_parts = parts[1:]
    else:
        # No language provided
        book_lang = "Unknown Language"
        other_parts = parts

    # Extract remaining parts
    book_filetype = (
        other_parts[0].strip() if len(other_parts) > 0 else "Unknown Filetype"
    )
    book_source = other_parts[1].strip() if len(other_parts) > 1 else "Unknown Source"
    book_size = other_parts[2].strip() if len(other_parts) > 2 else "Unknown Size"
    book_content = other_parts[3].strip() if len(other_parts) > 3 else "Unknown Content"

    return book_lang, book_filetype, book_source, book_size, book_content


def create_url(query, page=1, langs=None):
    lang_params = (
        "".join(
            [
                f"&lang={lang.strip()}"
                for lang in langs.split(",")
                if lang.strip() in AVAILABLE_LANGUAGES
            ]
        )
        if langs
        else ""
    )
    # check if the first word of the query is a language code
    live_lang_param = query.split(" ")[0]
    if live_lang_param in AVAILABLE_LANGUAGES and len(live_lang_param) <= 3:
        lang_params = f"&lang={live_lang_param}"
        query = " ".join(query.split(" ")[1:])
    return f"https://annas-archive.org/search?index=&page={page}&q={query}&sort={lang_params}"


def get_search_results(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, "html.parser")
    results = soup.find_all("div", class_="mb-4")

    search_results = []

    for result in results:
        # Find all divs with class "h-[125] flex flex-col justify-center" inside div with class "mb-4"
        h125_divs = result.find_all(
            "div", class_="h-[125] flex flex-col justify-center"
        )

        for h125_div in h125_divs:
            # Ensure the div is not inside a div with class "bg-gray-100 mx-[-10px] px-[10px] overflow-hidden"
            if (
                h125_div.find_parent(
                    class_="bg-gray-100 mx-[-10px] px-[10px] overflow-hidden"
                )
                is None
            ):
                link = "https://annas-archive.org" + h125_div.find("a")["href"]
                # download_link = (
                #   "https://annas-archive.org/slow_download/"
                #    + link.split("/")[-1]
                #    + "/0/2"
                # )
                sub_results = h125_div.find(
                    "div", class_="relative top-[-1] pl-4 grow overflow-hidden"
                )

                sub_results_text = sub_results.find("div").text
                book_lang, book_filetype, book_source, book_size, book_content = (
                    parse_sub_results(sub_results_text)
                )

                title = sub_results.find("h3").text

                authors = sub_results.find_all("div")[2].text
                # Make sure authors are not too long
                if len(authors) > 50:
                    authors = authors[:50] + "..."

                publication = sub_results.find_all("div")[1].text.split(";")

                search_results.append(
                    {
                        "link": link,
                        "title": title,
                        "authors": authors if authors else "Unknown Author",
                        "book_lang": book_lang,
                        "book_filetype": book_filetype,
                        "book_source": book_source,
                        "book_size": book_size,
                        "book_content": book_content,
                        "publication": publication,
                        "md5": link.split("/")[-1],
                    }
                )

    return search_results


def output_results(results):
    return json.dumps({"items": results})


def create_alfred_item(
    title, subtitle=None, arg=None, quicklookurl=None, md5=None, filetype=None
):
    return {
        "title": title,
        "subtitle": subtitle,
        "arg": arg,
        "quicklookurl": quicklookurl,
        "mods": {
            "cmd": {
                "valid": True,
                "arg": f"{md5}#{title}#{filetype}",
            }
        },
    }


def main(query, page=1, langs=None):
    url = create_url(query, page, langs)
    results = get_search_results(url)
    alfred_items = []
    if results:
        for result in results:
            custom_subtitle = create_custom_subtitle(
                CUSTOM_SUBTITLE, CUSTOM_SUBTITLE_VARIABLES, result
            )
            alfred_item = create_alfred_item(
                title=result["title"],
                subtitle=custom_subtitle,
                arg=result["link"],
                quicklookurl=result["link"],
                md5=result["md5"],
                filetype=result["book_filetype"],
            )
            alfred_items.append(alfred_item)
    else:
        alfred_items.append(
            create_alfred_item(
                title="No results found",
                subtitle="Look for partial matches",
                arg=url,
                quicklookurl=url,
            )
        )

    print(output_results(alfred_items))


if __name__ == "__main__":
    main(KEYWORD, langs=LANGUAGES)
