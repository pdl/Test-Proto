package Test::Proto::Repeatable;
use strict;
use warnings;
use Moo;

has 'contents',
	is      => 'rw',
	default => sub {[]};

has 'min',
	is      => 'rw',
	default => sub {};

has 'max',
	is      => 'rw',
	default => sub {};

sub BUILDARGS {
	my $class = shift;
	return {contents=>[@_]};
}

1;
