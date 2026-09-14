<?php
/**
 * Plugin Name: Open Contracting: Disable Application Passwords
 * Description: Blocks the credentials that authenticate REST API and XML-RPC requests, which skip the second factor.
 *
 * @package OpenContracting
 */

add_filter( 'wp_is_application_passwords_available', '__return_false' );
