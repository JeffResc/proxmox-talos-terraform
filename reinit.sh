#!/usr/bin/env bash

# Clear all terraform.lock.hcl files
find . -type f -name "terraform.lock.hcl" -exec rm -f {} +

# Re-initialize the root Tofu modules
tofu init -upgrade

for dir in $(find ./modules -type d -depth 1 -print); do
  echo "Running tofu init in $dir"
  (cd "$dir" && tofu init)
done
