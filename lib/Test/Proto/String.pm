package Test::Proto::String;
use 5.006;
use strict;
use warnings;
use base 'Test::Proto::Base';

sub initialise
{
	my ($self) = @_;
	$self->is_defined;
	$self->is_a('SCALAR'); # implies we ought to move all the functions which stringify into , as it's legitimate to test what "$object" does.
}

1;

