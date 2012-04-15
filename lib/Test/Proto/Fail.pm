package Test::Proto::Fail;
use 5.006;
use strict;
use warnings;
use overload '""' => \&_to_string, '0+' => sub{0}, fallback => '0+';

sub new
{
	my $class = shift;
	my $warning = shift;
	
	bless {
		simple_warning => $warning,
	}, $class;
}

sub _to_string
{
	my $self = shift;
	return "Test Prototype Failure:".(defined $self->{'simple_warning'} ? "\n".$self->{'simple_warning'} : ''); # TODO: make this more verbose
}

1;

