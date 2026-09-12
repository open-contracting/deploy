<?php
/**
 * Plugin Name: Open Contracting: Require Two-Factor
 * Description: Sends administrators with no second factor to their profile page, until they enrol.
 *
 * The Two Factor plugin (https://wordpress.org/plugins/two-factor/) has no enforcement of its own. This does nothing
 * until that plugin is active.
 *
 * @package OpenContracting
 */

/**
 * Whether the current user must enrol.
 */
function opencontracting_needs_two_factor() {
	return class_exists( 'Two_Factor_Core' )
		&& current_user_can( 'manage_options' )
		&& ! Two_Factor_Core::is_user_using_two_factor();
}

add_action(
	'admin_init',
	function () {
		global $pagenow;

		// The profile page hosts Two Factor's settings, and its setup runs over admin-ajax.php.
		if ( 'profile.php' === $pagenow || wp_doing_ajax() || ! opencontracting_needs_two_factor() ) {
			return;
		}

		wp_safe_redirect( get_edit_profile_url() . '#two-factor-options' );
		exit;
	}
);

add_action(
	'admin_notices',
	function () {
		if ( opencontracting_needs_two_factor() ) {
			echo '<div class="notice notice-warning"><p>Administrators must use two-factor authentication. Enable a method under Two-Factor Options, then update your profile.</p></div>';
		}
	}
);
