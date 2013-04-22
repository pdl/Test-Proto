#!perl -T

use Test::More;

BEGIN {
	foreach (qw(
		Test::Proto
		Test::Proto::Base
		Test::Proto::Common
		Test::Proto::TestCase
		Test::Proto::TestRunner

		Test::Proto::Formatter
		Test::Proto::Formatter::TestBuilder

		Test::Proto::HashRef
		Test::Proto::Role::HashRef
		Test::Proto::ArrayRef
		Test::Proto::Role::ArrayRef
	))
	{
    	use_ok( $_ ) || print "Bail out!\n";
	}
}

diag( "Testing Test::Proto $Test::Proto::VERSION, Perl $], $^X" );
done_testing();
