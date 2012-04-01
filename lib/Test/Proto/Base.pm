package Test::Proto::Base;
use 5.006;
use strict;
use warnings;
use base 'Test::Builder::Module';
use Test::Deep::NoTest; # provides eq_deeply for _is_deeply. Consider removing this dependency.
use Test::Proto::Test;
use Test::Proto::Fail;
use Data::Dumper; # not used in canonical but keep for the moment for development
$Data::Dumper::Indent = 0;
$Data::Dumper::Terse = 1;
$Data::Dumper::Sortkeys = 1;
our $VERSION = '0.01';
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

	if (defined $test)
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
sub _is_defined
{
	return sub{
		my $got = shift;
		return fail('undef') unless defined $got;
		return 1;
	};
}
sub _can_be_string
{
	return sub{
		eval {$_[0] .= ''};
		return fail($@) if $@;
		return 1;
	};
}
sub _is_a
{
	my ($type) = @_;
	return sub{
		my $got = shift;
		$type = ref $type if (ref $type);
		unless (ref $got)
		{
			return 'SCALAR' eq $type ? 1 : fail('SCALAR ne '.$type) ;
		}
		foreach (qw(
		SCALAR
		ARRAY
		HASH
		CODE
		REF
		GLOB
		LVALUE
		FORMAT
		IO
		VSTRING
		Regexp))
		{
			if (ref $got eq $_)
			{
				return $_ eq $type ? 1 : fail ("$_ ne $type");
			}
		}
		return $got->isa($type);
	}
}
sub _is_ne
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = "$got" ne "$expected"};
		return fail($@) if $@;
		return $result ? 1 : fail("\"$got\" eq \"$expected\"");
	};
}
sub _is_also
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = $expected->validate($got)};
		return fail($@) if $@;
		return $result;
	};
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
	$self->add_test(_is_also($expected), $why);
}

sub is_a
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_a($expected), $why);
}
sub is_defined
{
	my ($self, $why) = @_;
	$self->add_test(_is_defined(), $why);
}
sub ok
{
	my($self, $got, $why) = @_;
	my $tb = $CLASS->builder;
	my $result = $self->validate($got);
	# output failure?
	return $tb->ok($result, $why);
}
sub is_eq
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_eq($expected), $why);
}
sub is_ne
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_ne($expected), $why);
}
sub is_deeply
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_deeply($expected), $why);
}
sub is_like
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_like($expected), $why);
}
sub is_unlike
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_unlike($expected), $why);
}
sub _is_eq
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = "$got" eq "$expected"};
		return fail($@) if $@;
		return $result ? 1 : fail("\"$got\" ne \"$expected\"");
	};
}
sub _is_deeply
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result=eq_deeply ($got, $expected)}; # consider replacing this with something more 'native' later. 
		return fail($@) if $@;
		return $result ? 1 : fail(Dumper ($got). " ne ". Dumper($expected));
	};
}
sub _is_like
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = "$got" =~ m/$expected/};
		return fail($@) if $@;
		return $result ? 1 : fail("\"$got\" !~ /$expected/");
	};
}
sub _is_unlike
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = "$got" !~ m/$expected/};
		return fail($@) if $@;
		return $result ? 1 : fail("\"$got\" =~ /$expected/");
	};
}
sub fail
{
	# should there be a metasugar module for things like this?
	# More detailed interface to T::P::Fail? (More detailed T::P::F first!)
	my ($why) = @_;
	die $why;
	return Test::Proto::Fail->new($why);
}

#sub fail
#{
#	my ($self, $name, $why) = @_;
#	return Test::Proto::Fail->new();
#}

1;

