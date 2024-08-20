# scihub-cli-downloader

This project is a shell and Python-based tool designed to retrieve and download academic papers from Sci-Hub. It dynamically fetches available Sci-Hub URLs, processes the article link, and automates the download process.

## Features

- **Dynamic URL Retrieval**: Automatically fetches the most up-to-date Sci-Hub URLs.
- **Robust Download Process**: Handles various methods of extracting the download link, ensuring high reliability.
- **Customizable**: Users can specify download directories and configure the maximum number of attempts.

## Requirements

- **Python 3.x**
- **Requests-HTML** library for Python
- **wget** or **curl** for downloading files

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/scihub-downloader.git
   cd scihub-cli-downloader
   ```

2. **Install Python dependencies:**

   ```bash
   pip install requests-html
   ```

3. **Make the scripts executable:**

   ```bash
   chmod +x scihub.py
   chmod +x download_from_scihub.sh
   ```

### Usage

Run the `download_from_scihub.sh` script with the necessary parameters:

```bash
./download_from_scihub.sh -u "https://doi.org/10.3847/1538-4365/acbc77"
```
or 

```bash
./download_from_scihub.sh -u "10.3847/1538-4365/acbc77"
```

**Optional flags:**

- `-d <download_directory>`: Specify the directory where the PDF will be saved (default is `~/Downloads`).
- `-m <max_attempts>`: Set the maximum number of attempts to try different Sci-Hub URLs (default is 6).

### Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Acknowledgments

This project was inspired by and built upon [Tony Wu’s Alfred Sci-Hub Workflow](https://github.com/TonyWu20/alfred-download-url-from-scihub-workflow/tree/main).
