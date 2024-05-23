#!/bin/sh

set -xeu

# The branch or tag, e.g. "1.0-dev" or "1__0__0".
REF="$GITHUB_REF_NAME"
# The first path component, e.g. "infrastructure" or "profiles".
COMPONENT="${PATH_PREFIX%%/*}"

# If a git tag or live branch is pushed.
if [ "$PRODUCTION" = "true" ]; then
    PREFIX=""
    SUFFIX=-$(date +%s)
else
    PREFIX="staging/"
    SUFFIX=""
fi

curl --silent --connect-timeout 1 standard.open-contracting.org:8255 || true

# If a git tag isn't pushed, deploy the build directory from the git branch.
if [ "$RELEASE" != "true" ]; then
    curl --silent --connect-timeout 1 standard.open-contracting.org:8255 || true
    rsync -az --delete-after build/ ocds-docs@standard.open-contracting.org:web/"$PREFIX""$PATH_PREFIX""$REF""$SUFFIX"

    # Index the build directory.
    ocdsindex sphinx build/ https://standard.open-contracting.org/"$PREFIX""$PATH_PREFIX""$REF"/ > documents.json
    ocdsindex index https://standard.open-contracting.org:443/search/ documents.json
    if [ "$REF" = "$VERSION" ]; then
        ocdsindex sphinx build/ https://standard.open-contracting.org/"$PREFIX""$PATH_PREFIX"latest/ > documents.json
        ocdsindex index https://standard.open-contracting.org:443/search/ documents.json
    fi

    if [ "$PRODUCTION" = "true" ]; then
        # Symlink the live directory.
        curl --silent --connect-timeout 1 standard.open-contracting.org:8255 || true
        # shellcheck disable=SC2087
        ssh ocds-docs@standard.open-contracting.org /bin/bash <<- EOF
            mkdir -p /home/ocds-docs/web/$PREFIX$PATH_PREFIX
            ln -nfs $REF$SUFFIX /home/ocds-docs/web/$PREFIX$PATH_PREFIX$REF
		EOF
    fi
# If a git tag is pushed, create the schema directory and ZIP file.
else
    if [ "$COMPONENT" = "profiles" ]; then
        DIRECTORY="extension"
    else
        DIRECTORY="schema"
    fi

    # Deploy the schema files, codelist files and metadata file (if any).
    curl --silent --connect-timeout 1 standard.open-contracting.org:8255 || true
    # shellcheck disable=SC2087
    ssh ocds-docs@standard.open-contracting.org /bin/bash <<- EOF
        mkdir -p /home/ocds-docs/web/"$PATH_PREFIX""$DIRECTORY"/"$REF"/
        cp -r /home/ocds-docs/web/"$PATH_PREFIX""$VERSION"/en/*.json /home/ocds-docs/web/"$PATH_PREFIX""$DIRECTORY"/"$REF"/
        cp -r /home/ocds-docs/web/"$PATH_PREFIX""$VERSION"/en/codelists /home/ocds-docs/web/"$PATH_PREFIX""$DIRECTORY"/"$REF"/

        cd /home/ocds-docs/web/"$PATH_PREFIX""$DIRECTORY"/
        zip -r "$REF".zip "$REF"

        if [ "$COMPONENT" = "profiles" ]; then
            # Deploy the patched directory for the profile.
            mkdir -p /home/ocds-docs/web/"$PATH_PREFIX"schema/"$REF"/
            cp -r /home/ocds-docs/web/"$PATH_PREFIX""$VERSION"/en/_static/patched/* /home/ocds-docs/web/"$PATH_PREFIX"schema/"$REF"/
        fi
    # The following line must be indented with tabs.
	EOF
fi
