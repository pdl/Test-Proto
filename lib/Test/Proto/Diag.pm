package Test::Proto::Diag;
use 5.006;
use strict;
use warnings;
use overload '""' => \&_to_string,  '0+' => sub{1}, fallback => '0+';

sub new
{
	my $class = shift;
	my $warning = shift;
	my $because = shift;
	return bless {
		simple_warning => $warning,
		trigger=>$because,
	}, $class;
}

sub _to_string
{
	my $self = shift;
	my $return = "\nTest Prototype Diagnostics:";
	my @why = @{$self->_why};
	$return .= "\n\t" . shift @why;
	foreach my $reason (@why)
	{
		$return .= "\nBecause:\n\t$reason";
	}
	return $return;
}


1;

=pod

=head1 NAME

Test::Proto::Diag - A Diagnostic event

=head1 SYNOPSIS

=head1 METHODS

=head3 new

	my $event = Test::Proto::Diag->new('Only 1 turnip');
	my $event = Test::Proto::Diag->new($testRunner, 'Only 1 turnip');

Creats a new diagnostic event. The string you give is the associated information. If the first argument is a Test::Proto::TestRunner, it will be considered the context of the event.

=head3 because

	$event->because($turnip_result);

Set the triggering failure and return the failure. If the triggering failure is boolean true, then return that instead.

=head3 Other methods

Currently all other public methods are via overloading:

All numeric operators treat Test::Proto::Diag objects as 1. 

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut


