package Test::Proto::String;
use 5.006;
use strict;
use warnings;
use base 'Test::Proto::Base';

sub initialise
{
	my ($self) = @_;
	$self->is_defined;
}
sub is_eq
{
	my ($self, $expected, $why) = @_;
	$self->add_test('is_eq', $expected, $why);
}
sub is_ne
{
	my ($self, $expected, $why) = @_;
	$self->add_test('is_ne', $expected, $why);
}
sub is_like
{
	my ($self, $expected, $why) = @_;
	$self->add_test('is_like', $expected, $why);
}
sub is_unlike
{
	my ($self, $expected, $why) = @_;
	$self->add_test('is_unlike', $expected, $why);
}

1;

