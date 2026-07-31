<?php
/**
 * Plugin Name: Open Contracting: Auto-Update Plugin
 * Description: Auto-updates a plugin, unless the new version is a new major version, or a new minor version within major version zero.
 *
 * @package OpenContracting
 * @link https://core.trac.wordpress.org/ticket/51126
 * @link https://github.com/dependabot/fetch-metadata/blob/924483a/src/dependabot/update_metadata.ts#L77-L94
 */

/**
 * Determines whether to auto-update a plugin.
 *
 * Declines a new major version, and a new minor version within major version zero, matching the
 * updates that Dependabot labels as semver-major.
 *
 * @param bool|null $value Whether to auto-update the plugin.
 * @param stdClass  $item  The plugin's update offer.
 * @return bool|null Whether to auto-update the plugin.
 */
function opencontracting_auto_update_plugin( $value, $item ) {
	$plugin_data = get_plugin_data( WP_PLUGIN_DIR . '/' . $item->plugin, false, false );

	$old_version = explode( '.', $plugin_data['Version'] );
	$new_version = explode( '.', $item->new_version );

	if (
		$old_version !== $new_version
		&& $old_version[0] === $new_version[0]
		&& ( $old_version[0] !== '0' || $old_version[1] === $new_version[1] )
	) {
		return true;
	}

	return $value;
}

add_filter( 'auto_update_plugin', 'opencontracting_auto_update_plugin', 10, 2 );
