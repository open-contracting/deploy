CoVE tasks
==========

Find all files uploaded by users
--------------------------------

.. code-block:: bash

   find /home/cove/cove/media -mindepth 3 -name '*.json'

CoVE OCDS' tests are run against the server, which submit many known filenames, daily. To exclude these, add:

.. code-block:: none

   -regextype egrep -not -regex '.*/(bad(_toplevel_list|file_(all|extension)_validation_errors)|basic_release_empty_fields|extended_many_jsonschema_keys|full_record|latin1|ocds_release_nulls|record_minimal_valid|release_aggregate|tenders_(1_release_with_extensions_1_1_missing_party_scale|records_1_record_with_invalid_extensions|releases_(1_release_(unpackaged|with_(all_invalid_extensions|closed_codelist|extension(_broken_json_ref|s_(1_1|new_layout))|invalid_extensions|patch_in_version|tariff_codelist|unrecognized_version|various_codelists|wrong_version_type))|2_releases(|_(1_1_tenderers_with_missing_ids|codelists|invalid|not_json))|7_releases_check_ocids|deprecated_fields_against_1_1_live|extra_data))|unconvertable_json|utf(8|-16)|ocds-213czf-000-00001-02-tender)\.json'

.. You can visualize the regular expression with https://www.debuggex.com.

To count unique basenames, add: ``-exec basename '{}' \; | sort | uniq -c | sort -n``

Find prefixes
-------------

Find the files as above, and store the output. For example:

.. code-block:: bash

   FILES=$(find /home/cove/cove/media -mindepth 3 -name '*.json')

For OCDS, run (takes about 4 minutes):

.. code-block:: bash

   for file in $FILES; do
     jq -rn 'input | (if .releases then .releases else .records end)[0].ocid // ""' $file; done | cut -d- -f1-2 | sort | uniq -c;
   done

For OC4IDS, run:

.. code-block:: bash

   for file in $FILES; do
     jq -rn 'input | .projects[0].id // ""' $file; done | cut -c-11 | sort | uniq -c | sort -n;
   done
