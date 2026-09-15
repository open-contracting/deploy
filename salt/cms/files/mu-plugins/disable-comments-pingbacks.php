<?php
/**
 * Plugin Name: Open Contracting: Disable comments and pingbacks
 * Description: Disable comments and pingbacks, so attachment pages (which WordPress opens to comments by default)
 * can't collect spam.
 *
 * @package OpenContracting
 */

add_filter( 'comments_open', '__return_false' );
add_filter( 'pings_open', '__return_false' );
