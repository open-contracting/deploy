<?php
/**
 * Plugin Name: Open Contracting: Disable User Enumeration
 * Description: Hides the user list from anonymous visitors: the REST API's users endpoints and the users sitemap.
 *
 * @package OpenContracting
 */

add_filter(
	'rest_endpoints',
	function ( $endpoints ) {
		if ( is_user_logged_in() ) {
			return $endpoints;
		}
		foreach ( array_keys( $endpoints ) as $route ) {
			if ( str_starts_with( $route, '/wp/v2/users' ) ) {
				unset( $endpoints[ $route ] );
			}
		}
		return $endpoints;
	}
);

// WordPress publishes wp-sitemap-users-1.xml by default.
add_filter( 'wp_sitemaps_add_provider', fn ( $provider, $name ) => 'users' === $name ? false : $provider, 10, 2 );
