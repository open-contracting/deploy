<?php
// The default is: 'wordpress@sitedomain.tld'
// https://developer.wordpress.org/reference/hooks/wp_mail_from/
add_filter( 'wp_mail_from', fn () => 'noreply@noreply.open-contracting.org' );
