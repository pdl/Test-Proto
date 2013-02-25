package Test::Proto::Base2;
use 5.006;
use strict;
use warnings;
use Test::Proto::TestRunner;
use Moo;

our $defined_tests = {};
sub initialise
{
	return $_[0];
}

has natural_type => (
	is=>'rw',
	default=>sub{''},,
); # roughly corresponds to ref.
has natural_script => (
	is=>'rw',
	default=>sub{[]},
); # check if it is a bona fide X where X is the natural_type. Useful to avoid repeated ref checking.
has user_script => (
	is=>'rw',
	default=>sub{[]},
);

sub script {
	my $self = shift;
	return [
		@{ $self->natural_script },
		@{ $self->user_script },
	];
}
sub clone
{
	my $self = shift;
	my $new = bless {
		script=>$self->{'script'},
	}, ref $self;
	return $new;
}
sub add_test{
	my $self = shift;
	push @{ $self->user_script }, [@_];
	return $self;
}

sub run_test{
	my ($self, $test, $subject, $context) = @_;
	print ref ($context)."\n"; # Huh?
	print "- ".(defined $_ ? $_: '[undefined]')."\n" foreach @$test; # Huh?
	my $package = ref $self;
	$defined_tests->{$test->[0]}
		->($context, $subject, @$test);
	return $self;
}

sub defined_tests {
	# my ($package, $filename, $line) = caller;
	# return ${$package."::defined_tests"}; 
	return $defined_tests;

}

sub run_tests{
	my ($self, $subject, $context) = @_;
	foreach my $test (@{ $self->script }){
		run_test($self, $test, $subject, $context);
	}
}

sub define_test{
	my ($testName, $testSub) = @_;
	my ($package, $filename, $line) = caller;
	defined_tests->{$testName} = $testSub;
	# return value of this not specified 
}

sub is {
	my ($self, $expected, $reason) = @_;
	$self->add_test('is', $expected, $reason);
	return $self;
};

define_test is => sub {
	my ($self, $subject, $test, $expected, $reason) = @_; # self is the context, NOT the prototype
	if($subject eq $expected) {
		return $self->test_pass($subject, $test, $expected, $reason); 
	}
	else {
		return $self->test_fail($subject, $test, $expected, $reason);
	}
}; 

sub validate {
	my ($self, $subject, $context) = @_;
	if (!defined $context or !ref $context){ # if context is not a TestRunner
		$context = Test::Proto::TestRunner->new($context);
	}
	run_tests($self, $subject, $context);
	return $context;
}

