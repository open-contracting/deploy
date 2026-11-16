<?php
/**
 * Plugin Name: Open Contracting: Disable User Enumeration
 * Description: Hides the user list from anonymous visitors: the REST API's users endpoints, the users sitemap and author IDs.
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

// WordPress redirects /?author=ID to /author/{slug}/, so counting through IDs lists every user.
// Links to /author/{slug}/ still work, because WordPress looks those up by slug, not by ID.
add_filter(
	'request',
	function ( $query_vars ) {
		if ( isset( $query_vars['author'] ) && ! is_user_logged_in() ) {
			$query_vars['error'] = '404';
		}
		return $query_vars;
	}
);
