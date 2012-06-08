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
	my ($method) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval { $result = $got->CORE::can($method); };
#?		return fail ($@) if $@;
		return $result ? $result : fail('Object cannot '. $method);
	}
}
sub try_can
{
	my ($self, $method, $args, $expected, $why) = @_;
	$self->add_test(_try_can($method, $args, $self->upgrade($expected)), $why);
}

sub _try_can
{
	my ($method, $args, $expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval { $result = $expected->validate($got->$method(@$args)); };
		return $result if defined $result;
		return Test::Proto::Base::exception ($@) if $@;
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

	Test::Proto::Object->new->ok($object); # ok
	Test::Proto::Object->new->ok('1'); # not ok
	Test::Proto::Object
		->new->try_can(
			'toString', [], ['<div/>'], 'Element div toString returns <div/>'
		)->ok($object);

This is a test prototype which requires that the value it is given is defined and is a scalar. It provides methods for interacting with strings.

=head1 METHODS

See L<Test::Proto::Base> for documentation on common methods.

=head3 can

	$prototype->can('toString', 'has a toString method')->ok($object);

This method adds a test equivalent to Perl's builtin C<can>, i.e. tests if an object has a method with the given name. It does not actually execute this method. 

=head3 try_can

	$prototype->try_can('toString', [], ['<div/>'], 'Element div toString returns <div/>')->ok($object);
	# is_deeply($object->toString   (), ['<div/>'], 'Element div toString returns <div/>');

This method allows you to make method calls to your object and test the result. Arguments are: 1) the method name; 2) an arrayref containing the arguments you want to pass to the method call; 3) an arrayref containing the results; 4) Optionally, the reason for the test. 

NB: Results are evaluated in list context and what is available for testing is always an arrayref. 

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut

1;

