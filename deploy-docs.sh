#!/bin/sh

set -xeu

# The branch or tag, e.g. "1.0-dev" or "1__0__0".
ref="$GITHUB_REF_NAME"
# The first path component, e.g. "infrastructure" or "profiles".
component="${PATH_PREFIX%%/*}"
# The hostname, in case of proxy.
host_name=ocp19.open-contracting.org

# If a git tag or live branch is pushed.
if [ "$PRODUCTION" = "true" ]; then
    prefix=""
    suffix=-$(date +%s)
else
    prefix="staging/"
    suffix=""
fi

# If a git tag isn't pushed, deploy the build directory from the git branch.
if [ "$RELEASE" != "true" ]; then
    curl --silent --connect-timeout 1 $host_name:8255 || true
    rsync -az --delete-after build/ ocds-docs@$host_name:web/"$prefix""$PATH_PREFIX""$ref""$suffix"

    # Index the build directory.
    ocdsindex sphinx build/ https://standard.open-contracting.org/"$prefix""$PATH_PREFIX""$ref"/ > documents.json
    ocdsindex index https://standard.open-contracting.org:443/search/ documents.json
    if [ "$ref" = "$VERSION" ]; then
        ocdsindex sphinx build/ https://standard.open-contracting.org/"$prefix""$PATH_PREFIX"latest/ > documents.json
        ocdsindex index https://standard.open-contracting.org:443/search/ documents.json
    fi

    if [ "$PRODUCTION" = "true" ]; then
        # Symlink the live directory.
        curl --silent --connect-timeout 1 $host_name:8255 || true
        # shellcheck disable=SC2087
        ssh ocds-docs@$host_name /bin/bash <<- EOF
            mkdir -p /home/ocds-docs/web/$prefix$PATH_PREFIX
            ln -nfs $ref$suffix /home/ocds-docs/web/$prefix$PATH_PREFIX$ref
		EOF
    fi
# If a git tag is pushed, create the schema directory and ZIP file.
else
    if [ "$component" = "profiles" ]; then
        directory="extension"
    else
        directory="schema"
    fi

    # Deploy the schema files, codelist files and metadata file (if any).
    curl --silent --connect-timeout 1 $host_name:8255 || true
    # shellcheck disable=SC2087
    ssh ocds-docs@$host_name /bin/bash <<- EOF
        mkdir -p /home/ocds-docs/web/"$PATH_PREFIX""$directory"/"$ref"/
        cp -r /home/ocds-docs/web/"$PATH_PREFIX""$VERSION"/en/*.json /home/ocds-docs/web/"$PATH_PREFIX""$directory"/"$ref"/
        cp -r /home/ocds-docs/web/"$PATH_PREFIX""$VERSION"/en/codelists /home/ocds-docs/web/"$PATH_PREFIX""$directory"/"$ref"/

        cd /home/ocds-docs/web/"$PATH_PREFIX""$directory"/
        zip -r "$ref".zip "$ref"

        if [ "$component" = "profiles" ]; then
            # Deploy the patched directory for the profile.
            mkdir -p /home/ocds-docs/web/"$PATH_PREFIX"schema/"$ref"/
            cp -r /home/ocds-docs/web/"$PATH_PREFIX""$VERSION"/en/_static/patched/* /home/ocds-docs/web/"$PATH_PREFIX"schema/"$ref"/
        fi
    # The following line must be indented with tabs.
	EOF
fi
