# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))

# -- Project information -----------------------------------------------------

project = 'Deploy'
copyright = '2019, Open Contracting Partnership'
author = 'Open Contracting Partnership'


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = ['sphinx_design']

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'furo'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

html_css_files = ['css/custom.css']


# -- Extension configuration -------------------------------------------------

linkcheck_ignore = [
    # Localhost instructions.
    r'^http://localhost:',
    # Redirects to login pages.
    r'^https://(?:account|dcc)\.godaddy\.com',
    r'^https://(?:docs\.google\.com/(?:document|spreadsheets)/d|drive\.google\.com/drive/folders)/',
    r'^https://(?:ocp-library\.herokuapp|robot\.hetzner|us-east-1\.console\.aws\.amazon)\.com',
    r'^https://(?:postmaster|search)\.google\.com',
    r'^https://app\.(dmarcanalyzer|usefathom)\.com',
    r'^https://github\.com/open-contracting/[^/]+/issues/new',
    r'^https://sentry.io/organizations/open-contracting-partnership/',
    # Private repositories return not found.
    r'^https://github\.com/open-contracting/(?:deploy-pillar-private|dogsbody-maintenance)',
]
# Note: GitHub anchors cause false positives (anchors are loaded via JavaScript).
# Don't ignore these, in case the URLs fail for another reason.
# Note: Hetzner URLs responds to linkcheck requests with 501 errors.
