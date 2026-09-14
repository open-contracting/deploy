<?php
/**
 * Lists the updates that WordPress's automatic updater won't install, and the plugins it can't update.
 *
 * Run with `wp eval-file`.
 *
 * @package OpenContracting
 * @link https://developer.wordpress.org/reference/classes/wp_automatic_updater/should_update/
 */

/**
 * Requires the update API and refreshes the update transients.
 */
function opencontracting_updates_refresh() {
	require_once ABSPATH . 'wp-admin/includes/plugin.php';
	require_once ABSPATH . 'wp-admin/includes/file.php';
	require_once ABSPATH . 'wp-admin/includes/update.php';
	require_once ABSPATH . 'wp-admin/includes/class-wp-upgrader.php';

	// Refresh the update transients, unless they were refreshed recently.
	wp_version_check();
	wp_update_plugins();
	wp_update_themes();
}

/**
 * Returns the updates that WP_Automatic_Updater won't install.
 *
 * WP_Automatic_Updater::should_update() declines, for example, a major version if WP_AUTO_UPDATE_CORE is 'minor', a
 * plugin or theme whose auto-updates are off, and a version that requires a newer PHP version than the server runs.
 *
 * @return array[] Rows of type, name, installed version and available version.
 */
function opencontracting_updates_check() {
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

/**
 * Returns the installed plugins that received no answer from their update API.
 *
 * WordPress lists every plugin it asked about in `checked`, and every answer in `response` or `no_update`. A plugin
 * in neither was not answered for: the request timed out, its license is expired, or it's closed on wordpress.org.
 * (Not `wp plugin list`, which shows such a plugin as up to date.)
 *
 * @return array[] Rows of name and installed version.
 */
function opencontracting_silent_plugins() {
	$transient = get_site_transient( 'update_plugins' );

	if ( empty( $transient->checked ) ) {
		return array();
	}

	$silent = array_diff_key(
		(array) $transient->checked,
		(array) ( $transient->response ?? array() ),
		(array) ( $transient->no_update ?? array() )
	);

	$rows = array();
	foreach ( $silent as $file => $version ) {
		$rows[] = array( '.' === dirname( $file ) ? $file : dirname( $file ), $version );
	}

	return $rows;
}

// wp eval-file passes its positional arguments as $args.
$opencontracting_parts = $args ? $args : array( 'updates', 'silent' );

opencontracting_updates_refresh();

$opencontracting_pending = in_array( 'updates', $opencontracting_parts, true ) ? opencontracting_updates_check() : array();
$opencontracting_silent  = in_array( 'silent', $opencontracting_parts, true ) ? opencontracting_silent_plugins() : array();

if ( $opencontracting_pending ) {
	WP_CLI::line( "Updates that won't install automatically:" );
	foreach ( $opencontracting_pending as $row ) {
		WP_CLI::line( sprintf( '%s %s: %s -> %s', $row[0], $row[1], $row[2], $row[3] ) );
	}
}

if ( $opencontracting_silent ) {
	WP_CLI::line( "Plugins that can't update, because their update API gave no answer:" );
	foreach ( $opencontracting_silent as $row ) {
		WP_CLI::line( sprintf( 'plugin %s: %s', $row[0], $row[1] ) );
	}
}

if ( $opencontracting_pending || $opencontracting_silent ) {
	WP_CLI::halt( 1 );
}
