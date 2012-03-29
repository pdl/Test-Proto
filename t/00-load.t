#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Test::Proto' ) || print "Bail out!\n";
}

diag( "Testing Test::Proto $Test::Proto::VERSION, Perl $], $^X" );
