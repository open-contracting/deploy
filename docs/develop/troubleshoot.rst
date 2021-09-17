Troubleshoot
============

jinja2.exceptions.TemplateNotFound
----------------------------------

If you ``{% include %}`` a file, this error might be raised. To resolve the issue, add the included file to the ``extra_filerefs`` list in the ``Saltfile`` file (`Salt issue <https://github.com/saltstack/salt/issues/21370>`__).
