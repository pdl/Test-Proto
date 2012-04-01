#!perl -T

use Test::More;

BEGIN {
	foreach (qw(
		Test::Proto
		Test::Proto::Base
		Test::Proto::Fail
		Test::Proto::Test
		Test::Proto::String
		Test::Proto::HashRef
		Test::Proto::ArrayRef
		Test::Proto::Object
	))
	{
    	use_ok( $_ ) || print "Bail out!\n";
	}
}

diag( "Testing Test::Proto $Test::Proto::VERSION, Perl $], $^X" );
done_testing();
