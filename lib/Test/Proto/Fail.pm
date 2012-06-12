package Test::Proto::Fail;
use 5.006;
use strict;
use warnings;
use overload '""' => \&_to_string,  '0+' => sub{0}, fallback => '0+';

sub new
{
	my $class = shift;
	my $warning = shift;
	my $because = shift;
	return $warning if ref $warning and $warning->isa('Test::Proto::Fail');
	return $because if $because;
	bless {
		simple_warning => $warning,
		trigger=>$because,
	}, $class;
}

sub _to_string
{
	my $self = shift;
	my $return = "\nTest Prototype Failure:";
	my @why = @{$self->_why};
	$return .= "\n\t" . shift @why;
	foreach my $reason (@why)
	{
		$return .= "\nBecause:\n\t$reason";
	}
	return $return;
}
sub _why
{
	my $self = shift;
	my $return = [defined $self->{'simple_warning'} ? $self->{'simple_warning'} : '']; 
	if (defined $self->{'trigger'})
	{
		$return = [@$return,@{$self->{'trigger'}->_why}]
	}
	return $return;
}
sub because
{
	my $self = shift;
	my $trigger = shift;
	$self->{'trigger'} = $trigger;
	return $trigger if $trigger;
	return $self;
}

1;

=pod

=head1 NAME

Test::Proto::Fail - indicates the test has failed, and why

=head1 SYNOPSIS

	$turnip_result = @turnips ? 1 : Test::Proto::Fail->new('Out of turnips');
	$broth_result = Test::Proto::Fail->new('No broth', $turnip_result)
	# i.e. $broth_result = $turnip_result ? 1 : Test::Proto::Fail->new('No broth')->because($turnip_result);
	print $broth_result;

Prints either 1 (if you have turnips) or an object which stringifies to:
	
	Test Prototype failure:
		No broth
	Because:
		Out of turnips

NB: Do not confuse with C<Test::More::fail> - this is more like C<carp>-like functionality to the C<$why> element of tests.

=head1 METHODS

=head3 new

	Test::Proto::Fail->new('Out of turnips')

Creats a new failure. The warning you give is the reason for the failure. Optionally, add the failure which caused this failure as a third argument (if this is boolean true, then it will return true instead).

=head3 because

	$fail->because($turnip_result);

Set the triggering failure and return the failure. If the triggering failure is boolean true, then return that instead.

=head3 Other methods

Currently all other public methods are via overloading:

All numeric operators treat Test::Proto::Fail objects as 0. 

When stringified, however, Test::Proto::Fail objects return the explanation for the failure.

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut


