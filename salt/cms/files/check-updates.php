<?php
/**
 * Plugin Name: Open Contracting: Check Updates
 * Description: Lists the core, plugin and theme updates that the automatic updater will not install.
 *
 * Run with `wp eval-file`.
 *
 * @package OpenContracting
 * @link https://developer.wordpress.org/reference/classes/wp_automatic_updater/should_update/
 */

/**
 * Returns the updates that WP_Automatic_Updater won't install.
 *
 * @return array[] Rows of type, name, installed version and available version.
 */
function opencontracting_updates_check() {
	require_once ABSPATH . 'wp-admin/includes/plugin.php';
	require_once ABSPATH . 'wp-admin/includes/file.php';
	require_once ABSPATH . 'wp-admin/includes/update.php';
	require_once ABSPATH . 'wp-admin/includes/class-wp-upgrader.php';

	// Refresh the update transients, unless they were refreshed recently.
	wp_version_check();
	wp_update_plugins();
	wp_update_themes();

	$updater = new WP_Automatic_Updater();
	$pending = array();

	// Unlike `wp core check-update`, this follows WP_AUTO_UPDATE_CORE.
	//
	// wp_version_check() stores the offers from api.wordpress.org: the newest version, with response "upgrade", and the
	// newest version of each branch down to the newest version of the site's branch, with response "autoupdate".
	// get_core_updates() omits "autoupdate" offers. find_core_auto_update() returns the "autoupdate" offer with the
	// highest version that WP_AUTO_UPDATE_CORE allows, which can be the same version as the "upgrade" offer. As such,
	// the loop reports the "upgrade" offer, unless it will be auto-updated.
	$auto_update = find_core_auto_update();
	// Include an offer hidden with "Hide this update" in Dashboard > Updates, which get_core_updates() omits by default.
	foreach ( (array) get_core_updates( array( 'dismissed' => true ) ) as $offer ) {
		// Ignore "latest" and "development" offers.
		if ( 'upgrade' !== $offer->response ) {
			continue;
		}
		if ( $auto_update && $auto_update->current === $offer->current ) {
			continue;
		}
		$pending[] = array( 'core', 'wordpress', get_bloginfo( 'version' ), $offer->current );
	}

	$plugins = get_plugins();
	// Not `wp plugin list --update=available`, which also lists the updates that WP_Automatic_Updater is about to install.
	foreach ( get_plugin_updates() as $file => $data ) {
		if ( $updater->should_update( 'plugin', $data->update, WP_PLUGIN_DIR ) ) {
			continue;
		}
		$pending[] = array( 'plugin', '.' === dirname( $file ) ? $file : dirname( $file ), $plugins[ $file ]['Version'], $data->update->new_version );
	}

	// Not `wp theme list --update=available`, which also lists the updates that WP_Automatic_Updater is about to install.
	foreach ( get_theme_updates() as $stylesheet => $theme ) {
		// The transient stores theme offers as arrays.
		$item = (object) $theme->update;
		if ( $updater->should_update( 'theme', $item, get_theme_root( $stylesheet ) ) ) {
			continue;
		}
		$pending[] = array( 'theme', $stylesheet, $theme->get( 'Version' ), $item->new_version );
	}

	return $pending;
}

$opencontracting_pending = opencontracting_updates_check();
if ( $opencontracting_pending ) {
	WP_CLI::line( "Updates that won't install automatically:" );
	foreach ( $opencontracting_pending as $row ) {
		WP_CLI::line( sprintf( '%s %s: %s -> %s', $row[0], $row[1], $row[2], $row[3] ) );
	}
	WP_CLI::halt( 1 );
}
