package Test::Proto::Repeatable;
use strict;
use warnings;
use Moo;

has 'contents',
	is      => 'rw',
	default => sub {Test::Proto::Series->new(@_)};

has 'min',
	is      => 'rw',
	default => sub {0};

has 'max',
	is      => 'rw',
	default => sub {undef};

around 'min', 'max' => sub {
	#~ This means treat min and max as chainable accessors
	my $orig = shift;
	my $self = shift;
	if (exists $_[0]){
		#~ when setting, return self
		$orig->($self, @_);
		return $self;
	}
	else {
		#~ when getting, return value
		return $orig->($self, @_);
	}

};

sub BUILDARGS {
	my $class = shift;
	return {contents=>Test::Proto::Series->new(@_)};
}

=head1 NAME

Test::Proto::Repeatable - represent a repeatable element or series in array validation

=head1 SYNOPSIS

	pArray->contains_only(pRepeatable('a', 'b')); 
	# will validate ['a', 'b'] and  ['a', 'b', 'a', 'b'] as true

Used in array validation to represent a sequence qhich must be present in its entirety. Can contain, or be contained by, a L<Test::Proto::Series> or a L<Test::Proto::Alternation>.

=head1 METHODS

=head3 new

Each argument is another element in the series. NB: A series is automatically created to hold all the contents.

=head3 contents

	die unless exists $alternation->contents->[0];

A getter/setter method for the contents of the series.

=head3 min

Sets and/or returns the minimum number of occurrences required.

=head3 max

Sets and/or returns the maximum number of occurrences permitted.

=cut

1;
