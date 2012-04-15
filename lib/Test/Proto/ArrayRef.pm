package Test::Proto::ArrayRef;
use 5.006;
use strict;
use warnings;
use base 'Test::Proto::Base';

sub initialise
{
	my ($self) = @_;
	$self->is_defined;
	$self->is_a('ARRAY');
}

sub is_empty
{
	my ($self, $why) = @_;
	$self->array_length(0, $why);
}
sub array_length
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_array_length($self->upgrade($expected)), $why);
}
sub range
{
	my ($self, $range, $expected, $why) = @_;
	$self->add_test(_range($range, $self->upgrade($expected)), $why);
}

sub grep
{
	my ($self, $code, $expected, $why) = @_;
	$self->add_test(_grep($code, $self->upgrade($expected)), $why);
}
sub map
{
	my ($self, $code, $expected, $why) = @_;
	$self->add_test(_map($code, $self->upgrade($expected)), $why);
}
sub reduce
{
	my ($self, $code, $expected, $why) = @_;
	$self->add_test(_reduce($code, $self->upgrade($expected)), $why);
}
sub contains_only
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_contains_only([map {$self->upgrade($_)} @$expected]), $why);
}
sub _array_length
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = ( $expected->validate(@$got ? length(@$got): 0) ? 1 : Test::Proto::Base::fail ("$expected != length(@$got)") )};
		return Test::Proto::Base::fail($@) if $@;
		return $result;
	};
}
sub _contains_only
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my @got = @$got;
		# TODO: I think it requires parser-like logic to include series
		foreach my $expect (@$expected)
		{
			
			if ($expect->can('validate_many'))
			{
				my $remainder = $expect->validate_many([@got]); # 
				return $remainder unless $remainder;
				@got = @$remainder;
			}
			else
			{
				my $this = shift @got;
				my $result = $expect->validate($this);
				return $result unless $result;
			}
		}
		return 1;
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
sub _reduce
{
	my ($code, $expected) = @_;
	return sub{
		my $got = shift;
		my $result = [];
		my $current = $got->[0];
		return fail ('reduce requires length of > 1') if $#$got == 0; 
		for (my $i = 1; $i<=$#$got; $i++)
		{
			$current = &{$code}($current,$got->[$i]);
		}
		return $expected->validate($current);
	};
}
sub _range
{
	my ($range, $expected) = @_;
	return sub{
		my $got = shift;
		my $result = [];
		$range =~ s/-(\d+)/$#{$got} + 1 - $1/ge; # really also need to do some validating of range.	
		my @range = eval ("($range)"); # surely there is a better way?
		foreach my $i (@range)
		{
			push (@$result, $_) foreach $got->[$i];
		}
		return $expected->validate($result);
	};
}
return 1; # module loaded ok

=pod
=head1 NAME

Test::Proto::ArrayRef - Test Prototype for Array References. 

=head1 SYNOPSIS

	Test::Proto::ArrayRef->new->ok([1,2,3]); # ok
	Test::Proto::ArrayRef->new->ok([]); # also ok
	Test::Proto::ArrayRef->new->is_deeply([1,2,3])->ok([1,2,3]); # ok
	Test::Proto::ArrayRef->new->is_empty->ok([]); # also ok
	Test::Proto::ArrayRef->new->ok(undef); # not ok
	Test::Proto::ArrayRef->new->ok(1,2,3); # not ok

This is a test prototype which requires that the value it is given is defined and is an arrayref. It provides methods for interacting with arrayrefs. (To test lists/arrays, make them arrayrefs and test them with this module)

=head1 METHODS

See L<Test::Proto::Base> for documentation on common methods.

=head3 array_length

=head3 is_empty

=head3 map

=head3 grep

=head3 range

=head3 range

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

