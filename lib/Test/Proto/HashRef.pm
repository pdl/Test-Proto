package Test::Proto::HashRef;
use 5.006;
use strict;
use warnings;
use base 'Test::Proto::Base';

sub keys
{
	my ($self, $expected, $why) = @_;
	$self->add_test('keys', $expected, $why);
}

1;

