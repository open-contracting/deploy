<?php
/**
 * Plugin Name: Open Contracting: Sentry
 * Description: Loads Sentry for WordPress ahead of other plugins, to report any errors they raise while loading.
 *
 * (Must-use plugins load in filename order, so the 00- prefix puts this one first.)
 *
 * @package OpenContracting
 * @link https://github.com/stayallive/wp-sentry#capturing-plugin-errors
 */

/**
 * Caps the SDK's HTTP calls, which hold a worker until they return.
 *
 * @param \Sentry\ClientBuilder $builder The builder, before the SDK initialises.
 */
function opencontracting_sentry_clientbuilder( \Sentry\ClientBuilder $builder ): void {
	$builder->getOptions()->setHttpConnectTimeout( 1.0 ); // 2s default
	$builder->getOptions()->setHttpTimeout( 1.0 ); // 5s default
}

$opencontracting_sentry = WP_PLUGIN_DIR . '/wp-sentry-integration/wp-sentry.php';

if ( file_exists( $opencontracting_sentry ) ) {
	require_once $opencontracting_sentry;
}
