<?php
/**
 * Plugin Name: Open Contracting: Mail From
 * Description: Sets the From address for outgoing mail. (The default would be wordpress@sitedomain.tld.)
 *
 * @package OpenContracting
 * @link https://developer.wordpress.org/reference/hooks/wp_mail_from/
 */

add_filter( 'wp_mail_from', fn () => 'noreply@noreply.open-contracting.org' );
