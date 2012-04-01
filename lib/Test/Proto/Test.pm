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

