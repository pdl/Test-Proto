package Test::Proto::TestRunner;
use 5.006;
use strict;
use warnings;
use Test::Proto::Fail;
use Test::Proto::Pass;
use Test::Proto::Exception;
use Test::Proto::Diag;
use Data::Dumper; # not used in canonical but keep for the moment for development
$Data::Dumper::Indent = 0;
$Data::Dumper::Terse = 1;
$Data::Dumper::Sortkeys = 1;
use overload 'bool'=> \&_boolean_result;

sub new
{
	my $class = shift;
	my $self = bless {
		# formatter
		# format push
		location=>[],
		log=>[],
	}, $class;
	return $self;
}
sub test_location {
	my $self = shift;
	return $self->{'location'};
}

sub results {
	my $self = shift;
	return [grep { (!ref $_) or ($_->isa('Test::Proto::Info')) } $self->{'results'}];
}
sub _boolean_result {
	my $self = shift;
	foreach (@{$self->results}) {
		return 0 unless $_;
	}
	return 1;
}
sub test_result {
	my ($self, $result) = @_;
	push (@{$self->{log}}, $result);
	return $result;
}

sub test_pass {
	my ($self) = @_;
	return $self->test_result(Test::Proto::Pass->new(@_));
}

sub test_note {
	my ($self) = @_;
	return $self->test_result(Test::Proto::Diag->new(@_));
}

sub test_diag {
	my ($self) = @_;
	return $self->test_result(Test::Proto::Diag->new(@_));
}

sub test_fail {
	my ($self) = @_;
	return $self->test_result(Test::Proto::Fail->new(@_));
}

sub test_exception {
	my ($self) = @_;
	return $self->test_result(Test::Proto::Exception->new(@_));
}
sub current_state {
	my $self = shift;
	return {
		location=>$self->test_location
	}
}


return 1; # end of Test::Proto::TestRunner

=head1 NAME

Test::Proto::TestRunner - Run through a prototype, record the results, and pass them to a formatter. 

=head1 SYNOPSIS

	my $runner = Test::Runner->new;
	my $child = $runner->new_subtest('/id');
	
	$runner->test_fail();

	$runner->test_pass();
	$runner->test_diag();
	$runner->test_note();

	$runner->test_location();

	$runner->report();
	

The TestRunner is designed to be passed into tests in prototypes. Normally, the author of a test script should not even be aware of the TestRunner, unless they want to set its formatter. A Test Prototype author might interact with the TestRunner to pass results or diagnostics into it but does not create it. 

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut


