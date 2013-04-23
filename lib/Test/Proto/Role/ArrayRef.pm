package Test::Proto::Role::ArrayRef;
use 5.006;
use strict;
use warnings;
use Test::Proto::Common;
use Moo::Role;

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

Finds the length of the array (number of items) and compares the result to the prototype provided in the argument.

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

Finds the nth item (where n is the first argument) and compares the result to the prototype provided in the second argument.

=cut

sub in_groups {
	my ($self, $groups, $expected, $reason) = @_;
	$self->add_test('in_groups', { 'groups' => $groups, expected => $expected }, $reason);
}

define_test in_groups => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
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
	my $length_result = Test::Proto::ArrayRef->new()->count_items($length)->validate($self->subject, $self);
	foreach my $i (0..$length){
		#upgrade($data->{expected}->[$i])->validate($self->subject->[$i], $self);
		Test::Proto::ArrayRef->new()->nth($i, $data->{expected}->[$i])->validate($self->subject, $self);
	}
};



1;

