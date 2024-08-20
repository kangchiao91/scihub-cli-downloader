import re
import sys
from urllib.parse import urlparse
from requests_html import HTMLSession

def extract_doi_or_identifier(url: str) -> str:
    """Extracts the DOI or article identifier from the given URL."""
    parsed_url = urlparse(url)
    return parsed_url.path.strip('/')

def get_scihub_urls() -> list:
    """Retrieve Sci-Hub URLs from the webpage."""
    session = HTMLSession()
    try:
        base_page = session.get("https://www.sci-hub.pub/")
        base_page.raise_for_status()
    except Exception as e:
        print(f"Error accessing Sci-Hub site list: {e}", file=sys.stderr)
        sys.exit(1)

    urls = base_page.html.xpath("//div/ul/li/a/@href")
    if not urls:
        print("No Sci-Hub URLs found. The site structure may have changed.", file=sys.stderr)
        sys.exit(1)

    return urls

def get_download_link(doi_or_identifier: str, base_url: str) -> str:
    """Return download link from the given DOI or article identifier using the base Sci-Hub URL."""
    session = HTMLSession()
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    sci_hub_url = f"{base_url.rstrip('/')}/{doi_or_identifier.lstrip('/')}"

    try:
        response = session.get(sci_hub_url, headers=headers)
        response.raise_for_status()
    except Exception as e:
        print(f"Error fetching the page from {sci_hub_url}: {e}", file=sys.stderr)
        return None

    # Fallback method to find the download link
    embed_url = response.html.xpath("//iframe/@src | //embed/@src", first=True)
    if embed_url:
        if not embed_url.startswith("https://"):
            embed_url = f"https:{embed_url}"
        return embed_url

    print("Failed to find the download link using all methods.", file=sys.stderr)
    return None

def main(url: str):
    """Main function to get the download link from Sci-Hub."""
    print("Fetching available Sci-Hub URLs...", file=sys.stderr)
    scihub_urls = get_scihub_urls()
    print(f"Found {len(scihub_urls)} Sci-Hub URLs.", file=sys.stderr)

    doi_or_identifier = extract_doi_or_identifier(url)
    for base_url in scihub_urls:
        print(f"Attempting to use Sci-Hub URL: {base_url}", file=sys.stderr)
        download_url = get_download_link(doi_or_identifier, base_url)
        if download_url:
            print(download_url)  # Only print the URL to stdout
            return

    print("Failed to retrieve the download link after trying all available Sci-Hub URLs.", file=sys.stderr)
    sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python scihub.py <article_url>", file=sys.stderr)
        sys.exit(1)

    article_url = sys.argv[1]
    main(article_url)
