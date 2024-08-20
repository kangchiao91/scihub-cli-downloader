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
        sys.stderr.write(f"Error accessing Sci-Hub site list: {e}\n")
        sys.exit(1)

    urls = base_page.html.xpath("//div/ul/li/a/@href")
    if not urls:
        sys.stderr.write("No Sci-Hub URLs found. The site structure may have changed.\n")
        sys.exit(1)

    return urls

def get_download_link_and_title(doi_or_identifier: str, base_url: str) -> tuple:
    """Return download link and title from the given DOI or article identifier using the base Sci-Hub URL."""
    session = HTMLSession()
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    sci_hub_url = f"{base_url.rstrip('/')}/{doi_or_identifier.lstrip('/')}"

    try:
        response = session.get(sci_hub_url, headers=headers)
        response.raise_for_status()  # Check for HTTP errors
    except Exception as e:
        sys.stderr.write(f"Error fetching the page from {sci_hub_url}: {e}\n")
        return None, None

    # Extract the paper title from the HTML
    title = response.html.xpath("//title/text()", first=True)
    if title:
        # Remove "Sci-Hub | " from the title
        title = title.replace("Sci-Hub | ", "")
        # Remove anything resembling a DOI at the end of the title
        title = re.sub(r'\s+\d{2,}\S*$', '', title)
        # Clean the title for safe filename usage
        title = re.sub(r'[^\w\s-]', '', title).strip()

    # Attempt to find the download link from iframe/embed tags or any potential direct links
    embed_url = response.html.xpath("//iframe/@src | //embed/@src", first=True)
    if embed_url:
        # Ensure the URL has the correct scheme
        if not embed_url.startswith("http"):
            embed_url = f"https:{embed_url}"
        return embed_url, title

    return None, title



def main(url: str):
    """Main function to get the download link and title from Sci-Hub."""
    scihub_urls = get_scihub_urls()

    doi_or_identifier = extract_doi_or_identifier(url)
    for base_url in scihub_urls:
        download_url, title = get_download_link_and_title(doi_or_identifier, base_url)
        if download_url:
            print(download_url)  # Only print the download URL to stdout
            if title:
                print(title)  # Print the title on a new line if available
            return

    sys.exit(1)  # Exit with an error code if no URL is found

if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.stderr.write("Usage: python scihub.py <article_url>\n")
        sys.exit(1)

    article_url = sys.argv[1]
    main(article_url)
