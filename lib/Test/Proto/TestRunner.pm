package Test::Proto::TestRunner;
use 5.006;
use strict;
use warnings;
use overload 'bool'=> sub{$_[0]->value};
use Moo;
use Object::ID;

sub _zero { sub { 0;} };

=head1 NAME

Test::Proto::TestRunner - Embodies a run through a test

=head1 SYNOPSIS

		my $runner = Test::Proto::TestRunner->new(test_case=>$testCase);
		my $subRunner $runner->subtest;
		$subRunner->pass;
		$runner->done();

Note that it is a Moo class.

Unless otherwise specified, the return value is itself.

=cut

sub BUILD {
	my $self = shift;
	$self->inform_formatter('new');
}

=head2 ATTRIBUTES

=cut

=head3 subject

Returns the test subject

=cut

has 'subject' =>
	is => 'rw';

=head3 test_case

Returns the test case or the prototype

=cut

has 'test_case' =>
	is => 'rw';

=head3 parent

Returns the parent of the test.

=cut

has 'parent' =>
	is => 'rwp';

=head3 is_complete

Returns C<1> if the test run has finished, C<0> otherwise.

=cut

has 'is_complete' =>
	is => 'rwp',
	default => _zero;

=head3 value

Returns C<0> if the test run has failed or exception, C<1> otherwise.

=cut

has 'value' =>
	is => 'rw',
	default => _zero;

=head3 is_exception

Returns C<1> if the test run has run into an exception, C<0> otherwise.

=cut

has 'is_exception'  =>
	is => 'rwp',
	default => _zero;

=head3 is_info

Returns C<1> if the result is for information purposes, C<0> otherwise.

=cut

has 'is_info'  =>
	is => 'rwp',
	default => _zero; 

=head3 is_skipped

Returns C<1> if the test case was skipped, C<0> otherwise.

=cut

has 'is_skipped'  =>
	is => 'rwp',
	default => _zero;

=head3 children

Returns an arrayref 

=cut

has 'children'  =>
	is => 'rw',
	default => sub{[]};

=head3 status_message

This is a string which indicates the reason for skipping, exception info, etc.

=cut

has 'status_message'  =>
	is => 'rw',
	default => sub{''};


=head3 formatter

Returns the formatter used.

=cut

has 'formatter' =>
	is => 'rw'; # Test::Proto::Common::Formatter->new;


=head3 complete

	$self->complete(0);

Declares the test run is complete. It is intended that this is only called by the other methods C<done>, C<pass>, C<fail>, C<exception>, C<diag>, C<skip>.

=cut

sub complete {
	my ($self, $value, $message) = @_;
	if ($self->is_complete){
		warn "Tried to complete something that was already complete (a ".$self->status."). (Tried with value=> " . ($value // '[undefined]') . ", message=>". ($message // '[undefined]') .")";
		return $self;
	}
	$self->value($value);
	$self->status_message($message);
	$self->_set_is_complete(1);
	$self->inform_formatter('done');
	return $self;
}

=head3 subtest

=cut
sub subtest{
	my $self = shift;
	my $event = __PACKAGE__->new({
		formatter=> $self->formatter,
		subject=> $self->subject,
		test_case=> $self->test_case,
		parent=>$self,
		@_
	});
	$self->add_event($event);
	return $event;
}

=head3 add_event

Adds an event to the runner. 

=cut

sub add_event {
	my ($self, $event) = @_;
	if ($self->is_complete){
		warn "Tried to add an event to a TestRunner which is already complete";
	}
	else{
		unless (defined $event){
			die('tried to add an undefined event');
		}
		push @{$self->children}, $event;
	}
	return $self;
}

=head3 done

	$self->done;

Declares that the test run is complete, and determines if the result is a pass or a fail - if there are any failures, then the result is deemed to be a failure. 

=cut
 
sub done {
	my ($self, $message) = @_;
	return $self->exception if scalar grep { $_->is_exception } @{ $self->children() };
	$self->complete($self->_count_fails?0:1);
	return $self;
}

sub _count_fails {
	my $self = shift;
	return scalar grep { !$_->value } @{ $self->children() };
}
# add_(pass|fail|diag|exception) to spec further

=head3 pass

	$self->pass;

Declares that the test run is complete, and declares the result to be a pass, irrespective of what the results of the subtests were. 

=cut

sub pass{
	my $self = shift;
	$self->complete(1);
	return $self;
}

=head3 fail

	$self->fail;

Declares that the test run is complete, and declares the result to be a failure, irrespective of what the results of the subtests were. 

=cut

sub fail{
	my ($self, $message) = @_;
	$self->complete(0, $message);
	return $self;
}

=head3 diag

	$self->diag;

Declares that the test run is complete, and declares that it is not a result but a diagnostic message, irrespective of what the results of the subtests were. 

=cut

sub diag{
	my ($self, $message) = @_;
	$self->_set_is_info(1);
	$self->complete(1);
	return $self;
}

=head3 skip

	$self->skip;

Declares that the test run is complete, but that it was skipped.

=cut

sub skip{
	my ($self, $message) = @_;
	$self->_set_is_skipped(1);
	$self->complete(1, $message);
	return $self;
}

=head3 exception

	$self->exception;

Declares that the test run is complete, and declares the result to be an exception, irrespective of what the results of the subtests were. 

=cut

sub exception{
	my ($self, $message) = @_;
	$self->_set_is_exception(1);
	$self->complete(0, $message);
	return $self;
}

=head3 inform_formatter

	$self->inform_formatter;

Used internally to send events to the formatter. The two events currently permitted are 'new' and 'done'. 

=cut


sub inform_formatter{
	my ($self) = @_;
	my $formatter = $self->formatter;
	if (defined $formatter){ 
		$formatter->event(@_);
	}
}

=head3 status

	$self->status;

Useful to summarise the status of the TestRunner. Possible values are: FAIL, PASS, INFO, SKIPPED, EXCEPTION, INCOMPLETE. 

=cut


sub status {
	my ($self) = @_;
	return 'INCOMPLETE' unless $self->is_complete;
	return 'EXCEPTION' if $self->is_exception;
	return 'SKIPPED' if $self->is_skipped;
	return 'INFO' if $self->is_info;
	return 'PASS' if $self->value;
	return 'FAIL';
}

=head3 object_id, object_uuid

Test::Proto::TestRunner implements L<Object::ID>. This is used by formatters.

=cut

1;

