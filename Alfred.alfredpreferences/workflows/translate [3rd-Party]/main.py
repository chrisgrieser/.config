#!/usr/bin/python

import json
from typing import List
import urllib.parse
import random
import http.client
import sys
import os


class Translate:
    """
    Translate API
    Thanks to Telegram MacOS client for the idea

    https://github.com/TelegramOrg/Telegram-macos-Swift/blob/67e4cf8de2f060ec8152ce68562c9489a6073534/packages/Translate/Sources/Translate/Translate.swift
    """

    languages = {
        "af",
        "sq",
        "am",
        "ar",
        "hy",
        "as",
        "ay",
        "az",
        "bm",
        "eu",
        "be",
        "bn",
        "bho",
        "bs",
        "bg",
        "ca",
        "ceb",
        "zh-CN",
        "zh-TW",
        "co",
        "hr",
        "cs",
        "da",
        "dv",
        "doi",
        "nl",
        "en",
        "eo",
        "et",
        "ee",
        "fil",
        "fi",
        "fr",
        "fy",
        "gl",
        "ka",
        "de",
        "el",
        "gn",
        "gu",
        "ht",
        "ha",
        "haw",
        "he",
        "hi",
        "hmn",
        "hu",
        "is",
        "ig",
        "ilo",
        "id",
        "ga",
        "it",
        "ja",
        "jv",
        "kn",
        "kk",
        "km",
        "rw",
        "gom",
        "ko",
        "kri",
        "ku",
        "ckb",
        "ky",
        "lo",
        "la",
        "lv",
        "ln",
        "lt",
        "lg",
        "lb",
        "mk",
        "mai",
        "mg",
        "ms",
        "ml",
        "mt",
        "mi",
        "mr",
        "mni-Mtei",
        "lus",
        "mn",
        "my",
        "ne",
        "no",
        "ny",
        "or",
        "om",
        "ps",
        "fa",
        "pl",
        "pt",
        "pa",
        "qu",
        "ro",
        "ru",
        "sm",
        "sa",
        "gd",
        "nso",
        "sr",
        "st",
        "sn",
        "sd",
        "si",
        "sk",
        "sl",
        "so",
        "es",
        "su",
        "sw",
        "sv",
        "tl",
        "tg",
        "ta",
        "tt",
        "te",
        "th",
        "ti",
        "ts",
        "tr",
        "tk",
        "ak",
        "uk",
        "ur",
        "ug",
        "uz",
        "vi",
        "cy",
        "xh",
        "yi",
        "yo",
        "zu",
    }


    user_agent = [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:94.0) Gecko/20100101 Firefox/94.0",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:95.0) Gecko/20100101 Firefox/95.0",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.55 Safari/537.36"
    ]

    def __init__(self, lang: str = "en"):
        if lang not in self.languages:
            raise ValueError(f"Language {lang} is not supported")
        self.lang = lang

    @classmethod
    def _get_user_agent(cls):
        return random.choice(cls.user_agent)

    def _generate_url(self, text):
        text_encoded = urllib.parse.quote(text)
        return "translate.goo" + \
            "gleapis.c" + \
            "om", "/tr" + \
            "anslate_a" + \
            "/singl" + \
            f"e?client=gtx&sl=auto&tl={self.lang}&dt=t&ie=UTF-8&oe=UTF-8&otf=1&ssel=0&tsel=0&kc=7&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&q={text_encoded}"

    def _get_request(self, text):
        url, path = self._generate_url(text)
        conn = http.client.HTTPSConnection(url)
        headers = {
            "User-Agent": self._get_user_agent(),
        }
        conn.request("GET", path, headers=headers)
        res = conn.getresponse()
        if res.status != 200:
            raise RuntimeError(f"HTTP Error: {res.status}")
        return json.loads(res.read())

    def _parse_response(self, data: List) -> List[str]:
        if data[1] is None:
            return data[2], [data[0][0][0]]
        return data[2], data[1][0][1]

    def get_translation(self, text: str):
        return self._parse_response(self._get_request(text))


def generate_worflow_output(translations: List[str]):
    return json.dumps({
        "items": [
            {
                "title": translation,
                "subtitle": "",
                "arg": translation,
            }
            for translation in translations
        ]
    }, ensure_ascii=False)


if __name__ == "__main__":
    text_list = sys.argv[1:]
    out_lang = os.environ["output_language"]
    in_lang = os.environ["input_language"]

    recognised_lang, translate = Translate(
        out_lang).get_translation(' '.join(text_list))
    if recognised_lang == out_lang:
        _, translate = Translate(
            in_lang).get_translation(' '.join(text_list))

    print(generate_worflow_output(translate))
