#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR"

echo "Generating documentation for root module..."
# Generate terraform docs for root module using config file
terraform-docs -c .terraform-docs.yml .

# Post-process the README to convert ## headers to ### within the terraform-docs section
# This uses perl to find content between BEGIN_TF_DOCS and END_TF_DOCS markers
# and replace ## with ### only in that section
perl -i -pe '
    if (/<!-- BEGIN_TF_DOCS -->/ .. /<!-- END_TF_DOCS -->/) {
        s/^## /### /;
    }
' "$SCRIPT_DIR/README.md"

echo "Generating documentation for modules..."

# Generate documentation for each module
for module_dir in "$SCRIPT_DIR/modules"/*; do
    if [ -d "$module_dir" ]; then
        module_name=$(basename "$module_dir")
        echo "Generating documentation for module: $module_name"

        # Generate terraform docs for the module
        terraform-docs -c "$SCRIPT_DIR/.terraform-docs.yml" "$module_dir"

        # Post-process the module README to convert ## headers to ### within the terraform-docs section
        # perl -i -pe '
        #     if (/<!-- BEGIN_TF_DOCS -->/ .. /<!-- END_TF_DOCS -->/) {
        #         s/^## /### /;
        #     }
        # ' "$module_dir/README.md"
    fi
done

echo "Terraform documentation generated for root module and all modules."
