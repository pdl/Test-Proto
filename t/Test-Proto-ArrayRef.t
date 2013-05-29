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

# nth
is_a_good_pass(pAr->nth(1, 'b')->validate(['a','b']), "nth: item 1 of ['a','b'] is 'b'");
is_a_good_fail(pAr->nth(1, 'a')->validate(['a','b']), "nth: item 1 of ['a','b'] is not 'a'");
# is_a_good_exception(pAr->nth(2, 'b')->validate(['a','b']), "item 2 of ['a','b'] does not exist"); # or should it fail with an out of bounds message?

# map
is_a_good_pass(pAr->map(sub {uc shift;}, ['A','B'])->validate(['a','b']), "map passes with a transform");
is_a_good_pass(pAr->map(sub {shift;}, ['a','b'])->validate(['a','b']), "map passes with no transform");
is_a_good_fail(pAr->map(sub {uc shift;}, ['a','b'])->validate(['a','b']), "map fails when expected does not match");

# grep
is_a_good_pass(pAr->grep(sub {$_[0] eq uc $_[0]}, ['A'])->validate(['A','b']), "grep passes");
is_a_good_pass(pAr->grep(sub {$_[0] eq uc $_[0]}, [])->validate(['a','b']), "grep passes when nothing matches");
is_a_good_fail(pAr->grep(sub {$_[0] eq uc $_[0]}, ['a','b'])->validate(['A','b']), "grep fails when expected does not match");

# grep (1 arg form)
is_a_good_pass(pAr->grep(sub {$_[0] eq uc $_[0]})->validate(['A','b']), "boolean grep passes when something matches");
is_a_good_fail(pAr->grep(sub {$_[0] eq uc $_[0]})->validate(['a','b']), "boolean grep fails when nothing matches");

# array_any
is_a_good_pass(pAr->array_any(sub {$_[0] eq uc $_[0]})->validate(['A','b']), "array_any passes when something matches");
is_a_good_fail(pAr->array_any(sub {$_[0] eq uc $_[0]})->validate(['a','b']), "array_any fails when nothing matches");

# array_none
is_a_good_pass(pAr->array_none(sub {$_[0] eq uc $_[0]})->validate(['a','b']), "array_none passes when nothing matches");
is_a_good_fail(pAr->array_none(sub {$_[0] eq uc $_[0]})->validate(['A','b']), "array_none fails when something matches");

# array_all
is_a_good_pass(pAr->array_all(sub {$_[0] eq uc $_[0]})->validate(['A','B']), "array_all passes when everything matches");
is_a_good_fail(pAr->array_all(sub {$_[0] eq uc $_[0]})->validate(['A','b']), "array_all fails when anything does not match");

# reduce
is_a_good_pass(pAr->reduce(sub { $_[0] + $_[1] }, 6 )->validate([1,2,3]), "reduce passes when result matches");
is_a_good_fail(pAr->reduce(sub { $_[0] + $_[1] }, 7 )->validate([1,2,3]), "reduce fails when result does not match");
is_a_good_exception(pAr->reduce(sub { $_[0] + $_[1] }, 7 )->validate([1]), "reduce is exception when subject has less than two members");

# array_eq
is_a_good_pass(pAr->array_eq(['a','b'])->validate(['a','b']), "['a','b'] is ['a','b']");
is_a_good_pass(pAr->array_eq(['a',['b']])->validate(['a',['b']]), "['a',['b']] is ['a',['b']]");
is_a_good_pass(pAr->array_eq([])->validate([]), "[] is  []");
is_a_good_fail(pAr->array_eq(['a','b'])->validate(['a']), "['a'] is not ['a','b']");
is_a_good_fail(pAr->array_eq(['a'])->validate(['a', 'b']), "['a','b'] is not ['a']");
is_a_good_fail(pAr->array_eq(['a','b'])->validate(['b','a']), "['b','a'] is not ['a','b']");

# in_groups
is_a_good_pass(pAr->in_groups(2,[['a','b'],['c','d']])->validate(['a','b','c','d']), "in_groups works");
is_a_good_pass(pAr->in_groups(2,[])->validate([]), "in_groups works with empty list");
is_a_good_pass(pAr->in_groups(1,[['a'],['b'],['c'],['d']])->validate(['a','b','c','d']), "in_groups works with n=1");
is_a_good_pass(pAr->in_groups(2,[['a','b'],['c','d'],['e']])->validate(['a','b','c','d','e']), "in_groups works with remainders");
is_a_good_fail(pAr->in_groups(2,[])->validate(['a','b','c','d']), "in_groups fails when no match");
is_a_good_exception(pAr->in_groups(0,[['a'],['b'],['c'],['d']])->validate(['a','b','c','d']), "in_groups throws exceptions when n<1");

# group_when
is_a_good_pass(pAr->group_when(sub {$_[0] eq uc $_[0]} ,[['A'],['B','c','d'],['E']])->validate(['A','B','c','d','E']), "group_when works");
is_a_good_pass(pAr->group_when(sub {$_[0] eq uc $_[0]} ,[['a','b','c','d','e']])->validate(['a','b','c','d','e']), "group_when works when it matches nothing");

# count_items
is_a_good_pass(pAr->count_items(2)->validate(['a','b']), "count_items 2 on ['a','b'] passes");
is_a_good_fail(pAr->count_items(1)->validate(['a','b']), "count_items 1 on ['a','b'] fails");
is_a_good_pass(pAr->count_items(p->num_lt(5))->validate(['a','b']), "count_items <5 on ['a','b'] passes");
is_a_good_fail(pAr->count_items(p->num_gt(5))->validate(['a','b']), "count_items >5 on ['a','b'] fails");

# range
is_a_good_pass(pAr->range(1, ['b'])->validate(['a','b']), "range: item 1 of ['a','b'] is 'b'");
is_a_good_fail(pAr->range(1, ['a'])->validate(['a','b','c','d']), "range: item 1 of ['a','b'] is not 'a'");
is_a_good_pass(pAr->range('1,3', ['b','d'])->validate(['a','b','c','d']), "range: comma");
is_a_good_pass(pAr->range('0,1,3', ['a','b','d'])->validate(['a','b','c','d']), "range: multiple commas");
is_a_good_pass(pAr->range('1,1,3', ['b','b','d'])->validate(['a','b','c','d']), "range: repeated elements");
is_a_good_pass(pAr->range('0..2', ['a','b','c'])->validate(['a','b','c','d']), "range: .. operator from beginning");
is_a_good_pass(pAr->range('1..3', ['b','c','d'])->validate(['a','b','c','d']), "range: .. operator to end");
is_a_good_pass(pAr->range('0..1,3', ['a','b','d'])->validate(['a','b','c','d']), "range: .. and comma");
is_a_good_pass(pAr->range('0..1,2..3', ['a','b','c','d'])->validate(['a','b','c','d']), "range: multiple ..");
is_a_good_pass(pAr->range('0..1,1..3', ['a','b','b','c','d'])->validate(['a','b','c','d']), "range: overlapping ..");

# reverse
is_a_good_pass(pAr->reverse([qw (d c b a)])->validate(['a','b','c','d']), "reverse passes when expected matches");
is_a_good_fail(pAr->reverse([qw (a b c d)])->validate(['a','b','c','d']), "reverse fails when expected does not match");

done_testing;


