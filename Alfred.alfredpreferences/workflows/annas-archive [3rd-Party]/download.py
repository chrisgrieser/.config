import requests
from bs4 import BeautifulSoup
import sys
from pathlib import Path


def resolve_libgen_download_link(md5, title, filetype):
    link = f"http://libgen.li/ads.php?md5={md5}"
    response = requests.get(link)
    soup = BeautifulSoup(response.text, "html.parser")
    download_link = soup.find_all("a")
    download_link = (
        "http://libgen.li/"
        + [link["href"] for link in download_link if "get.php" in link["href"]][0]
    )
    if response.status_code == 200:
        download_path = str(Path.home() / "Downloads")
        with open(f"{download_path}/{title}{filetype}", "wb") as f:
            f.write(requests.get(download_link, allow_redirects=True).content)
        return f"Downloaded {title}{filetype}"


def main():
    md5, title, filetype = " ".join(sys.argv[1:]).split("#")
    try:
        print(resolve_libgen_download_link(md5, title, filetype))
    except Exception as e:
        print("Download failed. Please ensure the book source contains /lgli.")


if __name__ == "__main__":
    main()
