if [ -z ${PATH_PREFIX+x} ]; then
    echo "\$PATH_PREFIX is not set, exiting."
    exit
fi

if [ -z "$SEARCH_SECRET" ]; then
    echo "\$SEARCH_SECRET is not set or empty, exiting."
    exit
fi

if [ -z "$LANGS" ]; then
    echo "\$LANGS is not set or empty, exiting."
    exit
fi

echo "Copy the built files to the remote server..."
rsync -av --delete-after -e "ssh bastion ssh" build/ ocds-docs@staging.standard.open-contracting.org:web/$PATH_PREFIX${GITHUB_REF##*/}

echo "Update the search index..."
curl "https://standard-search.open-contracting.org/v1/index_ocds?secret=${SEARCH_SECRET}&version=$(echo $PATH_PREFIX | sed 's/\//%2F/g')${GITHUB_REF##*/}&langs=${LANGS}"
