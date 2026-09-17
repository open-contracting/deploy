<?php
/**
 * Plugin Name: Open Contracting: ACF Field Group Cache
 * Description: Caches ACFML's translation of the ACF field groups, for the duration of the request.
 *
 * ACF applies the `acf/load_field_groups` filter on every `acf_get_field_groups()` call, outside its
 * own cache of the field groups. ACFML translates every group's strings in that filter, and a list
 * screen calls it twice per row, so the translation runs twice per row instead of once.
 *
 * @package OpenContracting
 * @link https://github.com/AdvancedCustomFields/acf/blob/6.8.10/includes/class-acf-internal-post-type.php#L381
 */

add_action(
	'init',
	function () {
		$hook = $GLOBALS['wp_filter']['acf/load_field_groups'] ?? null;
		if ( ! $hook instanceof WP_Hook ) {
			return;
		}

		foreach ( $hook->callbacks as $priority => $callbacks ) {
			foreach ( $callbacks as $id => $callback ) {
				if ( ! opencontracting_is_acfml_group_translator( $callback['function'] ) ) {
					continue;
				}

				$translate = $callback['function'];
				$memo      = array();

				// Keyed on the language (which the translation varies by and which WPML can switch mid-request)
				// and the arguments (so that edited field groups miss rather than match).
				$hook->callbacks[ $priority ][ $id ]['function'] = function ( ...$args ) use ( $translate, &$memo ) {
					$key = (string) apply_filters( 'wpml_current_language', null )
						. ':' . md5( serialize( $args ) ); // phpcs:ignore WordPress.PHP.DiscouragedPHPFunctions.serialize_serialize

					if ( ! array_key_exists( $key, $memo ) ) {
						$memo[ $key ] = $translate( ...$args );
					}

					return $memo[ $key ];
				};

				// Saving a field group registers its strings with WPML, so the same field groups can
				// translate differently afterwards, which the key alone would not notice.
				foreach ( array( 'acf/update_field_group', 'acf/delete_field_group', 'acf/trash_field_group', 'acf/untrash_field_group', 'acf/duplicate_field_group' ) as $action ) {
					add_action(
						$action,
						function () use ( &$memo ) {
							$memo = array();
						}
					);
				}
			}
		}
	},
	PHP_INT_MAX
);

/**
 * Whether the callback is ACFML's field group translator, which WPML wraps in a closure.
 *
 * ACFML 2.2.4 registers it in `wp-content/plugins/acfml/classes/Strings/FieldHooks.php` as
 * `Fns::withoutRecursion( Fns::identity(), [ $this, 'translateGroups' ] )`, which puts
 * `translateGroups` in the closure's `fn` static variable. ACFML itself is not open-source.
 * The link is to the library building that closure, of which WPML bundles an older build.
 *
 * @param mixed $callback A callback registered on `acf/load_field_groups`.
 * @link https://git.onthegosystems.com/wpml-packages/fp/-/blob/master/core/Fns.php
 */
function opencontracting_is_acfml_group_translator( $callback ) {
	if ( ! $callback instanceof Closure || ! class_exists( '\ACFML\Strings\FieldHooks' ) ) {
		return false;
	}

	// https://www.php.net/manual/en/reflectionfunctionabstract.getstaticvariables.php
	// `fn` is the `[ $this, 'translateGroups' ]` argument to `Fns::withoutRecursion`.
	$wrapped = ( new ReflectionFunction( $callback ) )->getStaticVariables()['fn'] ?? null;

	return is_array( $wrapped )
		&& ( $wrapped[0] ?? null ) instanceof \ACFML\Strings\FieldHooks
		&& 'translateGroups' === ( $wrapped[1] ?? null );
}
