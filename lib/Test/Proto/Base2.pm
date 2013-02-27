package Test::Proto::Base2;
use 5.006;
use strict;
use warnings;
use Test::Proto::TestRunner;
use Moo;
use Sub::Name;

=pod

=head1 NAME

Test::Proto::Base2 - Base Class for Test Prototypes (Temporary name for replacement for Test::Proto::Base)

=head1 SYNOPSIS

	my $p = Test::Proto::Base2->new->is_eq(-5);
	$p->ok ($temperature) # will fail unless $temperature is -5
	$p->ok ($score) # you can use the same test multple times
	ok($p->validate($score)) # If you like your "ok"s first

This is a base class for test prototypes. 

Note that it is a Moo class.

=cut

sub initialise
{
	return $_[0];
}

=head3 natural_type

This roughly corresponds to C<ref>. Useful for indicating what sort of element you're expecting.

This is documented for information purposes only and is not intended to be used except in the maintainance of C<Test::Proto> itself.

=cut

has natural_type => (
	is=>'rw',
	default=>sub{''},,
); # roughly corresponds to ref.

=head3 natural_script

These are tests common to the whole prototype which need not be repeated if two similar scripts are joined together. Normally, this should only be modified by the prototype class.

This is documented for information purposes only and is not intended to be used except in the maintainance of C<Test::Proto> itself.

=cut

has natural_script => (
	is=>'rw',
	default=>sub{[]},
); 
=head3 user_script

These are the tests which the user (specifically, the test script author) has added by a method call. Normally, these should empty in a class but may be present in an instance of an object.

This is documented for information purposes only and is not intended to be used except in the maintainance of C<Test::Proto> itself.

=cut


has user_script => (
	is=>'rw',
	default=>sub{[]},
);

=head3 script

This method returns an arrayref containing the contents of the C<natural_script> and the C<user_script>, i.e. all the tests in the object that are due to be run when C<< ->ok() >> is called.

=cut

sub script {
	my $self = shift;
	return [
		@{ $self->natural_script },
		@{ $self->user_script },
	];
}

=head3 script

This method returns a copy of the current object. The new object can have tests added without affecting the existing test.

=cut

sub clone
{
	my $self = shift;
	my $new = bless {
		script=>$self->{'script'}, # that won't work!
	}, ref $self;
	return $new;
}

=head3 add_test

This method adds a test to the current object, specifically to the C<user_script>, and returns the prototype object.

This is documented for information purposes only and is not intended to be used except in the maintainance of C<Test::Proto> itself.

=cut

sub add_test{
	my $self = shift;
	push @{ $self->user_script }, [@_];
	return $self;
}

=head3 run_test

	$self->run_test($test, $subject, $context);

This method runs a particular test in the object's script, and returns the prototype object. It is called by the C<< ->run_tests >> method.

This is documented for information purposes only and is not intended to be used except in the maintainance of C<Test::Proto> itself.

=cut

sub run_test{
	my ($self, $test, $subject, $context) = @_;
	print ref ($context)."\n"; # Huh?
	print "- ".(defined $_ ? $_: '[undefined]')."\n" foreach @$test; # Huh?
	my $package = ref $self;
	{
		no strict 'refs';
		my $testMethodName = $package.'::TEST_'.$test->[0];
		eval { &{$testMethodName} ($context, $subject, @$test); };
		$context->text_exception($@) if $@;
	}
	return $self;
}


=head3 run_tests

	$self->run_tests($subject, $context);

This method runs all the tests in the prototype object's script (simply calling the C<< ->run_tests >> method on each), and returns the prototype object. 

This is documented for information purposes only and is not intended to be used except in the maintainance of C<Test::Proto> itself.

=cut

sub run_tests{
	my ($self, $subject, $context) = @_;
	foreach my $test (@{ $self->script }){
		run_test($self, $test, $subject, $context);
	}
	return $self;
}

=head3 define_test

	define_test 'is_uppercase', sub { $_[1] =~ !/[a-z]/ }

This method runs all the tests in the prototype object's script (simply calling the C<< ->run_tests >> method on each), and returns the prototype object. 

This is documented for information purposes only and is not intended to be used except in the maintainance of C<Test::Proto> itself.

=cut


sub define_test{
	my ($testName, $testSub) = @_;
	my ($package, $filename, $line) = caller;
	#defined_tests->{$testName} = $testSub;
	{
		no strict 'refs';
		my $fullName = $package.'::TEST_'.$testName;
		*$fullName = subname ('TEST_'.$testName , $testSub); # Consider Sub::Install here, per Khisanth on irc.freenode.net#perl
	}
	# return value of this not specified 
}

=head3 is

	p->is('This exact value');

This test method adds a test which checks that the test subject is identical to the expected value. It uses the C<eq> comparison operator.

=cut

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

=head3 eq, ne, gt, lt, ge, lt, le

	p->ge(c, 'a')->ok('b');
	p->ge(cNum, 2)->ok(10);

Tests sort order against a comparator. The first argument is a comparison function, see C<Test::Proto::Compare>. The second argument is the comparator.

=cut

define_test _cmp => sub {
	# todo: implement the logic (!)
	return sub {
		my ($self, $subject, $test, $expected, $reason) = @_; # self is the context, NOT the prototype
		if($subject le $expected) {
			return $self->test_pass($subject, $test, $expected, $reason); 
		}
		else {
			return $self->test_fail($subject, $test, $expected, $reason);
		}
	}
}; 

sub le
{
	my ($self, $cmp, $expected, $reason) = @_;
	$self->add_test('le', _cmp($cmp, 'le', $expected), $reason);
}


#todo

=head3 validate

	my $result = $p->validate($subject);
	warn $result unless $result;

Runs through the tests in the prototype and checks that they all pass. It returns a TestRunner which evaluates true or false accordingly. 

If you have an existing TestRunner, you can pass it that as well;

	my $result = $p->validate($subject, $context);

=cut

sub validate {
	my ($self, $subject, $context) = @_;
	if (!defined $context or !ref $context){ # if context is not a TestRunner
		$context = Test::Proto::TestRunner->new($context);
	}
	run_tests($self, $subject, $context);
	return $context;
}

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut

