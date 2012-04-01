package Test::Proto::ArrayRef;
use 5.006;
use strict;
use warnings;
use base 'Test::Proto::Base';

sub is_empty
{
	my ($self, $why) = @_;
	$self->array_length(0, $why);
}
sub array_length
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_array_length($expected), $why);
}
sub range
{
	my ($self, $range, $expected, $why) = @_;
	$self->add_test(_range($range, $expected), $why);
}

sub grep
{
	my ($self, $code, $expected, $why) = @_;
	$self->add_test(_grep($code, $expected), $why);
}
sub map
{
	my ($self, $code, $expected, $why) = @_;
	$self->add_test(_map($code, $expected), $why);
}
sub _array_length
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = ( $expected == scalar (@$got) ? 1 : fail ("$expected != length(@$got)") )};
		return Test::Proto::Base::fail($@) if $@;
		return $result;
	};
}

sub _grep
{
	my ($code, $expected) = @_;
	return sub{
		my $got = shift;
		my $result = [];
		foreach (@$got)
		{
			push @$result, ($_) if &$code($_);
		}
		return $expected->validate($result);
	};
}
sub _map
{
	my ($code, $expected) = @_;
	return sub{
		my $got = shift;
		my $result = [];
		foreach (@$got)
		{
			push @$result, (&{$code}($_));
		}
		return $expected->validate($result);
	};
}
sub _range
{
	my ($range, $expected) = @_;
	return sub{
		my $got = shift;
		my $result = [];
		$range =~ s/-(\d+)/$#{$got} + 1 - $1/ge;
		my @range = eval ("($range)"); # surely there is a better way?
		foreach my $i (@range)
		{
			push (@$result, $_) foreach $got->[$i];
		}
		return $expected->validate($result);
	};
}

1;

