package Test::Proto::Role::HashRef;
use 5.006;
use strict;
use warnings;
use Test::Proto::TestRunner;
use Test::Proto::TestCase;
use Test::Proto::Base;
use Moo::Role;

sub key_has_value {
	my ($self, $key, $expected, $reason) = @_;
	$self->add_test('key_has_value', { key => $key, expected => $expected }, $reason);
}
Test::Proto::Base::define_test key_has_value => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $subject = $self->subject->{$data->{key}}; 
	return $self->upgrade($data->{expected})->validate($subject, $self);
};

1;
