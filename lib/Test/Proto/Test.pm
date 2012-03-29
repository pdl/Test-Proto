package Test::Proto::Test;
use 5.006;
use strict;
use warnings;
use Data::Dumper;
use Test::Proto::Fail;
use base 'Test::Builder::Module';
my $CLASS = __PACKAGE__;
my $dispatch = { 
	# This is ugly and should probably all go into the calling modules like T::P::Base, T::P::Object , etc. 
	# But... Prove concept first. Refactor later. 
	is_defined=>\&_is_defined,
	is_a=>\&_is_a,
	is_also=>\&_is_also,
	is_like=>\&_is_like,
	is_unlike=>\&_is_unlike,
	is_eq=>\&_is_eq,
	is_ne=>\&_is_ne,
	'keys'=>\&_keys,
	'grep'=>\&_grep,
	'array_length'=>\&_array_length,
};

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
	elsif (defined $dispatch->{$test})
	{
		push @{$self->{'tests'}},$dispatch->{$test}(@args);
		return $self;
	}
	return undef;
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
sub _array_length
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = ( $expected == scalar (@$got) ? 1 : fail ("$expected != length(@$got)") )};
		return fail($@) if $@;
		return $result;
	};
}

sub _keys
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = $expected->validate([keys %$got])};
		return fail($@) if $@;
		return $result;
	};
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
sub _grep
{
	my ($code, $expected) = @_;
	return sub{
		my $got = shift;
		my $result = [];
#		$code $got" !~ m/$expected/};
		foreach (@$got)
		{
			push @$result, ($_) if $code->$_;
		}
		return $expected->validate($result);
	};
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
sub fail
{
	# should there be a metasugar module for this when refactoring?
	my ($why) = @_;
	die $why;
	return Test::Proto::Fail->new($why);
}
1;

