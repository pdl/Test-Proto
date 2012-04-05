package Test::Proto::Object;
use 5.006;
use strict;
use warnings;
use base 'Test::Proto::Base';

sub initialise
{
	my ($self) = @_;
	$self->is_defined;
	#$self->is_a(); # ref? dunno
}

sub can
{
	my ($self, $method, $why) = @_;
	$self->add_test(_can($method), $why);
}

sub _can
{
	my ($method, $why) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval { $result = $got->CORE::can($method); };
#?		return fail ($@) if $@;
		return $result ? $result : fail ('Object cannot '. $method);
	}
}

sub fail
{
	Test::Proto::Base::fail(@_);
}

=pod
=head1 NAME

Test::Proto::Object - Test Prototype for objects.

=head1 SYNOPSIS

	Test::Proto::Object->new->ok('123'); # ok
	Test::Proto::String->new->ok(undef); # not ok
	Test::Proto::String->new->ok([1,2,3]); # not ok

This is a test prototype which requires that the value it is given is defined and is a scalar. It provides methods for interacting with strings.

=head1 METHODS

Currently, all methods are inherited from L<Test::Proto::Base>. 

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 
=cut
1;

