#!perl -T
use strict;
use warnings;

use Test::More;
use Test::Proto::Base;
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

sub is_a_good_exception {
	# Todo: test this more
	ok($_[0]?0:1, $_[1]);
	ok($_[0]->is_exception, '... and be an exception');
}


sub p { Test::Proto::Base->new(); }



is_a_good_pass(p->true->validate('a'), "'a' is true should pass");
is_a_good_fail(p->true->validate(0), "0 is true should fail");

is_a_good_pass(p->false->validate(0), "0 is false should pass");
is_a_good_fail(p->false->validate('a'), "'a' is false should fail");

is_a_good_pass(p->is('a')->validate('a'), "'a' is 'a' should pass");
is_a_good_fail(p->is('a')->validate('b'), "'b' is 'a' should fail");

is_a_good_pass(p->eq('a')->validate('a'), "'a' eq 'a' should pass");
is_a_good_fail(p->eq('a')->validate('b'), "'b' eq 'a' should fail");

is_a_good_pass(p->num_eq(1)->validate(1), "1 num_eq 1 should pass");
is_a_good_fail(p->num_eq(2)->validate(1), "2 num_eq 1 should fail");

is_a_good_fail(p->ne('a')->validate('a'), "'a' ne 'a' should fail");
is_a_good_pass(p->ne('a')->validate('b'), "'b' ne 'a' should pass");

is_a_good_fail(p->num_ne(1)->validate(1), "1 num_ne 1 should fail");
is_a_good_pass(p->num_ne(1)->validate(2), "2 num_ne 1 should pass");

is_a_good_pass(p->lt('b')->validate('a'), "'a' lt 'b' should pass");
is_a_good_fail(p->lt('a')->validate('a'), "'a' lt 'a' should fail");
is_a_good_fail(p->lt('a')->validate('b'), "'b' lt 'a' should fail");

is_a_good_pass(p->num_lt(2)->validate(1), "1 num_lt 2 should pass");
is_a_good_fail(p->num_lt(1)->validate(1), "1 num_lt 1 should fail");
is_a_good_fail(p->num_lt(1)->validate(2), "2 num_lt 1 should fail");

is_a_good_fail(p->gt('b')->validate('a'), "'a' gt 'b' should fail");
is_a_good_fail(p->gt('a')->validate('a'), "'a' gt 'a' should fail");
is_a_good_pass(p->gt('a')->validate('b'), "'b' gt 'a' should pass");

is_a_good_fail(p->num_gt(2)->validate(1), "1 num_gt 2 should fail");
is_a_good_fail(p->num_gt(1)->validate(1), "1 num_gt 1 should fail");
is_a_good_pass(p->num_gt(1)->validate(2), "2 num_gt 1 should pass");

is_a_good_pass(p->le('b')->validate('a'), "'a' le 'b' should pass");
is_a_good_pass(p->le('a')->validate('a'), "'a' le 'a' should pass");
is_a_good_fail(p->le('a')->validate('b'), "'b' le 'a' should fail");

is_a_good_pass(p->num_le(2)->validate(1), "1 num_le 2 should pass");
is_a_good_pass(p->num_le(1)->validate(1), "1 num_le 1 should pass");
is_a_good_fail(p->num_le(1)->validate(2), "2 num_le 1 should fail");

is_a_good_fail(p->ge('b')->validate('a'), "'a' ge 'b' should fail");
is_a_good_pass(p->ge('a')->validate('a'), "'a' ge 'a' should pass");
is_a_good_pass(p->ge('a')->validate('b'), "'b' ge 'a' should pass");

is_a_good_fail(p->num_ge(2)->validate(1), "1 num_ge 2 should fail");
is_a_good_pass(p->num_ge(1)->validate(1), "1 num_ge 1 should pass");
is_a_good_pass(p->num_ge(1)->validate(2), "2 num_ge 1 should pass");

is_a_good_pass(p->is_a('ARRAY')->validate([]), "[] is_a ARRAY should pass");
is_a_good_fail(p->is_a('ARRAY')->validate({}), "{} is_a ARRAY should fail");

is_a_good_pass(p->ref('ARRAY')->validate([]), "[] ref ARRAY should pass");
is_a_good_fail(p->ref('ARRAY')->validate({}), "{} ref ARRAY should fail");

# is_a_good_exception(p->eq('a')->validate(undef), "undef eq 'a' should fail"); # Doesn't die, though, so maybe this is fine as a fail.

# use Data::Dumper;
# diag (Dumper p->eq('a')->validate('b'));
{
	$_ = 3;
	is_a_good_pass(p->num_eq(3)->validate(), "validate implicitly takes $_");
}

done_testing;

