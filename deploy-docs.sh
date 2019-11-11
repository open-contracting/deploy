if [ -z "$PRIVATE_KEY" ]; then
    echo "\$PRIVATE_KEY is not set or empty, exiting."
    exit
fi

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

echo "Create a private key from the environment variable..."
echo "$PRIVATE_KEY" | tr '#' '\n' | tr '_' ' ' > id_rsa
chmod 600 id_rsa

echo "Add the host key for the remote server..."
echo 'staging.standard.open-contracting.org ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDk8O226B/sYkPqyHdNBdjUFCEpT9IMdUxgFXEOtlPq1QnwTgHY76PsaOin7KhJcBrm8RAOuzoOIrKfgUJjXoxCtx1edp594tD8OChF5koHyO8YkQVlJmH8LrV16txsxokfh2F31ofRIVMk+TXiEfvR4+WehqeR24TwnXzlLIv1KfMJB7znTDdwqZS3uONKjlNNzSBNNIvCZ4WTI6etVlCzQgv4HL9QllKGfk1ctDuwOgsGPMT8f5NNPhI/z7kZkNbcrHJ5Mo6ZtF26qFmZ3Hy6vxJAQ2C4/x/Zemtb0MbIvI4Qlghh3bl5lER1rB54oMg+DidJ36qMrbqEtZxrBwvP' >> ~/.ssh/known_hosts

echo "Copy the built files to the remote server..."
rsync -av --delete-after -e "ssh -i id_rsa" build/ ocds-docs@staging.standard.open-contracting.org:web/$PATH_PREFIX$TRAVIS_BRANCH

echo "Update the search index..."
curl "https://standard-search.open-contracting.org/v1/index_ocds?secret=${SEARCH_SECRET}&version=$(echo $PATH_PREFIX | sed 's/\//%2F/g')${TRAVIS_BRANCH}&langs=${LANGS}"
