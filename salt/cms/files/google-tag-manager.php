<?php
/**
 * Plugin Name: Open Contracting: Google Tag Manager
 * Description: Adds the Google Tag Manager container snippet, except for logged-in users.
 *
 * You can override the container ID in wp-config.php:
 *   define('GTM_CONTAINER_ID', 'GTM-ABCDEFG');
 *
 * @package OpenContracting
 */

add_action(
	'wp_head',
	function () {
		if ( is_user_logged_in() ) {
			return;
		}

		$container_id = defined( 'GTM_CONTAINER_ID' ) ? GTM_CONTAINER_ID : '{{ GTM_CONTAINER_ID }}';

		// The theme doesn't call wp_body_open(), so there's no place for a <noscript> fallback.
		// phpcs:ignore WordPress.WP.EnqueuedResources.NonEnqueuedScript -- Tag Manager must load before other scripts.
		echo "<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':new Date().getTime(),event:'gtm.js'});"
			. "var f=d.getElementsByTagName(s)[0],j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;"
			. "j.src='https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);})"
			. "(window,document,'script','dataLayer'," . wp_json_encode( $container_id ) . ');</script>' . "\n";
	}
);
