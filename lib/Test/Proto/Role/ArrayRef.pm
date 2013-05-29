package Test::Proto::Role::ArrayRef;
use 5.006;
use strict;
use warnings;
use Test::Proto::Common;
use Moo::Role;


=head3 map

	pAr->map(sub { uc shift }, ['A','B'])->ok(['a','b']);

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

	pAr->grep(sub { $_[0] eq uc $_[0] }, ['A'])->ok(['A','b']); # passes
	pAr->grep(sub { $_[0] eq uc $_[0] }, [])->ok(['a','b']); # passes
	pAr->grep(sub { $_[0] eq uc $_[0] })->ok(['a','b']); # fails - 'boolean' grep behaves like array_any

Applies the first argument (a prototype) onto each member of the array; if it returns true, the member is added to the resulting array. The resulting array is compared to the second argument.

=cut

sub grep {
	my ($self, $code, $expected, $reason) = @_;
	if (defined $expected) {
		$self->add_test('grep', { code => $code, expected => $expected }, $reason);
	}
	else {
		$self->add_test('array_any', { code => $code }, $reason);
	}
}

define_test 'grep' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = [ grep { upgrade($data->{code})->validate($_) } @{ $self->subject } ];
	return upgrade($data->{expected})->validate($subject, $self);
};

=head3 array_any

	pAr->array_any(sub { $_[0] eq uc $_[0] })->ok(['A','b']); # passes
	pAr->array_any(sub { $_[0] eq uc $_[0] })->ok(['a','b']); # fails

Applies the first argument (a prototype) onto each member of the array; if any member returns true, the test case succeeds.

=cut


sub array_any {
	my ($self, $code, $reason) = @_;
	$self->add_test('array_any', { code => $code }, $reason);
}

define_test 'array_any' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $i = 0;
	foreach my $single_subject ( @{ $self->subject } ){
		return $self->pass("Item $i matched") if upgrade($data->{code})->validate($single_subject);
		$i++;
	}
	return $self->fail('None matched');
};

=head3 array_none

	pAr->array_none(sub { $_[0] eq uc $_[0] })->ok(['a','b']); # passes
	pAr->array_none(sub { $_[0] eq uc $_[0] })->ok(['A','b']); # fails

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


=head3 reduce

	pAr->reduce(sub { $_[0] + $_[1] }, 6 )->ok([1,2,3]);

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

	p->nth(1,'b')->ok(['a','b']);

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

	p->count_items(2)->ok(['a','b']);

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

	p->enumerated($tests_enumerated)->ok(['a','b']);

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

	p->in_groups(2,[['a','b'],['c','d'],['e']])->ok(['a','b','c','d','e']);

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

	p->group_when(sub {$_[eq uc $_[0]} ,[['A'],['B','c','d'],['E']])->ok(['A','B','c','d','E']);
	p->group_when(sub {$_[0] eq $_[0]} ,[['a','b','c','d','e']])->ok(['a','b','c','d','e']);

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

	p->array_eq(['a','b'])->ok(['a','b']);

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



1;

