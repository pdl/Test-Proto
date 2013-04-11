#!perl -T
use strict;
use warnings;

use Test::More;
use Test::Proto::Base2;
ok (1, 'ok is ok');

sub is_a_good_pass {
	# Todo: test this more
	ok($_[0]?1:0, , $_[1]);
}

sub is_a_good_fail {
	# Todo: test this more
	ok($_[0]?0:1, $_[1]);
}

sub p { Test::Proto::Base2->new(); }

is_a_good_pass(p->is('a')->validate('a'), "'a' is 'a' should pass");
is_a_good_fail(p->is('a')->validate('b'), "'a' is 'b' should fail");

done_testing;

