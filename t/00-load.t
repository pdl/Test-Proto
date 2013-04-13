#!perl -T

use Test::More;

BEGIN {
	foreach (qw(
		Test::Proto
		Test::Proto::Base
		Test::Proto::TestCase
		Test::Proto::TestRunner
	))
	{
    	use_ok( $_ ) || print "Bail out!\n";
	}
}

diag( "Testing Test::Proto $Test::Proto::VERSION, Perl $], $^X" );
done_testing();
