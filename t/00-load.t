#!perl -T

use Test::More;

BEGIN {
	foreach (qw(
		Test::Proto
		Test::Proto::Base
		Test::Proto::Common
		Test::Proto::Formatter
		Test::Proto::Formatter::TestBuilder
		Test::Proto::TestCase
		Test::Proto::HashRef
		Test::Proto::Role::HashRef
		Test::Proto::TestRunner
	))
	{
    	use_ok( $_ ) || print "Bail out!\n";
	}
}

diag( "Testing Test::Proto $Test::Proto::VERSION, Perl $], $^X" );
done_testing();
