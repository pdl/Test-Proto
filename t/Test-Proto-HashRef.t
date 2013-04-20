#!perl -T
use strict;
use warnings;
use Data::Dumper;

use Test::More;
use Test::Proto::HashRef;

ok (1, 'ok is ok');

sub is_a_good_pass {
	# Todo: test this more
	ok($_[0]?1:0, , $_[1]) or diag Dumper $_[0];
}

sub is_a_good_fail {
	# Todo: test this more
	ok($_[0]?0:1, $_[1]) or diag Dumper $_[0];
	ok(!$_[0]->is_exception, '... and not be an exception') or diag Dumper $_[0];
}

sub is_a_good_exception {
	# Todo: test this more
	ok($_[0]?0:1, $_[1]);
	ok($_[0]->is_exception, '... and be an exception');
}


sub pHr { Test::Proto::HashRef->new(); }

is_a_good_pass(pHr->key_has_value('a','b')->validate({'a'=>'b'}), "This should pass");
is_a_good_fail(pHr->key_has_value('a','b')->validate({'a'=>'c'}), "This should fail");
is_a_good_fail(pHr->key_has_value('a','b')->validate({}), "This should fail");

is_a_good_pass(pHr->count_keys(1)->validate({'a'=>'b'}), "This should pass");


done_testing;

