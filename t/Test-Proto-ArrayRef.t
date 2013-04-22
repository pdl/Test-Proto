#!perl -T
use strict;
use warnings;
use Data::Dumper;

use Test::More;
use Test::Proto::ArrayRef;

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


sub p { Test::Proto::Base->new(); }
sub pAr { Test::Proto::ArrayRef->new(); }

is_a_good_pass(pAr->nth(1, 'b')->validate(['a','b']), "item 1 of ['a','b'] is 'b'");
is_a_good_fail(pAr->nth(1, 'a')->validate(['a','b']), "item 1 of ['a','b'] is not 'a'");

# is_a_good_exception(pAr->nth(2, 'b')->validate(['a','b']), "item 2 of ['a','b'] does not exist"); # or should it fail with an out of bounds message?

is_a_good_pass(pAr->count_items(2)->validate(['a','b']), "count_items 2 on ['a','b'] passes");
is_a_good_fail(pAr->count_items(1)->validate(['a','b']), "count_items 1 on ['a','b'] fails");
is_a_good_pass(pAr->count_items(p->num_lt(5))->validate(['a','b']), "count_items <5 on ['a','b'] passes");
is_a_good_fail(pAr->count_items(p->num_gt(5))->validate(['a','b']), "count_items >5 on ['a','b'] fails");


done_testing;

