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

/**
 * Return the container ID, or null if this request gets no tag.
 */
function opencontracting_gtm_container_id() {
	if ( is_user_logged_in() ) {
		return null;
	}

	return defined( 'GTM_CONTAINER_ID' ) ? GTM_CONTAINER_ID : '{{ GTM_CONTAINER_ID }}';
}

add_action(
	'wp_head',
	function () {
		$container_id = opencontracting_gtm_container_id();

		if ( null === $container_id ) {
			return;
		}

		// phpcs:ignore WordPress.WP.EnqueuedResources.NonEnqueuedScript -- Tag Manager must load before other scripts.
		echo "<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':new Date().getTime(),event:'gtm.js'});"
			. "var f=d.getElementsByTagName(s)[0],j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;"
			. "j.src='https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);})"
			. "(window,document,'script','dataLayer'," . wp_json_encode( $container_id ) . ');</script>' . "\n";
	}
);

/**
 * Output the <noscript> fallback, at most once.
 */
function opencontracting_gtm_render_no_js() {
	static $rendered = false;

	$container_id = opencontracting_gtm_container_id();

	if ( $rendered || null === $container_id ) {
		return;
	}

	$rendered = true;

	printf(
		'<noscript><iframe src="%s" height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>' . "\n",
		esc_url( 'https://www.googletagmanager.com/ns.html?id=' . rawurlencode( $container_id ) )
	);
}

// Tag Manager wants this right after <body>. wp_footer covers themes that don't call wp_body_open().
add_action( 'wp_body_open', 'opencontracting_gtm_render_no_js', -9999 );
add_action( 'wp_footer', 'opencontracting_gtm_render_no_js' );
