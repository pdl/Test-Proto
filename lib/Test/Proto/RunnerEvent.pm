package Test::Proto::RunnerEvent;
use 5.006;
use strict;
use warnings;
use overload '""' => \&_to_string,  '0+' => \&value, fallback => '0+';

sub new
{
	my $class = shift;
	my $testRunner = shift;
	my $data = shift;
	my $context = {};
	if (ref $testRunner and $testRunner->isa('Test::Proto::TestRunner')) {
		$context = $testRunner->current_state;	
	}
	bless {
		context=>$context,
		value=>$class::value,
		data=>$data,
	}, $class;
}

sub value {
	return 1;
}

sub _to_string {
	return 'Undefined event';
}

sub is_result {
	return 0;
}

sub is_info {
	return 0;
}

1;

=pod

=head1 NAME

Test::Proto::RunnerEvent - Base class for logged events

This method should not be called by anyone, it is just a base class. 

=head1 Methods

=head3 is_result

Returns 1 if it is a result.

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut


