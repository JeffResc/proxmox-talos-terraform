#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Change to the talos-template directory to run terraform-docs
cd "$SCRIPT_DIR"

# Generate terraform docs using config file
terraform-docs -c .terraform-docs.yml .

# Post-process the README to convert ## headers to ### within the terraform-docs section
# This uses perl to find content between BEGIN_TF_DOCS and END_TF_DOCS markers
# and replace ## with ### only in that section
perl -i -pe '
    if (/<!-- BEGIN_TF_DOCS -->/ .. /<!-- END_TF_DOCS -->/) {
        s/^## /### /;
    }
' "$SCRIPT_DIR/README.md"

echo "Terraform documentation generated."