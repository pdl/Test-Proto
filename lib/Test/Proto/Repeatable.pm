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

sub BUILDARGS {
	my $class = shift;
	return {contents=>Test::Proto::Series->new(@_)};
}

1;
