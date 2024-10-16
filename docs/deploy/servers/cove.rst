CoVE
====

Find all files uploaded by users
--------------------------------

For example:

.. code-block:: bash

   find /data/storage/cove-ocds/media -mindepth 3 -name '*.json'

CoVE OCDS' tests are run against the server, which submit many known filenames, daily. To exclude these, add:

.. code-block:: none

   -regextype egrep -not -regex '.*/(bad(_toplevel_list|file_(all|extension)_validation_errors)|basic_release_empty_fields|extended_many_jsonschema_keys|full_record|latin1|ocds_release_nulls|record_minimal_valid|release_aggregate|tenders_(1_release_with_extensions_1_1_missing_party_scale|records_1_record_with_invalid_extensions|releases_(1_release_(unpackaged|with_(all_invalid_extensions|closed_codelist|extension(_broken_json_ref|s_(1_1|new_layout))|invalid_extensions|patch_in_version|tariff_codelist|unrecognized_version|various_codelists|wrong_version_type))|2_releases(|_(1_1_tenderers_with_missing_ids|codelists|invalid|not_json))|7_releases_check_ocids|deprecated_fields_against_1_1_live|extra_data))|unconvertable_json|utf(8|-16)|ocds-213czf-000-00001-02-tender)\.json'

.. You can visualize the regular expression with https://www.debuggex.com.

To count unique basenames, add: ``-exec basename '{}' \; | sort | uniq -c | sort -n``

Find prefixes
-------------

Find the files as above, and store the output. For example:

.. code-block:: bash

   FILES=$(find /data/storage/cove-ocds/media -mindepth 3 -name '*.json')

For OCDS, run (takes about 4 minutes):

.. code-block:: bash

   for file in $FILES; do
     jq -rn 'input | (if .releases then .releases else .records end)[0].ocid // ""' $file;
   done | cut -d- -f1-2 | sort | uniq -c

For OC4IDS, run:

.. code-block:: bash

   for file in $FILES; do
     jq -rn 'input | .projects[0].id // ""' $file;
   done | cut -d- -f1-2 | sort | uniq -c

Search files
------------

For example:

.. code-block:: bash

   rg -c 'my search string' /data/storage/cove-ocds/media

To exclude generated files, add:

.. code-block:: none

   -g '!{metatab,unflattened,validation_errors-3}.json'

To exclude generated files and CoVE OCDS' test fixtures, add:

.. code-block:: none

   -g '!{bad_toplevel_list,badfile_all_validation_errorsbadfile_extension_validation_errors,basic_release_empty_fields,extended_many_jsonschema_keys,full_record,latin1,ocds_release_nulls,record_minimal_valid,release_aggregate,tenders_1_release_with_extensions_1_1_missing_party_scale,tenders_records_1_record_with_invalid_extensions,tenders_releases_1_release_unpackaged,tenders_releases_1_release_with_all_invalid_extensions,tenders_releases_1_release_with_closed_codelist,tenders_releases_1_release_with_extension_broken_json_ref,tenders_releases_1_release_with_extensions_1_1tenders_releases_1_release_with_extensions_new_layout,tenders_releases_1_release_with_invalid_extensions,tenders_releases_1_release_with_patch_in_version,tenders_releases_1_release_with_tariff_codelist,tenders_releases_1_release_with_unrecognized_version,tenders_releases_1_release_with_various_codelists,tenders_releases_1_release_with_wrong_version_type,tenders_releases_2_releases,tenders_releases_2_releases_1_1_tenderers_with_missing_ids,tenders_releases_2_releases_codelists,tenders_releases_2_releases_invalid,tenders_releases_2_releases_not_json,tenders_releases_7_releases_check_ocids,tenders_releases_deprecated_fields_against_1_1_live,tenders_releases_extra_data,unconvertable_json,utf8,utf-16,ocds-213czf-000-00001-02-tender,metatab,unflattened,validation_errors-3}.json'
