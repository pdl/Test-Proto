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
	ok(!$_[0]->is_exception, '... and not be an exception');
}

sub p { Test::Proto::Base2->new(); }

is_a_good_pass(p->is('a')->validate('a'), "'a' is 'a' should pass");
is_a_good_fail(p->is('a')->validate('b'), "'a' is 'b' should fail");

is_a_good_pass(p->eq('a')->validate('a'), "'a' eq 'a' should pass");
is_a_good_fail(p->eq('a')->validate('b'), "'a' eq 'b' should fail");

is_a_good_fail(p->ne('a')->validate('a'), "'a' ne 'a' should fail");
is_a_good_pass(p->ne('a')->validate('b'), "'a' ne 'b' should pass");

is_a_good_pass(p->lt('b')->validate('a'), "'a' lt 'b' should pass");
is_a_good_fail(p->lt('a')->validate('a'), "'a' lt 'a' should fail");
is_a_good_fail(p->lt('a')->validate('b'), "'b' lt 'a' should fail");

is_a_good_fail(p->gt('b')->validate('a'), "'a' gt 'b' should fail");
is_a_good_fail(p->gt('a')->validate('a'), "'a' gt 'a' should fail");
is_a_good_pass(p->gt('a')->validate('b'), "'b' gt 'a' should pass");

is_a_good_pass(p->le('b')->validate('a'), "'a' le 'b' should pass");
is_a_good_pass(p->le('a')->validate('a'), "'a' le 'a' should pass");
is_a_good_fail(p->le('a')->validate('b'), "'b' le 'a' should fail");

is_a_good_fail(p->ge('b')->validate('a'), "'a' ge 'b' should fail");
is_a_good_pass(p->ge('a')->validate('a'), "'a' ge 'a' should pass");
is_a_good_pass(p->ge('a')->validate('b'), "'b' ge 'a' should pass");

# use Data::Dumper;
# diag (Dumper p->le('b')->validate('a'));

done_testing;

