# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "Deploy"
copyright = "2019, Open Contracting Partnership"
author = "Open Contracting Partnership"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    "sphinx_design",
]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = "furo"
html_static_path = ["_static"]
html_css_files = ["custom.css"]

# -- Extension configuration -------------------------------------------------

# docs.hetzner.com returns 403, otherwise.
user_agent = "curl/8.6.0"
linkcheck_allow_unauthorized = False
linkcheck_report_timeouts_as_broken = True
linkcheck_ignore = [
    # Localhost instructions.
    r"^http://localhost:",
    # Unauthorized.
    r"^https://(alertmanager|monitor)\.prometheus\.open-contracting\.org",
    # Redirects to login pages.
    r"^https://(?:account|dcc)\.godaddy\.com",
    r"^https://(?:docs\.google\.com/(?:document|spreadsheets)/d|drive\.google\.com/drive/folders)/",
    r"^https://(?:dash\.cloudflare|ocp-library\.herokuapp|portal\.azure|robot\.hetzner|us-east-1\.console\.aws\.amazon)\.com",
    r"^https://(?:postmaster|search)\.google\.com",
    r"^https://app\.(ahrefs|usefathom)\.com",
    r"^https://github\.com/open-contracting/[^/]+/issues/new",
    r"^https://sentry.io/organizations/open-contracting-partnership/",
    # Private repositories return not found.
    r"^https://github\.com/open-contracting/(?:deploy-pillar-private)",
]
linkcheck_anchors_ignore_for_url = (
    r"^https://github\.com/[^/]+/[^/]+/blob/",
    r"^https://github\.com/[^/]+/[^/]+/tree/",
    r"^https://github\.com/icing/mod_md",
    r"^https://rabbitmq\.kingfisher\.open-contracting\.org",
)
