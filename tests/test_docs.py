import os
from urllib.parse import urlparse

import pytest
import requests

fqdn = os.environ.get('FQDN', 'standard.open-contracting.org')
base_url = 'https://' + fqdn

versions = {
    '': (['latest', '1.0', '1.1-dev'], '/es/schema/release/'),
    '/infrastructure': (['latest', '0.9-dev'], '/en/reference/schema/'),
    '/profiles/eu': (['master'], '/en/reference/'),
    '/profiles/ppp': (['latest', '1.0-dev'], '/es/reference/schema/'),
}

languages = {
    '': (['en', 'es', 'fr', 'it'], '/schema/release/'),
    '/infrastructure': (['en'], '/reference/schema/'),
    '/profiles/eu': (['en'], '/reference/'),
    '/profiles/ppp': (['en', 'es'], '/reference/schema/'),
}

banner_live = [
    ('', ['latest', '1.1']),
    ('/infrastructure', ['latest', '0.9']),
    ('/profiles/ppp', ['latest', '1.0']),
    ('/profiles/eu', ['master']),
]
banner_old = [
    ('', ['1.0']),
]


def get(url, **kwargs):
    return requests.get(url, allow_redirects=False, **kwargs)


@pytest.mark.parametrize('url', [
    'http://standard.open-contracting.org/switcher?branch=latest',
    'http://standard.open-contracting.org/latest/switcher?lang=en',
])
def test_force_https(url):
    r = get(url)

    assert r.status_code == 302
    assert r.headers['Location'] == urlparse(url)._replace(scheme='https').geturl()


def test_robots_txt():
    r = get('https://testing.live.standard.open-contracting.org/robots.txt')

    assert r.status_code == 200
    assert r.text == 'User-agent: *\nDisallow: / \n'

    r = get('https://standard.open-contracting.org/robots.txt')

    assert r.status_code == 200
    assert 'Googlebot' in r.text


def test_json_headers():
    r = get(base_url + '/schema/1__1__0/release-schema.json')

    assert r.status_code == 200
    assert r.headers['Content-Type'] == 'application/json; charset=utf-8'
    assert r.headers['Access-Control-Allow-Origin'] == '*'


@pytest.mark.parametrize('root, version', [
    (root, vers[0]) for root, (vers, path) in versions.items()
])
def test_add_version(root, version):
    for suffix in ('', '/'):
        r = get('{}{}'.format(base_url, root, suffix))

        assert r.status_code == 302
        assert r.headers['Location'] == '{}{}/{}/'.format(base_url, root, version)


@pytest.mark.parametrize('root, version', [
    (root, version) for root, (vers, path) in versions.items() for version in vers
])
def test_add_language(root, version):
    for suffix in ('', '/'):
        r = get('{}{}/{}{}'.format(base_url, root, version, suffix))

        assert r.status_code == 302
        assert r.headers['Location'] == '{}{}/{}/en/'.format(base_url, root, version)


@pytest.mark.parametrize('root, version, lang', [
    (root, version, lang) for root, (langs, path) in languages.items() for lang in langs
    for version in versions[root][0] if version != '1.0' or lang != 'it'  # OCDS 1.0 isn't available in IT
])
def test_add_trailing_slash_per_lang(root, version, lang):
    r = get('{}{}/{}/{}'.format(base_url, root, version, lang))

    # With DirectorySlash On, development branches get redirected to staging server.
    if version.endswith('-dev'):
        assert r.status_code == 301
        assert r.headers['Location'] == 'https://staging.standard.open-contracting.org{}/{}/{}/'.format(root, version, lang)  # noqa
    else:
        assert r.status_code == 301
        assert r.headers['Location'] == '{}{}/{}/{}/'.format(base_url, root, version, lang)


def test_add_trailing_slash_to_profiles():
    r = get(base_url + '/profiles')

    # With DirectorySlash On, development branches get redirected to staging server.
    assert r.status_code == 301
    assert r.headers['Location'] == 'https://staging.standard.open-contracting.org/profiles/'


def test_profiles():
    r = get(base_url + '/profiles/')

    assert r.status_code == 200
    assert 'Parent Directory' in r.text


def test_version_switcher_legacy():
    r = get(base_url + '/switcher?branch=legacy/r/0__1__0')

    assert r.status_code == 302
    assert r.headers['Location'] == '{}/legacy/r/0__1__0/'.format(base_url)


def test_version_switcher_legacy_with_referer():
    r = get(base_url + '/switcher?branch=legacy/r/0__1__0',
            headers={'Referer': base_url + '/latest/es/schema/release/'})

    assert r.status_code == 302
    assert r.headers['Location'] == '{}/legacy/r/0__1__0/'.format(base_url)


@pytest.mark.parametrize('root, version', [
    (root, version) for root, (vers, path) in versions.items() for version in vers
])
def test_version_switcher(root, version):
    r = get('{}{}/switcher?branch={}'.format(base_url, root, version))

    assert r.status_code == 302
    assert r.headers['Location'] == '{}{}/{}/'.format(base_url, root, version)


@pytest.mark.parametrize('root, version, path', [
    (root, version, path) for root, (vers, path) in versions.items() for version in vers
])
def test_version_switcher_with_referer(root, version, path):
    r = get('{}{}/switcher?branch={}'.format(base_url, root, version),
            headers={'Referer': '{}{}/latest{}'.format(base_url, root, path)})

    if root == '' and version.endswith('-dev'):  # unstable sitemap
        expected = '{}{}/{}/'.format(base_url, root, version)
    else:
        expected = '{}{}/{}{}'.format(base_url, root, version, path)

    assert r.status_code == 302
    assert r.headers['Location'] == expected


@pytest.mark.parametrize('root, version, lang', [
    (root, version, lang) for root, (langs, path) in languages.items() for lang in langs
    for version in versions[root][0]
])
def test_language_switcher(root, version, lang):
    r = get('{}{}/{}/switcher?lang={}'.format(base_url, root, version, lang))

    assert r.status_code == 302
    assert r.headers['Location'] == '{}{}/{}/{}/'.format(base_url, root, version, lang)


@pytest.mark.parametrize('root, version, lang, path', [
    (root, version, lang, path) for root, (langs, path) in languages.items() for lang in langs
    for version in versions[root][0]
])
def test_language_switcher_with_referer(root, version, lang, path):
    r = get('{}{}/{}/switcher?lang={}'.format(base_url, root, version, lang),
            headers={'Referer': '{}{}/{}/en{}'.format(base_url, root, version, path)})

    assert r.status_code == 302
    assert r.headers['Location'] == '{}{}/{}/{}{}'.format(base_url, root, version, lang, path)


@pytest.mark.parametrize('root, version, lang', [
    (root, version, lang) for root, (langs, path) in languages.items() for lang in langs
    for version in versions[root][0] if version != '1.0' or lang != 'it'  # OCDS 1.0 isn't available in IT
])
def test_custom_404(root, version, lang):
    r = get('{}{}/{}/{}/path/to/nonexistent/'.format(base_url, root, version, lang))

    if version.endswith('-dev'):
        expected = '"error_redirect/"'
    else:
        expected = '"{}/{}/{}/"'.format(root, version, lang)

    assert r.status_code == 404
    assert expected in r.text

    if version.endswith('-dev'):
        r = get('{}{}/{}/{}/path/to/nonexistent/error_redirect/'.format(base_url, root, version, lang))

        assert r.status_code == 302
        assert r.headers['Location'] == '{}{}/{}/{}/'.format(base_url, root, version, lang)


def test_default_404():
    r = get(base_url + '/latest/eo/')

    assert r.status_code == 404
    assert 'at {} '.format(fqdn) in r.text


# As long as no branch is named "schema" or "extension", this also serves to test no proxy.
@pytest.mark.parametrize('path', [
    '/schema/',
    '/infrastructure/schema/',
    '/profiles/ppp/schema/',
    '/profiles/ppp/extension/',
])
def test_no_redirect(path):
    r = get(base_url + path)

    assert r.status_code == 200


@pytest.mark.parametrize('root, text', [
    ('', 'OCDS'),
    ('/infrastructure', 'OC4IDS'),
])
def test_review(root, text):
    r = get('{}{}/review/'.format(base_url, root))

    assert r.status_code == 200
    assert text in r.text

    r = get('{}{}/static/dataexplore/css/style.css'.format(base_url, root))

    assert r.status_code == 200
    assert 'color:' in r.text


@pytest.mark.parametrize('root, version', [
    (root, version) for root, versions in banner_live for version in versions
])
def test_banner_live(root, version):
    r = get('{}{}/{}/en/'.format(base_url, root, version))

    assert r.status_code == 200
    assert 'This is an old version of ' not in r.text
    assert 'This is a development copy of ' not in r.text


@pytest.mark.parametrize('root, version', [
    (root, version) for root, versions in banner_old for version in versions
])
def test_banner_old(root, version):
    r = get('{}{}/{}/en/'.format(base_url, root, version))

    assert r.status_code == 200
    assert 'This is an old version of ' in r.text
    assert 'This is a development copy of ' not in r.text


@pytest.mark.parametrize('root, version', [
    (root, vers[-1]) for root, (vers, path) in versions.items()
])
def test_banner_staging(root, version):
    r = get('{}{}/{}/en/'.format(base_url, root, version))

    assert r.status_code == 200
    assert 'This is an old version of ' not in r.text
    assert 'This is a development copy of ' in r.text

    if root != '/infrastructure':  # OC4IDS doesn't have its own banner
        assert '<a href="{}/latest/en/">'.format(root) in r.text


def test_banner_staging_profiles():
    r = get(base_url + '/profiles/gpa/master/en/')

    assert r.status_code == 200
    assert 'This profile is in development ' in r.text
    assert 'This is an old version of ' not in r.text
    assert 'This is a development copy of ' not in r.text


@pytest.mark.parametrize('path, location', [
    ('/feed', 'https://www.open-contracting.org/feed/'),
    ('/beta', 'https://www.open-contracting.org/2014/09/04/beta'),
    ('/project', '{}/latest/en/'.format(base_url)),
    ('/validator', '{}/review'.format(base_url)),
    ('/validator/data/1232ec83-48ac-45cb-923d-1f67701488ef',
     '{}/review/data/1232ec83-48ac-45cb-923d-1f67701488ef'.format(base_url)),
    # Redirects to extensions.open-contracting.org.
    ('/1.1/es/extensions/community/', 'https://extensions.open-contracting.org/es/extensions/'),
    ('/profiles/ppp/1.0/es/extensions/bids/', 'https://extensions.open-contracting.org/es/extensions/bids/'),
])
def test_redirect(path, location):
    r = get(base_url + path)

    assert r.status_code == 302
    assert r.headers['Location'] == location
