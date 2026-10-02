<?php
/**
 * Plugin Name: Open Contracting: Super Page Cache Feeds
 * Description: Lets Cloudflare cache feeds for 15 minutes, which Super Page Cache otherwise bypasses.
 *
 * Super Page Cache's Cloudflare cache rule respects the origin's Cache-Control, and the plugin sends
 * `no-store` for feeds, so every poll by a feed reader reaches PHP. Publishing a post purges only some
 * feeds, so a new post can take up to 15 minutes to appear in the others (like /feed/).
 *
 * @package OpenContracting
 */

// After Super Page Cache sends its headers, at `template_redirect` (priority PHP_INT_MAX).
foreach ( array( 'rss2', 'atom', 'rss', 'rdf' ) as $opencontracting_feed ) {
	add_action(
		"do_feed_{$opencontracting_feed}",
		function () {
			if ( ! is_user_logged_in() ) {
				header( 'Cache-Control: public, max-age=300, s-maxage=900' );
			}
		},
		0
	);
}
