import os
from urllib.parse import urlparse

import pytest
import requests

fqdn = os.environ.get('FQDN', 'standard.open-contracting.org')
base_url = f'https://{fqdn}'

versions = {
    '': (['latest', '1.0', '1.1-dev'], '/es/schema/release/'),
    '/infrastructure': (['latest', '0.9-dev'], '/en/reference/schema/'),
    '/profiles/eu': (['master'], '/en/reference/'),
    '/profiles/gpa': (['master'], '/en/reference/'),
    '/profiles/ppp': (['latest', '1.0-dev'], '/es/reference/schema/'),
}

languages = {
    '': (['en', 'es', 'fr', 'it'], '/schema/release/'),
    '/infrastructure': (['en'], '/reference/schema/'),
    '/profiles/eu': (['en'], '/reference/'),
    '/profiles/gpa': (['en'], '/reference/'),
    '/profiles/ppp': (['en', 'es'], '/reference/schema/'),
}

banner_live = [
    ('', ['latest', '1.1']),
    ('/infrastructure', ['latest', '0.9']),
    ('/profiles/eu', ['master']),
    ('/profiles/gpa', ['master']),
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


def test_json_headers():
    r = get(f'{base_url}/schema/1__1__0/release-schema.json')

    assert r.status_code == 200
    assert r.headers['Content-Type'] == 'application/json; charset=utf-8'
    assert r.headers['Access-Control-Allow-Origin'] == '*'


@pytest.mark.parametrize('root, version', [
    (root, vers[0]) for root, (vers, path) in versions.items()
])
def test_add_version(root, version):
    for suffix in ('', '/'):
        r = get(f'{base_url}{root}{suffix}')

        assert r.status_code == 302
        assert r.headers['Location'] == f'{base_url}{root}/{version}/'


@pytest.mark.parametrize('root, version', [
    (root, version) for root, (vers, path) in versions.items() for version in vers
])
def test_add_language(root, version):
    for suffix in ('', '/'):
        r = get(f'{base_url}{root}/{version}{suffix}')

        assert r.status_code == 302
        assert r.headers['Location'] == f'{base_url}{root}/{version}/en/'


@pytest.mark.parametrize('root, version, lang', [
    (root, version, lang) for root, (langs, path) in languages.items() for lang in langs
    for version in versions[root][0] if version != '1.0' or lang != 'it'  # OCDS 1.0 isn't available in IT
])
def test_add_trailing_slash_per_lang(root, version, lang):
    r = get(f'{base_url}{root}/{version}/{lang}')

    # With DirectorySlash On, development branches get redirected to staging server.
    if version.endswith('-dev'):
        assert r.status_code == 301
        assert r.headers['Location'] == f'https://staging.standard.open-contracting.org{root}/{version}/{lang}/'
    else:
        assert r.status_code == 301
        assert r.headers['Location'] == f'{base_url}{root}/{version}/{lang}/'


def test_add_trailing_slash_to_profiles():
    r = get(f'{base_url}/profiles')

    assert r.status_code == 301
    assert r.headers['Location'] == 'https://standard.open-contracting.org/profiles/'


def test_profiles():
    r = get(f'{base_url}/profiles/')

    assert r.status_code == 200
    assert 'Parent Directory' in r.text


def test_version_switcher_legacy():
    r = get(f'{base_url}/switcher?branch=legacy/r/0__1__0')

    assert r.status_code == 302
    assert r.headers['Location'] == f'{base_url}/legacy/r/0__1__0/'


def test_version_switcher_legacy_with_referer():
    r = get(f'{base_url}/switcher?branch=legacy/r/0__1__0',
            headers={'Referer': f'{base_url}/latest/es/schema/release/'})

    assert r.status_code == 302
    assert r.headers['Location'] == f'{base_url}/legacy/r/0__1__0/'


@pytest.mark.parametrize('root, version', [
    (root, version) for root, (vers, path) in versions.items() for version in vers
])
def test_version_switcher(root, version):
    r = get(f'{base_url}{root}/switcher?branch={version}')

    assert r.status_code == 302
    assert r.headers['Location'] == f'{base_url}{root}/{version}/'


@pytest.mark.parametrize('root, version, path', [
    (root, version, path) for root, (vers, path) in versions.items() for version in vers
])
def test_version_switcher_with_referer(root, version, path):
    r = get(f'{base_url}{root}/switcher?branch={version}',
            headers={'Referer': f'{base_url}{root}/latest{path}'})

    if root == '' and version.endswith('-dev'):  # unstable sitemap
        expected = f'{base_url}{root}/{version}/'
    else:
        expected = f'{base_url}{root}/{version}{path}'

    assert r.status_code == 302
    assert r.headers['Location'] == expected


@pytest.mark.parametrize('root, version, lang', [
    (root, version, lang) for root, (langs, path) in languages.items() for lang in langs
    for version in versions[root][0]
])
def test_language_switcher(root, version, lang):
    r = get(f'{base_url}{root}/{version}/switcher?lang={lang}')

    assert r.status_code == 302
    assert r.headers['Location'] == f'{base_url}{root}/{version}/{lang}/'


@pytest.mark.parametrize('root, version, lang, path', [
    (root, version, lang, path) for root, (langs, path) in languages.items() for lang in langs
    for version in versions[root][0]
])
def test_language_switcher_with_referer(root, version, lang, path):
    r = get(f'{base_url}{root}/{version}/switcher?lang={lang}',
            headers={'Referer': f'{base_url}{root}/{version}/en{path}'})

    assert r.status_code == 302
    assert r.headers['Location'] == f'{base_url}{root}/{version}/{lang}{path}'


@pytest.mark.parametrize('root, version, lang', [
    (root, version, lang) for root, (langs, path) in languages.items() for lang in langs
    for version in versions[root][0] if version != '1.0' or lang != 'it'  # OCDS 1.0 isn't available in IT
])
def test_custom_404(root, version, lang):
    r = get(f'{base_url}{root}/{version}/{lang}/path/to/nonexistent/')

    if version.endswith('-dev'):
        expected = '"error_redirect/"'
    else:
        expected = f'"{root}/{version}/{lang}/"'

    assert r.status_code == 404
    assert expected in r.text

    if version.endswith('-dev'):
        r = get(f'{base_url}{root}/{version}/{lang}/path/to/nonexistent/error_redirect/')

        assert r.status_code == 302
        assert r.headers['Location'] == f'{base_url}{root}/{version}/{lang}/'


def test_default_404():
    r = get(f'{base_url}/latest/eo/')

    assert r.status_code == 404
    assert f'at {fqdn} ' in r.text


# As long as no branch is named "schema" or "extension", this also serves to test no proxy.
@pytest.mark.parametrize('path', [
    '/schema/',
    '/infrastructure/schema/',
    '/profiles/ppp/schema/',
    '/profiles/ppp/extension/',
])
def test_no_redirect(path):
    r = get(f'{base_url}{path}')

    assert r.status_code == 200


@pytest.mark.parametrize('root, text', [
    ('', 'OCDS'),
    ('/infrastructure', 'OC4IDS'),
])
def test_review(root, text):
    r = get(f'{base_url}{root}/review/')

    assert r.status_code == 200
    assert text in r.text

    r = get(f'{base_url}{root}/static/dataexplore/css/style.css')

    assert r.status_code == 200
    assert 'color:' in r.text


@pytest.mark.parametrize('root, version', [
    (root, version) for root, versions in banner_live for version in versions
])
def test_banner_live(root, version):
    r = get(f'{base_url}{root}/{version}/en/')

    assert r.status_code == 200
    assert 'This is an old version of ' not in r.text
    assert 'This is a development copy of ' not in r.text


@pytest.mark.parametrize('root, version', [
    (root, version) for root, versions in banner_old for version in versions
])
def test_banner_old(root, version):
    r = get(f'{base_url}{root}/{version}/en/')

    assert r.status_code == 200
    assert 'This is an old version of ' in r.text
    assert 'This is a development copy of ' not in r.text


@pytest.mark.parametrize('root, version', [
    (root, vers[-1]) for root, (vers, path) in versions.items()
])
def test_banner_staging(root, version):
    r = get(f'{base_url}{root}/{version}/en/')

    assert r.status_code == 200
    assert 'This is an old version of ' not in r.text
    assert 'This is a development copy of ' in r.text

    if root != '/infrastructure':  # OC4IDS doesn't have its own banner
        assert f'<a href="{root}/latest/en/">' in r.text


def test_banner_staging_profiles():
    r = get(f'{base_url}/profiles/gpa/master/en/')

    assert r.status_code == 200
    assert 'This profile is in development ' in r.text
    assert 'This is an old version of ' not in r.text
    assert 'This is a development copy of ' not in r.text


@pytest.mark.parametrize('path, location', [
    ('/feed', 'https://www.open-contracting.org/feed/'),
    ('/beta', 'https://www.open-contracting.org/2014/09/04/beta'),
    ('/project', f'{base_url}/latest/en/'),
    ('/validator', f'{base_url}/review'),
    ('/validator/data/1232ec83-48ac-45cb-923d-1f67701488ef',
     f'{base_url}/review/data/1232ec83-48ac-45cb-923d-1f67701488ef'),
    # Redirects to extensions.open-contracting.org.
    ('/1.1/es/extensions/community/', 'https://extensions.open-contracting.org/es/extensions/'),
    ('/profiles/ppp/1.0/es/extensions/bids/', 'https://extensions.open-contracting.org/es/extensions/bids/'),
])
def test_redirect(path, location):
    r = get(f'{base_url}{path}')

    assert r.status_code == 302
    assert r.headers['Location'] == location
