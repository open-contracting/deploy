<?php
/**
 * Lists the premium plugins whose files changed, while their version didn't.
 *
 * WordPress.org publishes no checksums for premium plugins, so this compares each against the hashes it recorded when
 * it last saw the installed version. wp eval-file passes the plugins to compare as $args.
 *
 * @package OpenContracting
 */

/**
 * Returns the directory or file of a plugin or must-use plugin, and its version.
 *
 * @param string $name A plugin's directory, or a single-file plugin's basename.
 * @return array|false The path and version, or false if the plugin isn't installed.
 */
function opencontracting_premium_plugin( $name ) {
	require_once ABSPATH . 'wp-admin/includes/plugin.php';

	foreach ( get_plugins() as $file => $data ) {
		if ( dirname( $file ) === $name ) {
			return array( WP_PLUGIN_DIR . '/' . $name, $data['Version'] );
		}
		if ( $file === "$name.php" ) {
			return array( WP_PLUGIN_DIR . '/' . $file, $data['Version'] );
		}
	}

	foreach ( get_mu_plugins() as $file => $data ) {
		if ( $file === "$name.php" ) {
			return array( WPMU_PLUGIN_DIR . '/' . $file, $data['Version'] );
		}
	}

	return false;
}

/**
 * Returns the SHA-256 hash of each file, keyed by its path relative to the plugin.
 *
 * @param string $path A plugin's directory or file.
 * @return string[] Hashes, keyed by relative path.
 */
function opencontracting_premium_hashes( $path ) {
	if ( is_file( $path ) ) {
		return array( basename( $path ) => hash_file( 'sha256', $path ) );
	}

	$hashes = array();
	$files  = new RecursiveIteratorIterator( new RecursiveDirectoryIterator( $path, FilesystemIterator::SKIP_DOTS ) );
	foreach ( $files as $file ) {
		if ( $file->isFile() ) {
			$hashes[ substr( $file->getPathname(), strlen( $path ) + 1 ) ] = hash_file( 'sha256', $file->getPathname() );
		}
	}

	ksort( $hashes );

	return $hashes;
}

/**
 * Returns how each file changed, keyed by its path relative to the plugin.
 *
 * @param string[] $before The recorded hashes.
 * @param string[] $after  The current hashes.
 * @return string[] "added", "modified" or "removed", keyed by relative path.
 */
function opencontracting_premium_changes( $before, $after ) {
	$changes = array();

	foreach ( $after as $file => $hash ) {
		if ( ! isset( $before[ $file ] ) ) {
			$changes[ $file ] = 'added';
		} elseif ( $before[ $file ] !== $hash ) {
			$changes[ $file ] = 'modified';
		}
	}

	foreach ( array_keys( $before ) as $file ) {
		if ( ! isset( $after[ $file ] ) ) {
			$changes[ $file ] = 'removed';
		}
	}

	ksort( $changes );

	return $changes;
}

// Outside the document root, so that no request can read which plugins a site runs.
$opencontracting_file     = dirname( ABSPATH ) . '/premium-plugin-checksums.json';
$opencontracting_baseline = array();
$opencontracting_lines    = array();
$opencontracting_record   = false;

if ( file_exists( $opencontracting_file ) ) {
	// phpcs:ignore WordPress.WP.AlternativeFunctions.file_get_contents_file_get_contents, WordPress.WP.AlternativeFunctions.file_system_operations_file_get_contents -- WP_Filesystem is for the document root.
	$opencontracting_baseline = (array) json_decode( file_get_contents( $opencontracting_file ), true );
}

foreach ( $args as $opencontracting_name ) {
	$opencontracting_plugin = opencontracting_premium_plugin( $opencontracting_name );
	if ( ! $opencontracting_plugin ) {
		continue;
	}

	list( $opencontracting_path, $opencontracting_version ) = $opencontracting_plugin;

	$opencontracting_hashes = opencontracting_premium_hashes( $opencontracting_path );
	$opencontracting_entry  = $opencontracting_baseline[ $opencontracting_name ] ?? array();

	// Record a version this site hasn't recorded before: a first run, an install or an update.
	if ( ( $opencontracting_entry['version'] ?? null ) !== $opencontracting_version ) {
		$opencontracting_baseline[ $opencontracting_name ] = array(
			'version' => $opencontracting_version,
			'files'   => $opencontracting_hashes,
		);
		$opencontracting_record                            = true;
		continue;
	}

	// Leave the recorded hashes alone, to report the same files tomorrow, until someone restores or re-installs them.
	foreach ( opencontracting_premium_changes( $opencontracting_entry['files'], $opencontracting_hashes ) as $opencontracting_relative => $opencontracting_change ) {
		$opencontracting_lines[] = sprintf( 'plugin %s: %s %s', $opencontracting_name, $opencontracting_change, $opencontracting_relative );
	}
}

if ( $opencontracting_record ) {
	// phpcs:disable WordPress.WP.AlternativeFunctions.file_system_operations_file_put_contents, WordPress.WP.AlternativeFunctions.file_system_operations_chmod -- WP_Filesystem is for the document root.
	file_put_contents( $opencontracting_file, wp_json_encode( $opencontracting_baseline ) );
	chmod( $opencontracting_file, 0600 );
	// phpcs:enable
}

if ( $opencontracting_lines ) {
	WP_CLI::line( "Premium plugin files that changed, though the plugin's version didn't:" );
	foreach ( $opencontracting_lines as $opencontracting_line ) {
		WP_CLI::line( $opencontracting_line );
	}
}
