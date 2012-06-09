package Test::Proto::String;
use 5.006;
use strict;
use warnings;
use base 'Test::Proto::Base';

sub initialise
{
	my ($self) = @_;
	$self->is_defined;
	$self->is_a('SCALAR');
}

return 1; # module loaded ok

=pod

=head1 NAME

Test::Proto::String - Test Prototype for strings.

=head1 SYNOPSIS

	Test::Proto::String->new->ok('123'); # ok
	Test::Proto::String->new->ok(undef); # not ok
	Test::Proto::String->new->ok([1,2,3]); # not ok

This is a test prototype which requires that the value it is given is defined and is a scalar. It provides methods for interacting with strings.

=head1 METHODS

Currently, all methods are inherited from L<Test::Proto::Base>. 

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut

