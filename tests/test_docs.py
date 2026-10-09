import os
from urllib.parse import urlsplit

import pytest
import requests

fqdn = os.getenv("FQDN", "standard.open-contracting.org")
base_url = f"https://{fqdn}"

versions = {
    "": (["latest", "1.0", "1.1-dev"], "/es/schema/release/"),
    "/infrastructure": (["latest", "0.9-dev"], "/en/reference/schema/"),
    "/profiles/eforms": (["latest"], "/en/reference/"),
    "/profiles/eu": (["latest"], "/en/reference/"),
    "/profiles/gpa": (["latest"], "/en/reference/"),
    "/profiles/ppp": (["latest", "1.0-dev"], "/es/reference/schema/"),
}

languages = {
    "": (["en", "es"], "/schema/release/"),
    "/infrastructure": (["en"], "/reference/schema/"),
    "/profiles/eforms": (["en"], "/reference/"),
    "/profiles/eu": (["en"], "/reference/"),
    "/profiles/gpa": (["en"], "/reference/"),
    "/profiles/ppp": (["en", "es"], "/reference/schema/"),
}

# The versions that the version switcher offers: `documentation` in salt/docs/init.sls. Unlike `versions` above,
# this omits the staging branches and the alias directories.
switcher_versions = {
    "": ["latest", "1.0"],
    "/infrastructure": ["latest"],
    "/profiles/eforms": ["latest"],
    "/profiles/eu": ["latest"],
    "/profiles/gpa": ["latest"],
    "/profiles/ppp": ["latest"],
}

def get(url, **kwargs):
    return requests.get(url, allow_redirects=False, **kwargs)


def is_staging(version):
    return version.endswith("dev")


def get_prefix(version):
    if is_staging(version):
        return "/staging"
    return ""


@pytest.mark.parametrize(
    "url",
    [
        "http://standard.open-contracting.org/latest/en/",
        "http://standard.open-contracting.org/robots.txt",
    ],
)
def test_force_https(url):
    r = get(url)

    assert r.status_code == 301
    assert r.headers["Location"] == urlsplit(url)._replace(scheme="https").geturl()


def test_robots_txt():
    r = get("https://standard.open-contracting.org/robots.txt")

    assert r.status_code == 200
    assert "LinkChecker" in r.text


def test_json_headers():
    r = get(f"{base_url}/schema/1__1__0/release-schema.json")

    assert r.status_code == 200
    assert r.headers["Content-Type"] == "application/json; charset=utf-8"
    assert r.headers["Access-Control-Allow-Origin"] == "*"


@pytest.mark.parametrize(("root", "version"), [(root, vers[0]) for root, (vers, path) in versions.items()])
def test_add_version(root, version):
    for suffix in ("", "/"):
        r = get(f"{base_url}{root}{suffix}")

        assert r.status_code == 302
        assert r.headers["Location"] == f"{base_url}{root}/{version}/"


@pytest.mark.parametrize(
    ("root", "version"), [(root, version) for root, (vers, path) in versions.items() for version in vers]
)
def test_add_language(root, version):
    prefix = get_prefix(version)

    for suffix in ("", "/"):
        r = get(f"{base_url}{prefix}{root}/{version}{suffix}")

        assert r.status_code == 302
        assert r.headers["Location"] == f"{base_url}{prefix}{root}/{version}/en/"


@pytest.mark.parametrize(
    ("root", "version", "lang"),
    [
        (root, version, lang)
        for root, (langs, path) in languages.items()
        for lang in langs
        for version in versions[root][0]
    ],
)
def test_add_trailing_slash_per_lang(root, version, lang):
    prefix = get_prefix(version)

    r = get(f"{base_url}{prefix}{root}/{version}/{lang}")

    assert r.status_code == 301
    assert r.headers["Location"] == f"{base_url}{prefix}{root}/{version}/{lang}/"


def test_add_trailing_slash_to_profiles():
    r = get(f"{base_url}/profiles")

    assert r.status_code == 301
    assert r.headers["Location"] == f"{base_url}/profiles/"


def test_profiles():
    r = get(f"{base_url}/profiles/")

    assert r.status_code == 200
    assert "Parent Directory" in r.text


@pytest.mark.parametrize(
    ("root", "version", "lang"),
    [
        (root, version, lang)
        for root, (langs, path) in languages.items()
        for lang in langs
        for version in versions[root][0]
    ],
)
def test_custom_404(root, version, lang):
    prefix = get_prefix(version)

    r = get(f"{base_url}{prefix}{root}/{version}/{lang}/path/to/nonexistent/")

    expected = '"error_redirect/"' if is_staging(version) else f'"{root}/{version}/{lang}/"'

    assert r.status_code == 404
    assert expected in r.text

    if is_staging(version):
        r = get(f"{base_url}/staging{root}/{version}/{lang}/path/to/nonexistent/error_redirect/")

        assert r.status_code == 302
        assert r.headers["Location"] == f"{base_url}/staging{root}/{version}/{lang}/"


def test_default_404():
    r = get(f"{base_url}/latest/eo/")

    assert r.status_code == 404
    # Apache's own page, rather than the documentation's, which ErrorDocument sets per language.
    assert "<title>404 Not Found</title>" in r.text


# As long as no branch is named "schema" or "extension", this also serves to test no proxy.
@pytest.mark.parametrize(
    "path",
    [
        "/schema/",
        "/infrastructure/schema/",
        "/profiles/ppp/schema/",
        "/profiles/ppp/extension/",
    ],
)
def test_no_redirect(path):
    r = get(f"{base_url}{path}")

    assert r.status_code == 200


@pytest.mark.parametrize("root", switcher_versions)
def test_versions_json(root):
    r = get(f"{base_url}{root}/versions.json")

    assert r.status_code == 200
    assert r.headers["Content-Type"] == "application/json; charset=utf-8"
    assert r.headers["Cache-Control"] == "no-cache"
    assert [version["ref"] for version in r.json()["versions"]] == switcher_versions[root]
    assert all(version["label"] for version in r.json()["versions"])


@pytest.mark.parametrize("root", switcher_versions)
def test_versions_json_staging(root):
    r = get(f"{base_url}/staging{root}/versions.json")

    assert r.status_code == 200
    assert r.headers["Cache-Control"] == "no-cache"
    assert r.json() == {"staging": True, "live_url": f"{root}/latest/en/"}
    assert get(f"{base_url}{r.json()['live_url']}").status_code == 200


@pytest.mark.parametrize(
    ("path", "location"),
    [
        ("/feed", "https://www.open-contracting.org/feed/"),
        ("/beta", "https://www.open-contracting.org/2014/09/04/beta"),
        ("/project", f"{base_url}/latest/en/"),
        # Redirects to extensions.open-contracting.org.
        ("/1.1/es/extensions/community/", "https://extensions.open-contracting.org/es/extensions/"),
        ("/profiles/ppp/1.0/es/extensions/bids/", "https://extensions.open-contracting.org/es/extensions/bids/"),
    ],
)
def test_redirect(path, location):
    r = get(f"{base_url}{path}")

    assert r.status_code == 302
    assert r.headers["Location"] == location
