package Test::Proto::Role::HashRef;
use 5.006;
use strict;
use warnings;
use Test::Proto::Common;
use Moo::Role;

sub key_has_value {
	my ($self, $key, $expected, $reason) = @_;
	$self->add_test('key_has_value', { key => $key, expected => $expected }, $reason);
}
define_test key_has_value => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = $self->subject->{$data->{key}}; 
	return upgrade($data->{expected})->validate($subject, $self);
};

sub count_keys {
	my ($self, $expected, $reason) = @_;
	$self->add_test('count_keys', { expected => $expected }, $reason);
}
define_test count_keys => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = scalar keys %{ $self->subject };
	return upgrade($data->{expected})->validate($subject, $self);
};

# simple_test count_keys => sub {
# 	my ($subject, $expected) = @_; # self is the runner, NOT the prototype
# 	return $expected == scalar keys %$subject;
# };

1;
