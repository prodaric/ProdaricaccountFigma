#!/usr/bin/env bash
# Download IFRS taxonomy packages (XSD/XML) into resources/.
# If the IFRS site returns HTML (e.g. terms/cookies), run the manual steps in resources/README.md.
set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESOURCES="$REPO_ROOT/resources"
TMP="${TMPDIR:-/tmp}"

is_zip() {
  local f="$1"
  test -f "$f" || return 1
  # ZIP magic: PK (50 4B)
  local magic
  magic=$(head -c 2 "$f" | od -An -tx1 | tr -d ' ')
  test "$magic" = "504b" || return 1
}

download_ifrs_accounting() {
  local url="https://www.ifrs.org/content/dam/ifrs/standards/taxonomy/ifrs-taxonomies/IFRSAT-2024-03-27_29.08.24.zip"
  local dest="$RESOURCES/ifrs-accounting-taxonomy"
  local zip="$TMP/IFRSAT-2024-03-27.zip"
  echo "Downloading IFRS Accounting Taxonomy 2024..."
  if ! curl -sL -A "Mozilla/5.0 (compatible; Prodaric/1.0)" -o "$zip" "$url"; then
    echo "Error: download failed." >&2
    return 1
  fi
  if ! is_zip "$zip"; then
    echo "The server returned a non-ZIP file (the site may require browser acceptance of terms)." >&2
    echo "Please download manually from: https://www.ifrs.org/issued-standards/ifrs-taxonomy/ifrs-accounting-taxonomy-2024" >&2
    rm -f "$zip"
    return 1
  fi
  echo "Extracting to $dest..."
  unzip -q -o "$zip" -d "$dest"
  rm -f "$zip"
  echo "IFRS Accounting Taxonomy 2024 ready in $dest"
}

download_ifrs_sustainability() {
  local url="https://www.ifrs.org/content/dam/ifrs/standards/sustainability-disclosure-taxonomy/2024/ifrssdt-2024-04-26.zip"
  local dest="$RESOURCES/ifrs-sustainability-taxonomy"
  local zip="$TMP/ifrssdt-2024-04-26.zip"
  echo "Downloading IFRS Sustainability Disclosure Taxonomy 2024..."
  if ! curl -sL -A "Mozilla/5.0 (compatible; Prodaric/1.0)" -o "$zip" "$url"; then
    echo "Error: download failed." >&2
    return 1
  fi
  if ! is_zip "$zip"; then
    echo "The server returned a non-ZIP file (the site may require browser acceptance of terms)." >&2
    echo "Please download manually from: https://www.ifrs.org/issued-standards/ifrs-sustainability-taxonomy/ifrs-sustainability-disclosure-taxonomy-2024" >&2
    rm -f "$zip"
    return 1
  fi
  echo "Extracting to $dest..."
  unzip -q -o "$zip" -d "$dest"
  rm -f "$zip"
  echo "IFRS Sustainability Disclosure Taxonomy 2024 ready in $dest"
}

mkdir -p "$RESOURCES/ifrs-accounting-taxonomy" "$RESOURCES/ifrs-sustainability-taxonomy"
download_ifrs_accounting || true
download_ifrs_sustainability || true
