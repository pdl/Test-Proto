#!perl -T

use Test::More;

BEGIN {
	foreach (qw(
		Test::Proto
		Test::Proto::ArrayRef
		Test::Proto::Base
		Test::Proto::CodeRef
		Test::Proto::Compare
		Test::Proto::Compare::Numeric
		Test::Proto::Exception
		Test::Proto::Fail
		Test::Proto::HashRef
		Test::Proto::Object
		Test::Proto::Series
		Test::Proto::String
		Test::Proto::Test
		Test::Proto::TestRunner
	))
	{
    	use_ok( $_ ) || print "Bail out!\n";
	}
}

diag( "Testing Test::Proto $Test::Proto::VERSION, Perl $], $^X" );
done_testing();
