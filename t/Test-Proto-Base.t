#!perl -T
use strict;
use warnings;

use Test::More;
use Test::Proto::Base;
use Data::Dumper;
my $undef = undef;
ok (1, 'ok is ok');

sub is_a_good_pass {
	# Todo: test this more
	ok($_[0]?1:0, , $_[1])
	or diag Dumper $_[0];
}

sub is_a_good_fail {
	# Todo: test this more
	(	ok($_[0]?0:1, $_[1]) 
	and	ok(!$_[0]->is_exception, '... and not be an exception')
	) or	diag Dumper $_[0];
}

sub is_a_good_exception {
	# Todo: test this more
	(	ok($_[0]?0:1, $_[1])
	and	ok($_[0]->is_exception, '... and be an exception')
	) or 	diag Dumper $_[0];
}


sub p { Test::Proto::Base->new(); }



is_a_good_pass(p->true->validate('a'), "'a' is true should pass");
is_a_good_fail(p->true->validate(0), "0 is true should fail");

is_a_good_pass(p->false->validate(0), "0 is false should pass");
is_a_good_fail(p->false->validate('a'), "'a' is false should fail");

is_a_good_pass(p->defined->validate(0), "0 is defined should pass");
is_a_good_fail(p->defined->validate($undef), "undef is defined should fail");

is_a_good_pass(p->undefined->validate(undef), "undef is undefined should pass");
is_a_good_fail(p->undefined->validate(0), "0 is undefined should fail");

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

is_a_good_pass(p->like(qr/^a$/)->validate('a'), "'a' =~ /^a$/ should pass");
is_a_good_fail(p->like(qr/^a$/)->validate('b'), "'a' =~ /^a$/ should fail");

is_a_good_pass(p->unlike(qr/^b$/)->validate('a'), "'a' !~ /^b$/ should pass");
is_a_good_fail(p->unlike(qr/^b$/)->validate('b'), "'b' !~ /^b$/ should fail");

is_a_good_pass(p->try(sub{'a' eq shift})->validate('a'), "sub{'a' eq shift}->('b') should pass");
is_a_good_fail(p->try(sub{'a' eq shift})->validate('b'), "'sub{'a' eq shift}->('b') should fail");

is_a_good_pass(p->also(p->eq('a'))->validate('a'), "also will correctly pass");
is_a_good_fail(p->also(p->eq('a'))->validate('b'), "also will correctly fail");
is_a_good_pass(p->also('a')->validate('a'), "also will correctly pass (upgrading)");
is_a_good_fail(p->also('a')->validate('b'), "also will correctly fail (upgrading)");


is_a_good_pass(p->any_of([p->eq('a'), p->eq('b')])->validate('a'), "any_of will correctly pass");
is_a_good_pass(p->any_of([p->eq('a'), p->eq('b')])->validate('b'), "any_of will correctly pass");
is_a_good_fail(p->any_of([p->eq('a'), p->eq('b')])->validate('c'), "any_of will correctly pass");
is_a_good_pass(p->any_of(['a','b'])->validate('a'), "any_of will correctly pass (upgrading)");
is_a_good_pass(p->any_of(['a','b'])->validate('b'), "any_of will correctly pass (upgrading)");
is_a_good_fail(p->any_of(['a','b'])->validate('c'), "any_of will correctly fail (upgrading)");


TODO:{
	local $TODO = "https://github.com/pdl/Test-Proto/issues/37";
	my $trueval = {};
	my $weakref = \$trueval;
	use Scalar::Util 'weaken';
	weaken $weakref;
	my $strongref = \$trueval;

	is_a_good_pass(p->is_weak_ref->validate($weakref), "is_weak_ref will correctly pass");
	is_a_good_fail(p->is_weak_ref->validate($strongref), "is_weak_ref will correctly fail on strong refs");
	is_a_good_fail(p->is_weak_ref->validate('a'), "is_weak_ref will correctly fail on non-refs");
	is_a_good_pass(p->is_strong_ref->validate($strongref), "is_strong_ref will correctly pass");
	is_a_good_fail(p->is_strong_ref->validate($weakref), "is_strong_ref will correctly fail on weak refs");
	is_a_good_fail(p->is_strong_ref->validate('a'), "is_strong_ref will correctly fail on non-refs");
};

# is_a_good_exception(p->eq('a')->validate(undef), "undef eq 'a' should fail"); # Doesn't die, though, so maybe this is fine as a fail. ##????

{
	$_ = 3;
	is_a_good_pass(p->num_eq(3)->validate(), "validate implicitly takes \$_");
	is_a_good_pass(p->undefined->validate($undef), "validate undef is still undef even when \$_ is defined");
	is_a_good_pass(p->undefined->validate(sub{undef}->()), "validate undef is still undef even when \$_ is defined, and undef is created by an anon sub");
}


done_testing;

