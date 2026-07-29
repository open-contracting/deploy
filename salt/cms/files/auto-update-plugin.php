<?php
// Auto-update a plugin if a new version is available and it is neither a new major version
// nor a new minor version within major version zero.
// https://core.trac.wordpress.org/ticket/51126
function opencontracting_auto_update_plugin( $value, $item ) {
        // https://developer.wordpress.org/reference/functions/wp_plugin_directory_constants/
        $plugin_data = get_plugin_data( WP_PLUGIN_DIR . '/' . $item->plugin , false, false );
        // https://developer.wordpress.org/reference/functions/get_plugin_data/#return
        $old_version = explode( '.', $plugin_data['Version'] );
        $new_version = explode( '.', $item->new_version );
        // https://github.com/dependabot/fetch-metadata/blob/924483a/src/dependabot/update_metadata.ts#L77-L94
        if (
                $old_version !== $new_version
                && $old_version[0] === $new_version[0]
                && ( $old_version[0] !== '0' || $old_version[1] === $new_version[1] )
        ) {
                return true;
        }
        return $value;
}
// https://developer.wordpress.org/advanced-administration/upgrade/upgrading/#configuration-via-filters
// https://developer.wordpress.org/reference/functions/add_filter/
// https://developer.wordpress.org/reference/hooks/auto_update_type/
add_filter( 'auto_update_plugin', 'opencontracting_auto_update_plugin', 10, 2 );
