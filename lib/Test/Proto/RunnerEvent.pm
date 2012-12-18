package Test::Proto::RunnerEvent;
use 5.006;
use strict;
use warnings;
use overload '""' => \&_to_string,  '0+' => \&value, fallback => '0+';

#	
#	CLASS::new (RUNNER, MESSAGE, DATA)
#	CLASS::new (MESSAGE, DATA)
#	CLASS::new (MESSAGE)
#	CLASS::new (DATA)
#
sub new
{
	my ($class, $testRunner,  $message, $data) = @_;
	my $context = {};
	if (ref $testRunner and $testRunner->isa('Test::Proto::TestRunner')) {
		$context = $testRunner->current_state;	
	}
	else {
		$data = $message;
		$message = $testRunner;
	}
	if (!defined $data and ((ref $message) eq (ref {}))) {
		$data = $message;
		$message = '';
	}
	bless {
		context=>$context,
		value=>$class::value,
		message=>$message,
		data=>$data,
	}, $class;
}

# this code is poor and needs replacing.
sub _why
{
	my $self = shift;
	my $return = [defined $self->{'message'} ? $self->{'message'} : '']; 
	if (defined $self->{'data'}{'trigger'})
	{
		$return = [@$return,@{$self->{'data'}{'trigger'}->_why}]
	}
	return $return;
}
sub because
{
	my $self = shift;
	my $trigger = shift;
	$self->{'data'}{'trigger'} = $trigger;
	return $trigger if $trigger;
	return $self;
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

=head3 is_info

Returns 1 if it is an information event.

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut


