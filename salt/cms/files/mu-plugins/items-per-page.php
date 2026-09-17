<?php
/**
 * Plugin Name: Open Contracting: Items Per Page
 * Description: Sets how many items the admin's list tables show per page, rather than WordPress' 20.
 *
 * The plugins screen is omitted, because WordPress lists every plugin on one page: its default is
 * 999, and capping it would paginate a screen that is meant not to be.
 *
 * @package OpenContracting
 */

add_action(
	'admin_init',
	function () {
		$per_page = (int) '{{ ITEMS_PER_PAGE|default(10) }}';
		$options  = array( 'upload_per_page', 'edit_comments_per_page', 'users_per_page' );

		foreach ( get_post_types( array( 'show_ui' => true ) ) as $post_type ) {
			$options[] = "edit_{$post_type}_per_page";
		}

		// The slug is used verbatim, dashes included: edit_resource-type_per_page.
		foreach ( get_taxonomies( array( 'show_ui' => true ) ) as $taxonomy ) {
			$options[] = "edit_{$taxonomy}_per_page";
		}

		foreach ( $options as $option ) {
			add_filter( "get_user_option_{$option}", fn ( $value ) => (int) $value >= 1 ? $value : $per_page );
		}
	}
);
