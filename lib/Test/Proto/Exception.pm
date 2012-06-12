package Test::Proto::Exception;
use 5.006;
use strict;
use warnings;
use base qw(Test::Proto::Fail);
use overload '""' => \&_to_string, '0+' => sub{undef}, fallback => '0+';


sub _to_string
{
	my $self = shift;
	my $return = "\nTest Prototype Exception:";
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

Test::Proto::Exception - indicates the test has broken, and, if possible, why

=head1 SYNOPSIS

A bit like L<Test::Proto::Fail>, but with exceptions that return undef, not zero.

=head1 METHODS

=head3 new

	Test::Proto::Exception->new('Cannot access garden');

Creats a new exception. The warning you give is the reason for the exception. Optionally, add the failure which caused this failure as a third argument (if this is boolean true, then it will return true instead).

=head3 because

	$exception->because($original_sin);

Set the triggering exception/failure and return the exception. If the triggering exception/failure is boolean true, then return that instead.

=head3 Other methods

Currently all other public methods are via overloading:

All numeric operators treat Test::Proto::Exception objects as undef. 

When stringified, however, Test::Proto::Exception objects return the explanation.

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut


