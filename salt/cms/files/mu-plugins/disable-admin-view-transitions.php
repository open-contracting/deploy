<?php
/**
 * Plugin Name: Open Contracting: Disable Admin View Transitions
 * Description: Disables the animated view transitions in the admin dashboard, introduced in WordPress 7.0.
 *
 * @package OpenContracting
 * @link https://kinskiandbourke.com/disable-wordpress-admin-view-transitions/
 * @link https://core.trac.wordpress.org/ticket/64529
 */

remove_action( 'admin_enqueue_scripts', 'wp_enqueue_view_transitions_admin_css' );
