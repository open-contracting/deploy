import os
from urllib.parse import urlparse

import pytest
import requests

base_url = 'https://' + os.environ.get('FQDN', 'standard.open-contracting.org')

versions = [
    ('', ['latest', '1.0', '1.1-dev'], '/es/schema/release/'),
    ('/infrastructure', ['latest', '0.9-dev'], '/en/reference/schema/'),
    ('/profiles/ppp', ['latest', '1.0-dev'], '/es/reference/schema/'),
]

languages = [
    ('', ['en', 'es', 'fr', 'it'], '/schema/release/'),
    ('/infrastructure', ['en'], '/reference/schema/'),
    ('/profiles/ppp', ['en', 'es'], '/reference/schema/'),
]

banner_live = [
    ('', ['latest', '1.1']),
    ('/infrastructure', ['latest', '0.9']),
    ('/profiles/ppp', ['latest', '1.0']),
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


def test_json_charset():
    r = get(base_url + '/schema/1__1__0/release-schema.json')

    assert r.status_code == 200
    assert r.headers['Content-Type'] == 'application/json; charset=utf-8'


@pytest.mark.parametrize('root, version', [
    (root, versions[0]) for root, versions, path in versions
])
def test_add_version(root, version):
    for suffix in ('', '/'):
        r = get('{}{}'.format(base_url, root, suffix))

        assert r.status_code == 302
        assert r.headers['Location'] == '{}{}/{}/'.format(base_url, root, version)


@pytest.mark.parametrize('root, version', [
    (root, version) for root, versions, path in versions for version in versions
])
def test_add_language(root, version):
    r = get('{}{}/{}/'.format(base_url, root, version))

    assert r.status_code == 302
    assert r.headers['Location'] == '{}{}/{}/en/'.format(base_url, root, version)


@pytest.mark.parametrize('root, version', [
    (root, version) for root, versions, path in versions for version in versions if not version.endswith('-dev')
])
def test_add_trailing_slash_per_version(root, version):
    r = get('{}{}/{}'.format(base_url, root, version))

    assert r.status_code == 301
    assert r.headers['Location'] == '{}{}/{}/'.format(base_url, root, version)

    r = get('{}{}/{}/en'.format(base_url, root, version))

    assert r.status_code == 301
    assert r.headers['Location'] == '{}{}/{}/en/'.format(base_url, root, version)


@pytest.mark.parametrize('root, lang', [
    (root, lang) for root, languages, path in languages for lang in languages
])
def test_add_trailing_slash_per_lang(root, lang):
    r = get('{}{}/latest/{}'.format(base_url, root, lang))

    assert r.status_code == 301
    assert r.headers['Location'] == '{}{}/latest/{}/'.format(base_url, root, lang)


def test_version_switcher_legacy():
    r = get(base_url + '/switcher?branch=legacy/r/0__1__0')

    assert r.status_code == 302
    assert r.headers['Location'] == '{}/legacy/r/0__1__0'.format(base_url)


def test_version_switcher_legacy_with_referer():
    r = get(base_url + '/switcher?branch=legacy/r/0__1__0',
            headers={'Referer': base_url + '/latest/es/schema/release/'})

    assert r.status_code == 302
    assert r.headers['Location'] == '{}/legacy/r/0__1__0'.format(base_url)


@pytest.mark.parametrize('root, version', [
    (root, version) for root, versions, path in versions for version in versions
])
def test_version_switcher(root, version):
    r = get('{}{}/switcher?branch={}'.format(base_url, root, version))

    assert r.status_code == 302
    assert r.headers['Location'] == '{}{}/{}'.format(base_url, root, version)


@pytest.mark.parametrize('root, version, path', [
    (root, version, path) for root, versions, path in versions for version in versions if not version.endswith('-dev')
])
def test_version_switcher_with_referer(root, version, path):
    r = get('{}{}/switcher?branch={}'.format(base_url, root, version),
            headers={'Referer': '{}{}/latest{}'.format(base_url, root, path)})

    assert r.status_code == 302
    assert r.headers['Location'] == '{}{}/{}{}'.format(base_url, root, version, path)


@pytest.mark.parametrize('root, lang', [
    (root, lang) for root, languages, path in languages for lang in languages
])
def test_language_switcher(root, lang):
    r = get('{}{}/latest/switcher?lang={}'.format(base_url, root, lang))

    assert r.status_code == 302
    assert r.headers['Location'] == '{}{}/latest/{}'.format(base_url, root, lang)


@pytest.mark.parametrize('root, lang, path', [
    (root, lang, path) for root, languages, path in languages for lang in languages
])
def test_language_switcher_with_referer(root, lang, path):
    r = get('{}{}/latest/switcher?lang={}'.format(base_url, root, lang),
            headers={'Referer': '{}{}/latest/en{}'.format(base_url, root, path)})

    assert r.status_code == 302
    assert r.headers['Location'] == '{}{}/latest/{}{}'.format(base_url, root, lang, path)


@pytest.mark.parametrize('root, lang', [
    (root, lang) for root, languages, path in languages for lang in languages
])
def test_404(root, lang):
    r = get('{}{}/latest/{}/path/to/nonexistent/'.format(base_url, root, lang))

    assert r.status_code == 404
    assert '"{}/latest/{}/"'.format(root, lang) in r.text


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
    (root, versions[-1]) for root, versions, path in versions
])
def test_banner_staging(root, version):
    r = get('{}{}/{}/en/'.format(base_url, root, version))

    assert r.status_code == 200
    assert 'This is an old version of ' not in r.text
    assert 'This is a development copy of ' in r.text


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
