package Test::Proto::Role::HashRef;
use 5.006;
use strict;
use warnings;
use Test::Proto::Common;
use Moo::Role;

=head3 key_exists

	p->key_exists('a')->ok({a=>1, b=>2});

Returns true if the key exists (even if the value is undefined).

=cut

sub key_exists {
	my ($self, $key, $reason) = @_;
	$self->add_test('key_exists', { key => $key }, $reason);
}
define_test key_exists => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	return $self->pass if exists $self->subject->{$data->{key}}; 
	return $self->fail; 
};

=head3 key_has_value

	p->key_has_value('a',1)->ok({a=>1, b=>2});
	p->key_has_value('b',p->num_gt(0))->ok({a=>1, b=>2});

Returns the value of corresponding to the key provided within the subject, and tests it against the prototype provided in the argument.

=cut

sub key_has_value {
	my ($self, $key, $expected, $reason) = @_;
	$self->add_test('key_has_value', { key => $key, expected => $expected }, $reason);
}
define_test key_has_value => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = $self->subject->{$data->{key}}; 
	return upgrade($data->{expected})->validate($subject, $self);
};

=head3 count_keys

	p->count_keys(2)->ok({a=>1, b=>2});
	p->count_keys(p->num_gt(0))->ok({a=>1, b=>2});

Counts the keys of the hashref and compares them to the prototype provided. There is no equivalent count_values - the number should be identical!

=cut

sub count_keys {
	my ($self, $expected, $reason) = @_;
	$self->add_test('count_keys', { expected => $expected }, $reason);
}

define_test count_keys => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = scalar CORE::keys %{ $self->subject };
	return upgrade($data->{expected})->validate($subject, $self);
};

=head3 keys

	p->keys($tests_keys)->ok({a=>1, b=>2});

Returns the hash keys of the subject as an array reference (in an undetermined order), and tests them against the prototype provided in the argument.

In the above example, the C<ok> passes if the prototype C<$tests_keys> returns a pass for C<['a','b']> or C<['b','a']>.

=cut


sub keys {
	my ($self, $expected, $reason) = @_;
	$self->add_test('keys', { expected => $expected }, $reason);
}

define_test 'keys' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = [CORE::keys %{ $self->subject }];
	return upgrade($data->{expected})->validate($subject, $self);
};

=head3 values

	p->values($tests_values)->ok({a=>1, b=>2});

Produces the hash values of the subject as an array reference (in an undetermined order), and tests them against the prototype provided in the argument.

In the above example, the C<ok> passes if the prototype C<$tests_values> returns a pass for C<[1,2]> or C<[2,1]>.

=cut

sub values {
	my ($self, $expected, $reason) = @_;
	$self->add_test('values', { expected => $expected }, $reason);
}

define_test 'values' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = [CORE::values %{ $self->subject }];
	return upgrade($data->{expected})->validate($subject, $self);
};

=head3 enumerated

	p->enumerated($tests_key_value_pairs)->ok({a=>1, b=>2});

Produces the hash keys and values of the subject as an array reference (in an undetermined order), and tests them against the prototype provided in the argument.

In the above example, the prototype C<$tests_key_value_pairs> should return a pass for C<[['a','1'],['b','2']]> or C<[['b','2'],['a','1']]>.

=cut

sub enumerated {
	my ($self, $expected, $reason) = @_;
	$self->add_test('enumerated', { expected => $expected }, $reason);
}

define_test 'enumerated' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = [];
	push @$subject, [$_, $self->subject->{$_}] foreach (CORE::keys %{ $self->subject });
	return upgrade($data->{expected})->validate($subject, $self);
};


# simple_test count_keys => sub {
# 	my ($subject, $expected) = @_; # self is the runner, NOT the prototype
# 	return $expected == scalar keys %$subject;
# };

1;
