package Test::Proto::Alternation;
use strict;
use warnings;
use Moo;

has 'alternatives',
	is      => 'rw',
	default => sub {[]};

sub BUILDARGS {
	my $class = shift;
	return {alternatives=>[@_]};
}

1;
