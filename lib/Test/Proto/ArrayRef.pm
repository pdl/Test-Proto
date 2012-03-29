package Test::Proto::ArrayRef;
use 5.006;
use strict;
use warnings;
use base 'Test::Proto::Base';

sub is_empty
{
	my ($self, $why) = @_;
	$self->array_length(0, $why);
}
sub array_length
{
	my ($self, $expected, $why) = @_;
	$self->add_test('array_length', $expected, $why);
}

sub grep
{
	my ($self, $code, $expected, $why) = @_;
	$self->add_test('grep', $code, $expected, $why);
}
1;

