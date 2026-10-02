<?php
/**
 * Plugin Name: Open Contracting: Super Page Cache Dashboard Widget
 * Description: Hides the ThemeIsle news widget that Super Page Cache adds to the dashboard.
 *
 * The widget fetches two feeds and two api.wordpress.org queries while the dashboard renders, and
 * caches the queries for 6 hours, so most visits to the dashboard wait on them.
 *
 * @package OpenContracting
 */

add_filter( 'themeisle_sdk_hide_dashboard_widget', '__return_true' );
