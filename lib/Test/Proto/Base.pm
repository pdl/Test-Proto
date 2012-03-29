package Test::Proto::Base;
use 5.006;
use strict;
use warnings;
use base 'Test::Builder::Module';
use Test::Proto::Test;
use Test::Proto::Fail;
use Data::Dumper;
my $CLASS = __PACKAGE__;

sub initialise
{
	return $_[0];
}
sub new
{
	my $class = shift;
	my $self = bless {
		tests=>[],
	}, $class;
	return $self->initialise;
}
sub add_test #???
{
	my ($self, $testtype, @args) = @_;
	my $test = Test::Proto::Test->new($testtype, @args);

	if ( defined $test)
	{
		push @{$self->{'tests'}}, $test;
	}
	else
	{
		warn 'Failed to create test!'; # exception?
		return undef;
	}

	return $self;
}

sub validate
{
	my ($self, $got) = @_;
	foreach (@{$self->{'tests'}})
	{
		my $result = $_->run($got);
		return $result unless $result;
	}
	return 1;
}
sub is_also
{
	my ($self, $expected, $why) = @_;
	$self->add_test('is_also', $expected, $why);
}

sub is_a
{
	my ($self, $expected, $why) = @_;
	$self->add_test('is_a', $expected, $why);
}
sub is_defined
{
	my ($self, $why) = @_;
	$self->add_test('is_defined', $why);
}
sub ok
{
	my($self, $got, $why) = @_;
	my $tb = $CLASS->builder;
	my $result = $self->validate($got);
	# output failure?
	return $tb->ok($result, $why);
}

sub fail
{
	my ($self, $name, $why) = @_;
	return Test::Proto::Fail->new();
}

1;

