#!/usr/bin/env bash

# This script runs awk to copy everything from `specification/2.0/extensions-urls.adoc`
# into several files. This allows us to have a single source of truth for extension URLs
# that works across both GitHub and Metanorma. GitHub _does not_ support the include
# directive, so this file gets us around that issue.
#
# To run, just run this script from your 3d-tiles repository directory.

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# The script works in this directory. All other paths should be relative to here.
SPEC_DIR="$SCRIPT_DIR/specification/2.0"

# This is where we copy from.
URL_SRC_FILE="./extension-urls.adoc"

# These are the files we copy to. Each of them has a special block.
DEST_FILES=(
    "./CONFORMANCE.adoc"
    "./glTF.adoc"
    "./Metadata/README.adoc"
    "./README.adoc"
    "./REFERENCES.adoc"
    "./Specification.adoc"
    "./Styling/README.adoc"
)

if pushd "$SPEC_DIR" > /dev/null; then
    for dest in "${DEST_FILES[@]}"; do
        if [ -f "$dest" ]; then
            awk -i inplace -v src="$URL_SRC_FILE" '
                $0 ~ "// GITHUB_URL_START" {
                    print
                    found = 0
                    while ((getline line < src) > 0) {
                        if (found) { print line }
                        if (line ~ "// COPY_STARTS_HERE") { found = 1 }
                    }
                    close(src)
                    skip = 1
                }
                $0 ~ "// GITHUB_URL_END" { skip = 0 }
                !skip
            ' "$dest"

            echo "Updated: $dest"
        else
            echo "Warning: $dest was not found!"
        fi
    done

    popd > /dev/null
    echo "Copy complete."
else
    echo "Error: pushd to $SPEC_DIR failed? Does the directory exist?"
    exit 1
fi
