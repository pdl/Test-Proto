package Test::Proto::Role::ArrayRef;
use 5.006;
use strict;
use warnings;
use Test::Proto::Common;
use Moo::Role;

=head3 nth

	p->nth(0,'b')->ok(['a','b']);

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
		$self->exception('The index '.$data->{'index'}.' does not exist.')
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



1;

