<?php
/**
 * Plugin Name: Open Contracting: Autosave Lookup
 * Description: Restores the post name in revision queries, which WPML replaces with a single post ID.
 *
 * WordPress keeps one autosave per author per post. All of a post's autosaves have the post name
 * `{ID}-autosave-v1`, so `wp_get_post_autosave()` finds an author's autosave by that name and the author.
 * Outside wp-admin, including in the REST API, WPML replaces the name with the ID of the post's newest
 * autosave, by any author, and caches that ID until Redis expires it.
 *
 * For example, post 100 has autosave 201 by Ana and autosave 202 by Ben, so WPML replaces the name with
 * 202. The next time the block editor stores Ana's unsaved changes (about once a minute), WordPress looks
 * for autosave 202 by Ana, finds nothing, and creates autosave 203 instead of updating 201. WPML still
 * has 202, so a minute later WordPress creates 204, and so on. Opening post 100 renders every one of them.
 *
 * @package OpenContracting
 */

$opencontracting_revision_vars = new WeakMap();

// Before WPML's parse_query (priority 10), which overwrites both `name` and `p`.
add_action(
	'parse_query',
	function ( $query ) use ( $opencontracting_revision_vars ) {
		if ( 'revision' === $query->get( 'post_type' ) && $query->get( 'name' ) ) {
			$opencontracting_revision_vars[ $query ] = array(
				'name' => $query->get( 'name' ),
				'p'    => $query->get( 'p' ),
			);
		} else {
			// A WP_Query can run another query, which must not inherit this one's name.
			unset( $opencontracting_revision_vars[ $query ] );
		}
	},
	0
);

add_action(
	'pre_get_posts',
	function ( $query ) use ( $opencontracting_revision_vars ) {
		foreach ( $opencontracting_revision_vars[ $query ] ?? array() as $key => $value ) {
			$query->set( $key, $value );
		}
	}
);
