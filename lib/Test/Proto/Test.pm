package Test::Proto::Test;
use 5.006;
use strict;
use warnings;
use Data::Dumper;
use Test::Proto::Fail;
use base 'Test::Builder::Module';
my $CLASS = __PACKAGE__;

sub new
{
	my ($class, $test, @args) = @_;

	my $self = bless {
		tests=>[], # coderefs which return fail object or 1
	}, $class;
	if (!defined $test)
	{
		return $self;
	}
	elsif (ref ($test) eq ref (sub{})  )
	{
		push @{$self->{'tests'}},$test;
		return $self;
	}
	return undef;
}

sub run
{
	my ($self, $got) = @_;
	foreach (@{$self->{'tests'}})
	{
		my $result = &{$_}($got);
		return $result unless $result;
	}
	return 1;
}
1;

=pod

=head1 NAME

Test::Proto::Test - container for test and test-related information

=head1 SYNOPSIS

	Test::Proto::Test->new(sub{return $_[0]=~/\w/;})->run('Content!'); # ok

This is a minimal test object class for use in subclasses of L<Test::Proto::Base>. It stores the codered
It returns 1 or the result or the test if it failed. Coderefs should ideally return a L<Test::Proto::Fail> object if they fail, but this is not enforced.

=head1 METHODS

=head3 new

Create a new test. The first argument should be the code to be run. Supply the thing being tested later.

=head3 run

Execute the test on the argument.

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut

