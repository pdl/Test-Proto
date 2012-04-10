package Test::Proto::Fail;
use 5.006;
use strict;
use warnings;
use overload '""' => \&_to_string, '0+' => sub{0}, fallback => '0+';

sub new
{
	my $class = shift;
	bless {
	}, $class;
}

sub _to_string
{
	return "Test Prototype failure"; # TODO: make this more verbose
}

1;

