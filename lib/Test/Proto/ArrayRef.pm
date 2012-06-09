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

sub first_match
{
	my ($self, $code, $expected, $why) = @_;
	$self->add_test(_first_match($self->upgrade($code), $self->upgrade($expected)), $why);
}
sub last_match
{
	my ($self, $code, $expected, $why) = @_;
	$self->add_test(_last_match($self->upgrade($code), $self->upgrade($expected)), $why);
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
		return Test::Proto::Base::exception($@) if $@;
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
sub _first_match
{
	my ($code, $expected) = @_;
	return sub{
		my $got = shift;
		foreach my $g (@$got)
		{
			my $result = $code->validate($g);
			return $expected->validate($g) if $result;
		}
		return Test::Proto::fail('No matches');
	};
}
sub _last_match
{
	my ($code, $expected) = @_;
	return sub{
		my $got = shift;
		foreach my $g (reverse @$got)
		{
			my $result = $code->validate($g);
			return $expected->validate($g) if $result;
		}
		return Test::Proto::fail('No matches');
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

See L<Test::Proto::Base> for documentation on common methods. All methods which add a test return the prototype and the last argument is optional and contains the reason for running the test (for the output). The thing which is being tested is unaffected except where noted.

=head3 array_length

	$prototype->array_length(3, 'is 3 elements long')->ok([1,2,3]);

This method adds a test equivalent to Perl's builtin C<scalar>. The first argument is upgraded and validated with the result of the C<scalar> operation. 

=head3 is_empty

	$prototype->is_empty->ok([]);

This method adds a test which passes if the arrayref is empty.

=head3 map

	$prototype->map(sub{ord($_[0])}, [97,98,99])->ok(['a','b','c']);

This method adds a test in which each arrayref element is passed into the coderef provided and the output added to a new arrayref which is tested against the prototype. It functions like Perl's C<map>.

=head3 grep

	$prototype->grep(sub{ord($_[0])>97}, [98,99])->ok(['a','b','c']);

This method adds a test in which each arrayref element is passed into the test provided (if it is a coderef, it will be upgraded) and, if successful, the arrayref element will be added to a new arrayref which is tested against the prototype. It functions like Perl's C<grep>.

=head3 all

	$prototype->all(sub{ord($_[0])>96})->ok(['a','b','c']);

This method adds a test in which each arrayref element is passed into the test provided (if it is a coderef, it will be upgraded). The test will pass if all elements pass the test.

=head3 first_match

	$prototype->first_match(sub{ord($_[0])>97},'b')->ok(['a','b','c']);

This method adds a test in which each arrayref element is passed into the test provided (if it is a coderef, it will be upgraded). The first element which passes this test will then be passed into the second test.

=head3 last_match

	$prototype->last_match(sub{ord($_[0])>97},'c')->ok(['a','b','c']);

This method adds a test in which each arrayref element is passed into the test provided (if it is a coderef, it will be upgraded). The last element which passes this test will then be passed into the second test.

=head3 range

	$prototype->range('1..3', [9,8,7])->ok([10..1]);

This method selects a subrange and passes that to a new test. 

=head3 reduce

	$prototype->reduce(sub {$_[0] .= $_[1] }, 'abc')->ok(['a','b','c']);

Reduce works by passing elements to a function sequentially and always in pairs; the result of the last function plus the next item in the array, like L<List::Util>'s C<reduce>.

=head3 contains_only

	$prototype->contains_only([pSeries(pSeries(1,2)->repeat(1,5),3)])->ok([1,2,1,2,3]);

This method allows DTD-like validation of an arrayref. See also L<Test::Proto::Series>.

=head3 begins_with

	$prototype->begins_with([pSeries(1,2)])->ok([1,2,1,2,3]);

As C<contains_only>, but only checks the beginning of an array.

=head3 sort

	$prototype->sort(sub{lc $_[0] cmp lc $_[1]}, ['a','B','c'])->ok(['B','a','c']);

This method sorts the arrayref using the first argument as the comparison code and passes the result to a new test.

=head3 schwartz

	$prototype->sort(sub{$_[0] cmp $_[1]}, sub {lc $_[0]}, ['a','B','c'])->ok(['B','a','c']);

This method sorts the arrayref using a schwarzian transform using the first argument as the comparison code and the second as the normaliser, and passes the result to a new test.

=head3 uniq

	$prototype->uniq(sub{lc $_[0] cmp lc $_[1]}, ['B','c'])->ok(['B','b','c']);

This method reduces the arrayref to only those elements which are not repeated, and passes the result to a new test.

The first argument is a comparison operator which should return 0 if both arguments are identical for this purpose. For any matching pairs found, the first element is always kept, and the order is unchanged.

=head3 min

	$prototype->min(sub{lc $_[0] cmp lc $_[1]}, 'a')->ok(['B','a','c']);

This method picks the element with the lowest value (according to the comparison operator provided).

For any matching pairs found, the first element is used.

=head3 max

	$prototype->max(sub{lc $_[0] cmp lc $_[1]}, 'a')->ok(['B','a','c']);

This method picks the element with the highest value (according to the comparison operator provided).

For any matching pairs found, the first element is used.

=head3 enumerate

	$prototype->enumerate( [[1,'a'],[2,'B'],[3,'c']])->ok(['a','B','c']);

This method turns each element of the arrayref into an arrayref containing the index and the value and passes the result to a new test.

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut

