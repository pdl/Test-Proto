package Test::Proto::Series;
use strict;
use warnings;
use Moo;

has 'contents',
	is      => 'rw',
	default => sub {[]};

sub BUILDARGS {
	my $class = shift;
	return {contents=>[@_]};
}

1;
