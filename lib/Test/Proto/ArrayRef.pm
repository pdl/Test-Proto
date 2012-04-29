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
	$self->add_test(_grep($self->upgrade($code), $self->upgrade($expected)), $why);
}

sub all
{
	my ($self, $code, $why) = @_;
	$self->add_test(_all($self->upgrade($code)), $why);
}

sub map
{
	my ($self, $code, $expected, $why) = @_;
	$self->add_test(_map($code, $self->upgrade($expected)), $why);
}
sub sort
{
	my ($self, $cmp, $expected, $why) = @_;
	$self->add_test(_sort($cmp, $self->upgrade($expected)), $why);
}
sub schwartz
{
	my ($self, $cmp, $norm, $expected, $why) = @_;
	$self->add_test(_schwartz($cmp, $norm, $self->upgrade($expected)), $why);
}
sub uniq
{
	my ($self, $cmp, $expected, $why) = @_;
	$self->add_test(_uniq($cmp, $self->upgrade($expected)), $why);
}
sub max
{
	my ($self, $cmp, $expected, $why) = @_;
	$self->add_test(_max($cmp, $self->upgrade($expected)), $why);
}
sub min
{
	my ($self, $cmp, $expected, $why) = @_;
	$self->add_test(_min($cmp, $self->upgrade($expected)), $why);
}

sub enumerate
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_enumerate($self->upgrade($expected)), $why);
}
sub reduce
{
	my ($self, $code, $expected, $why) = @_;
	$self->add_test(_reduce($code, $self->upgrade($expected)), $why);
}
sub contains_only
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_pull([map {$self->upgrade($_)} @$expected], Test::Proto::ArrayRef->new->is_empty), $why);
}
sub begins_with
{
	my ($self, $expected, $allowed_remainder, $why) = @_;
	$allowed_remainder = Test::Proto::ArrayRef->new unless defined $allowed_remainder;
	$self->add_test(_pull([map {$self->upgrade($_)} @$expected], $self->upgrade($allowed_remainder)), $why);
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
sub _pull
{
	my ($expected, $allowed_remainder) = @_;
	return sub{
		my $got = shift;
		my @got = @$got;
		# TODO: rewrite to enable backtracking
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
		return $allowed_remainder->validate([@got]);
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
			push @$result, ($_) if $code->validate($_);
		}
		return $expected->validate($result);
	};
}
sub _all
{
	my ($code) = @_;
	return sub{
		my $got = shift;
		foreach (@$got)
		{
			my $result = $code->validate($_);
			return $result unless $result;
		}
		return 1;
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
sub _sort
{
	my ($cmp, $expected) = @_;
	return sub{
		my $got = shift;
		my $result = [sort {&{$cmp}($a,$b)} @$got];
		return $expected->validate($result);
	};
}
sub _schwartz
{
	my ($cmp, $norm, $expected) = @_;
	return sub{
		my $got = shift;
		my $result = [
			map {$_->[0]}
			sort {&{$cmp}($a->[1],$b->[1])}
			map {[$_, &{$norm}($_)]}
		@$got ];
		return $expected->validate($result);
	};
}
sub _enumerate
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		my $i = 0;
		foreach my $g (@$got)
		{
			push @$result, [$i, $g];
			$i++;
		}
		return $expected->validate($result);
	};
}
sub _uniq
{
	my ($cmp, $expected) = @_;
	return sub{
		my $got = shift;
		my $result = [];
		foreach my $g (@$got)
		{
			push @$result, $g if (!grep { !&{ $cmp }( $_, $g) } @$result);
		}
		return $expected->validate($result);
	};
}

sub _max
{
	my ($cmp, $expected) = @_;
	return sub{
		my $got = shift;
		my $result = $got->[1] if @$got;
		foreach my $g (@$got)
		{
			$result = $g if &{ $cmp }( $result, $g) == -1;
		}
		return $expected->validate($result);
	};
}
sub _min
{
	my ($cmp, $expected) = @_;
	return sub{
		my $got = shift;
		my $result = $got->[1] if @$got;
		foreach my $g (@$got)
		{
			$result = $g if &{ $cmp }( $result, $g) == 1;
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

=head3 all

=head3 range

=head3 is_empty

=head3 reduce

=head3 contains_only

=head3 begins_with

=head3 sort

=head3 schwartz

=head3 uniq

=head3 min

=head3 max

=head3 enumerate

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

