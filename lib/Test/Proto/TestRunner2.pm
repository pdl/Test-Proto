package Test::Proto::TestRunner2;
use 5.006;
use strict;
use warnings;
use overload 'bool'=> sub{$_[0]->value};
use Moo;

sub zero { sub { 0;} };

=head1 NAME

Test::Proto::BaseTestRunner2 - Embodies a run through a test (Temporary name for replacement for Test::Proto::TestRunner2)

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
	default => zero;

=head3 value

Returns C<0> if the test run has failed or exception, C<1> otherwise.

=cut

has 'value' =>
	is => 'rw',
	default => zero;

=head3 is_exception

Returns C<1> if the test run has run into an exception, C<0> otherwise.

=cut

has 'is_exception'  =>
	is => 'rwp',
	default => zero;

=head3 is_info

Returns C<1> if the result is for information purposes, C<0> otherwise.

=cut

has 'is_info'  =>
	is => 'rwp',
	default => zero; 

=head3 is_skipped

Returns C<1> if the test case was skipped, C<0> otherwise.

=cut

has 'is_skipped'  =>
	is => 'rwp',
	default => zero;

=head3 children

Returns an arrayref 

=cut

has 'children'  =>
	is => 'rw',
	default => sub{[]};

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
	my ($self, $value) = @_;
	if ($self->is_complete){
		warn "Tried to complete something that was already complete.";
		return $self;
	}
	$self->value($value);
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
	my $self = shift;
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
	my $self = shift;
	$self->complete(0);
	return $self;
}

=head3 diag

	$self->diag;

Declares that the test run is complete, and declares that it is not a result but a diagnostic message, irrespective of what the results of the subtests were. 

=cut

sub diag{
	my $self = shift;
	$self->_set_is_info(1);
	$self->complete(1);
	return $self;
}

=head3 skip

	$self->skip;

Declares that the test run is complete, but that it was skipped.

=cut

sub skip{
	my $self = shift;
	$self->_set_is_skipped(1);
	$self->complete(1);
	return $self;
}

=head3 exception

	$self->exception;

Declares that the test run is complete, and declares the result to be an exception, irrespective of what the results of the subtests were. 

=cut

sub exception{
	my $self = shift;
	$self->_set_is_exception(1);
	$self->complete(0);
	return $self;
}

sub inform_formatter{
	my $self = shift;
	my $formatter = $self->formatter;
	if (defined $formatter){ 
		$formatter->event(@_);
	}
}

1;

