package Test::Proto::Role::ArrayRef;
use 5.006;
use strict;
use warnings;
use Test::Proto::Common;
use Moo::Role;

=head1 NAME

Test::Proto::Role::ArrayRef - Role containing test case methods for array refs.

=head1 SYNOPSIS

	package MyProtoClass;
	use Moo;
	with 'Test::Proto::Role::ArrayRef';

This Moo Role provides methods to Test::Proto::ArrayRef for test case methods that apply to arrayrefs such as C<map>. It can also be used for objects which use overload or otherwise respond to arrayref syntax.

=head1 METHODS

=head3 map

	pArray->map(sub { uc shift }, ['A','B'])->ok(['a','b']);

Applies the first argument (a coderef) onto each member of the array. The resulting array is compared to the second argument.

=cut

sub map {
	my ($self, $code, $expected, $reason) = @_;
	$self->add_test('map', { code=> $code, expected => $expected }, $reason);
}

define_test 'map' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = [ map { $data->{code}->($_) } @{ $self->subject } ];
	return upgrade($data->{expected})->validate($subject, $self);
};

=head3 grep

	pArray->grep(sub { $_[0] eq uc $_[0] }, ['A'])->ok(['A','b']); # passes
	pArray->grep(sub { $_[0] eq uc $_[0] }, [])->ok(['a','b']); # passes
	pArray->grep(sub { $_[0] eq uc $_[0] })->ok(['a','b']); # fails - 'boolean' grep behaves like array_any

Applies the first argument (a prototype) onto each member of the array; if it returns true, the member is added to the resulting array. The resulting array is compared to the second argument.

=cut

sub grep {
	my ($self, $code, $expected, $reason) = @_;
	if (defined $expected) {
		$self->add_test('grep', { match => $code, expected => $expected }, $reason);
	}
	else {
		$self->add_test('array_any', { match => $code }, $reason);
	}
}

define_test 'grep' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = [ grep { upgrade($data->{match})->validate($_) } @{ $self->subject } ];
	return upgrade($data->{expected})->validate($subject, $self);
};

=head3 array_any

	pArray->array_any(sub { $_[0] eq uc $_[0] })->ok(['A','b']); # passes
	pArray->array_any(sub { $_[0] eq uc $_[0] })->ok(['a','b']); # fails

Applies the first argument (a prototype) onto each member of the array; if any member returns true, the test case succeeds.

=cut


sub array_any {
	my ($self, $expected, $reason) = @_;
	$self->add_test('array_any', { match => $expected }, $reason);
}

define_test 'array_any' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $i = 0;
	foreach my $single_subject ( @{ $self->subject } ){
		return $self->pass("Item $i matched") if upgrade($data->{match})->validate($single_subject);
		$i++;
	}
	return $self->fail('None matched');
};

=head3 array_none

	pArray->array_none(sub { $_[0] eq uc $_[0] })->ok(['a','b']); # passes
	pArray->array_none(sub { $_[0] eq uc $_[0] })->ok(['A','b']); # fails

Applies the first argument (a prototype) onto each member of the array; if any member returns true, the test case fails.

=cut


sub array_none {
	my ($self, $code, $reason) = @_;
	$self->add_test('array_none', { code => $code }, $reason);
}

define_test 'array_none' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $i = 0;
	foreach my $single_subject ( @{ $self->subject } ){
		return $self->fail("Item $i matched") if upgrade($data->{code})->validate($single_subject);
		$i++;
	}
	return $self->pass('None matched');
};

=head3 array_all

	pArray->array_all(sub { $_[0] eq uc $_[0] })->ok(['A','B']); # passes
	pArray->array_all(sub { $_[0] eq uc $_[0] })->ok(['A','b']); # fails

Applies the first argument (a prototype) onto each member of the array; if any member returns false, the test case fails.

=cut


sub array_all {
	my ($self, $code, $reason) = @_;
	$self->add_test('array_all', { code => $code }, $reason);
}

define_test 'array_all' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $i = 0;
	foreach my $single_subject ( @{ $self->subject } ){
		return $self->fail("Item $i did not match") unless upgrade($data->{code})->validate($single_subject);
		$i++;
	}
	return $self->pass('All matched');
};


=head3 reduce

	pArray->reduce(sub { $_[0] + $_[1] }, 6 )->ok([1,2,3]);

Applies the first argument (a coderef) onto the first two elements of the array, and thereafter the next element and the return value of the previous calculation. Similar to List::Util::reduce.

=cut

sub reduce {
	my ($self, $code, $expected, $reason) = @_;
	$self->add_test('reduce', { code=> $code, expected => $expected }, $reason);
}

define_test 'reduce' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $length = $#{ $self->subject };
	return $self->exception ('Cannot use reduce unless the subject has at least two elements; only '. ( $length + 1 ). ' found') unless $length; 
	my $left = ${ $self->subject }[0];
	my $right;
	my $i = 1;
	while ($i <= $length) {
		$right = ${ $self->subject }[$i];
		$left = $data->{code}->($left, $right);
		$i++;
	}
	return upgrade($data->{expected})->validate($left, $self);
};

=head3 nth

	pArray->nth(1,'b')->ok(['a','b']);

Finds the nth item (where n is the first argument) and compares the result to the prototype provided in the second argument.

=cut

sub nth {
	my ($self, $index, $expected, $reason) = @_;
	$self->add_test('nth', { 'index' => $index, expected => $expected }, $reason);
}

define_test nth => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	if (exists $self->subject->[$data->{'index'}]) {
		my $subject = $self->subject->[$data->{'index'}];
		return upgrade($data->{expected})->validate($subject, $self);
	}
	else {
		return $self->exception('The index '.$data->{'index'}.' does not exist.')
	}
};


=head3 count_items

	pArray->count_items(2)->ok(['a','b']);

Finds the length of the array (i.e. the number of items) and compares the result to the prototype provided in the argument.

=cut

sub count_items {
	my ($self, $expected, $reason) = @_;
	$self->add_test('count_items', { expected => $expected }, $reason);
}

define_test count_items => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = scalar @{ $self->subject };
	return upgrade($data->{expected})->validate($subject, $self);
};

=head3 enumerated

	pArray->enumerated($tests_enumerated)->ok(['a','b']);

Produces the indices and values of the subject as an array reference, and tests them against the prototype provided in the argument.

In the above example, the prototype C<$tests_enumerated> should return a pass for C<[[1,'a'],[2,'b']]>.

=cut

sub enumerated {
	my ($self, $expected, $reason) = @_;
	$self->add_test('enumerated', { expected => $expected }, $reason);
}

define_test 'enumerated' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = [];
	push @$subject, [$_, $self->subject->{$_}] foreach (0..$#{ $self->subject });
	return upgrade($data->{expected})->validate($subject, $self);
};

=head3 in_groups

	pArray->in_groups(2,[['a','b'],['c','d'],['e']])->ok(['a','b','c','d','e']);

Bundles the contents in groups of n (where n is the first argument), puts each group in an arrayref, and compares the resulting arrayref to the prototype provided in the second argument.

=cut

sub in_groups {
	my ($self, $groups, $expected, $reason) = @_;
	$self->add_test('in_groups', { 'groups' => $groups, expected => $expected }, $reason);
}

define_test in_groups => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	return $self->exception('in_groups needs groups of 1 or more') if $data->{'groups'} < 1;
	my $newArray = [];
	my $i = 0;
	my $currentGroup = [];
	foreach my $item (@{ $self->subject }){
		if (0 == ($i % $data->{'groups'})){
			push @$newArray, $currentGroup if defined $currentGroup and @$currentGroup;
			$currentGroup = [];
		}
		push @$currentGroup, $item;
		$i++;
	}
	push @$newArray, $currentGroup if defined $currentGroup and @$currentGroup;
	return upgrade($data->{expected})->validate($newArray, $self);
};

=head3 group_when

	pArray->group_when(sub {$_[eq uc $_[0]} ,[['A'],['B','c','d'],['E']])->ok(['A','B','c','d','E']);
	pArray->group_when(sub {$_[0] eq $_[0]} ,[['a','b','c','d','e']])->ok(['a','b','c','d','e']);

Bundles the contents of the test subject in groups; a new group is created when the member matches the first argument (a prototype). The resulting arrayref is compared to the second argument.

=cut

sub group_when {
	my ($self, $condition, $expected, $reason) = @_;
	$self->add_test('group_when', { 'condition' => $condition, expected => $expected }, $reason);
}

define_test group_when => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $newArray = [];
	my $currentGroup = [];
	my $condition = upgrade ($data->{condition});
	foreach my $item (@{ $self->subject }) {
		if ($condition->validate($item)){
			push @$newArray, $currentGroup if defined $currentGroup and @$currentGroup;
			$currentGroup = [];
		}
		push @$currentGroup, $item;
	}
	push @$newArray, $currentGroup if defined $currentGroup and @$currentGroup;
	return upgrade($data->{expected})->validate($newArray, $self);
};

=head3 array_eq

	pArray->array_eq(['a','b'])->ok(['a','b']);

Compares the elements of the test subject with the elements of the first argument, using the C<upgrade> feature.

=cut

sub array_eq {
	my ($self, $expected, $reason) = @_;
	$self->add_test('array_eq', { expected => $expected }, $reason);
}

define_test array_eq => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $length = scalar @{ $data->{expected} };
	my $length_result = Test::Proto::ArrayRef->new()->count_items($length)->validate($self->subject, $self->subtest);
	if ($length_result) {
		foreach my $i (0..($length-1)){
			#upgrade($data->{expected}->[$i])->validate($self->subject->[$i], $self);
			Test::Proto::ArrayRef->new()->nth($i, $data->{expected}->[$i])->validate($self->subject, $self->subtest);
		}
	}
	$self->done;
};

=head3 range

	pArray->range('1,3..4',[9,7,6,5])->ok([10..1]);

Finds the range specified in the first element, and compares them to the second element.

=cut

sub range {
	my ($self, $range, $expected, $reason) = @_;
	$self->add_test('range', { range=>$range, expected => $expected }, $reason);
}

define_test range => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $range = $data->{range};
	my $result = [];
	my $length = scalar @{ $self->subject };
	$range =~ s/-(\d+)/$length - $1/ge;
	$range =~ s/\.\.$/'..' . ($length - 1)/e;
	$range =~ s/^\.\./0../;
	return $self->exception('Invalid range specified') unless $range =~ m/^(?:\d+|\d+..\d+)(?:,(\d+|\d+..\d+))*$/;
	my @range = eval ("($range)"); # surely there is a better way?
	foreach my $i (@range) {
		return $self->fail("Element $i does not exist") unless exists $self->subject->[$i];
		push (@$result, $self->subject->[$i]);
	}
	return upgrade($data->{expected})->validate($result, $self);
};

=head3 reverse

	pArray->reverse([10..1])->ok([1..10]);

Reverses the order of elements and compares the result to the prototype given.

=cut

sub reverse {
	my ($self, $expected, $reason) = @_;
	$self->add_test('reverse', { expected => $expected }, $reason);
}

define_test reverse => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $reversed = [ CORE::reverse @{ $self->subject }];
	return upgrade($data->{expected})->validate($reversed, $self);
};


=head3 array_before

	pArray->array_before('b',['a'])->ok(['a','b']); # passes

Applies the first argument (a prototype) onto each member of the array; if any member returns true, the second argument is validated against a new arrayref containing all the preceding members of the array.

=cut


sub array_before {
	my ($self, $match, $expected, $reason) = @_;
	$self->add_test('array_before', { match => $match, expected => $expected }, $reason);
}

define_test 'array_before' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $i = 0;
	foreach my $single_subject ( @{ $self->subject } ){
		if (upgrade($data->{match})->validate($single_subject)) {
			# $self->add_info("Item $i matched")
			my $before = [ @{ $self->subject }[0..$i] ];
			pop @$before unless $data->{include_self};
			return upgrade($data->{expected})->validate($before, $self);
		}
		$i++;
	}
	return $self->fail('None matched');
};

=head3 array_after

	pArray->after('a',['b'])->ok(['a','b']); # passes

Applies the first argument (a prototype) onto each member of the array; if any member returns true, the second argument is validated against a new arrayref containing all the following members of the array.

=cut


sub array_after {
	my ($self, $match, $expected, $reason) = @_;
	$self->add_test('array_after', { match => $match, expected => $expected }, $reason);
}

define_test 'array_after' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $i = 0;
	foreach my $single_subject ( @{ $self->subject } ){
		if (upgrade($data->{match})->validate($single_subject)) {
			# $self->add_info("Item $i matched")
			my $last_index = $#{$self->subject};
			my $after = [ @{ $self->subject }[$i..$last_index] ];
			pop @$after unless $data->{include_self};
			return upgrade($data->{expected})->validate($after, $self);
		}
		$i++;
	}
	return $self->fail('None matched');
};

# Unordered comparisons

=head3 set_of

	pArray->set_of(['a','b','c'])->ok(['a','c','a','b']); # passes

Checks that all of the elements in the test subject match at least one element in the first argument, and vice versa. Members of the test subject may be 'reused'.

=cut


sub set_of {
	my ($self, $expected, $reason) = @_;
	$self->add_test('unordered_comparison', { expected => $expected, method=>'set' }, $reason);
}

=head3 bag_of

	pArray->bag_of(['a','b','c'])->ok(['c','a','b']); # passes

Checks that all of the elements in the test subject match at least one element in the first argument, and vice versa. Members may B<not> be 'reused'.

=cut


sub bag_of {
	my ($self, $expected, $reason) = @_;
	$self->add_test('unordered_comparison', { expected => $expected, method=>'bag' }, $reason);
}

=head3 subset_of

	pArray->subset_of(['a','b','c'])->ok(['a','a','b']); # passes

Checks that all of the elements in the test subject match at least one element in the first argument. Members of the test subject may be 'reused'.

=cut


sub subset_of {
	my ($self, $expected, $reason) = @_;
	$self->add_test('unordered_comparison', { expected => $expected, method=>'subset' }, $reason);
}

=head3 superset_of

	pArray->superset_of(['a','b','a'])->ok(['a','b','c']); # passes

Checks that all of the elements in the first argument can validate at least one element in the test subject. Members of the test subject may be 'reused'.

=cut


sub superset_of {
	my ($self, $expected, $reason) = @_;
	$self->add_test('unordered_comparison', { expected => $expected, method=>'superset' }, $reason);
}

=head3 subbag_of

	pArray->subbag_of(['a','b','c'])->ok(['a','b']); # passes

Checks that all of the elements in the test subject match at least one element in the first argument. Members of the test subject may B<not> be 'reused'.

=cut


sub subbag_of {
	my ($self, $expected, $reason) = @_;
	$self->add_test('unordered_comparison', { expected => $expected, method=>'subbag' }, $reason);
}

=head3 superbag_of

	pArray->superbag_of(['a','b'])->ok(['a','b','c']); # passes

Checks that all of the elements in the first argument can validate at least one element in the test subject. Members of the test subject may B<not> be 'reused'.

=cut

sub superbag_of {
	my ($self, $expected, $reason) = @_;
	$self->add_test('unordered_comparison', { expected => $expected, method=>'superbag' }, $reason);
}

my $machine;
define_test 'unordered_comparison' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	return $machine->($self, $data->{method}, $self->subject, $data->{expected});
};

my ($allocate_l, $allocate_r);
$allocate_l = sub{
	my ($matrix, $pairs, $bag) = @_;
	my $best = $pairs;
	LEFT: foreach my $l (0..$#{$matrix}) {
		next LEFT if grep { $_->[0] == $l } @$pairs; # skip if already allocated
		RIGHT: foreach my $r (0..$#{$matrix->[$l]}) {
			next RIGHT if $bag and grep { $_->[1] == $r } @$pairs; # skip if already allocated and bag logic
			if ($matrix->[$l]->[$r]){
				my $result = $allocate_l->($matrix, [@$pairs, [$l, $r]], $bag);
				$best = $result if ( @$result > @$best);
				# short circuit if length of Best == length of matrix ?
			}
		}
	}
	return $best;
};
$allocate_r = sub{
	my ($matrix, $pairs, $bag) = @_;
	my $best = $pairs;
	RIGHT: foreach my $r (0..$#{$matrix->[0]}) {
		next RIGHT if grep { $_->[1] == $r } @$pairs; # skip if already allocated
		LEFT: foreach my $l (0..$#{$matrix}) {
			next LEFT if $bag and grep { $_->[0] == $l } @$pairs; # skip if already allocated and bag logic
			if ($matrix->[$l]->[$r]){
				my $result = $allocate_r->($matrix, [@$pairs, [$l, $r]], $bag);
				$best = $result if (@$result > @$best);
			}
		}
	}
	return $best;
};
$machine = sub {
	my ($runner, $method, $left, $right) = @_;
	my $bag = ( $method =~ /bag$/ );
	my $matrix = [];
	my $super = ($method =~ m/^super/);
	# prepare the results matrix
	LEFT: foreach my $l (0..$#{$left}) {
		RIGHT: foreach my $r (0..$#{$right}) {
			my $result = upgrade($right->[$r])->validate($left->[$l], ); #$runner->subtest("Comparing subject->[$l] and expected->[$r]"));
			$matrix->[$l]->[$r] = $result;
		}
	}
	my $pairs = [];

	my $allocation_l = $allocate_l->($matrix, $pairs, $bag);
	my $allocation_r = $allocate_r->($matrix, $pairs, $bag);

	if ($method =~ m/^(sub|)(bag|set)$/){
		foreach my $l (0..$#{$left}){
			unless (grep { $_->[0] == $l } @$allocation_l) {
				return $runner->fail('Not a superbag') if $bag;
				return $runner->fail('Not a superset');
			}

		}
	}
	if ($method =~ m/^(super|)(bag|set)$/){
		foreach my $r (0..$#{$right}){
			unless (grep { $_->[1] == $r } @$allocation_r) {
				return $runner->fail('Not a superbag') if $bag;
				return $runner->fail('Not a superset');
			}
		}
	}
	return $runner->pass("Successful");
};






1;

