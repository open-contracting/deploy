<?php
/**
 * Plugin Name: Open Contracting: Fathom Analytics
 * Description: Adds the Fathom Analytics script, except for logged-in administrators and editors.
 *
 * You can override the domain and site ID in wp-config.php:
 *   define('FATHOM_DOMAIN', 'fathom.example.org');
 *   define('FATHOM_SITE_ID', 'ABCDEFGH');
 *
 * @package OpenContracting
 */

add_action(
	'wp_head',
	function () {
		if ( is_user_logged_in() && array_intersect( array( 'administrator', 'editor' ), (array) wp_get_current_user()->roles ) ) {
			return;
		}

		$domain  = defined( 'FATHOM_DOMAIN' ) ? FATHOM_DOMAIN : 'cdn.usefathom.com';
		$site_id = defined( 'FATHOM_SITE_ID' ) ? FATHOM_SITE_ID : '{{ FATHOM_ANALYTICS_ID }}';

		// Not enqueued, because wp_enqueue_script() would need a script_loader_tag filter
		// to re-add the data-site and data-excluded-domains attributes.
		// phpcs:ignore WordPress.WP.EnqueuedResources.NonEnqueuedScript -- see above.
		echo '<script src="' . esc_url( 'https://' . $domain . '/script.js' ) . '" data-site="' . esc_attr( $site_id ) . '" defer data-excluded-domains="localhost,127.0.0.1,0.0.0.0"></script>' . "\n";
	}
);
