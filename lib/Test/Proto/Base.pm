package Test::Proto::Base;
use 5.006;
use strict;
use warnings;
use Test::Proto::TestRunner;
use Test::Proto::TestCase;
use Moo;
use Sub::Name;

our $VERSION = '0.011';

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


=pod

=head1 NAME

Test::Proto::Base - Base Class for Test Prototypes

=head1 SYNOPSIS

	my $p = Test::Proto::Base->new->is_eq(-5);
	$p->ok ($temperature) # will fail unless $temperature is -5
	$p->ok ($score) # you can use the same test multple times
	ok($p->validate($score)) # If you like your "ok"s first

This is a base class for test prototypes. 

Note that it is a Moo class.

=cut

=head1 METHODS

=head2 PUBLIC METHODS

These are the methods intended for use when writing tests.

=cut

=head3 is

	p->is('This exact value');

This test method adds a test which checks that the test subject is identical to the expected value. It uses the C<eq> comparison operator.

=cut

sub is {
	my ($self, $expected, $reason) = @_;
	$self->add_test('is', { expected => $expected }, $reason);
};

define_test is => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	if($self->subject eq $data->{expected}) {
		return $self->pass; 
	}
	else {
		return $self->fail;
	}
}; 

=head3 eq, ne, gt, lt, ge, le


=cut

sub eq {
	my ($self, $expected, $reason) = @_;
	$self->add_test('eq', { expected => $expected }, $reason);
}
sub ne {
	my ($self, $expected, $reason) = @_;
	$self->add_test('ne', { expected => $expected }, $reason);
}
sub gt {
	my ($self, $expected, $reason) = @_;
	$self->add_test('gt', { expected => $expected }, $reason);
}
sub lt {
	my ($self, $expected, $reason) = @_;
	$self->add_test('lt', { expected => $expected }, $reason);
}
sub ge {
	my ($self, $expected, $reason) = @_;
	$self->add_test('ge', { expected => $expected }, $reason);
}
sub le {
	my ($self, $expected, $reason) = @_;
	$self->add_test('le', { expected => $expected }, $reason);
}

=head3 num_eq, num_ne, num_gt, num_lt, num_ge, num_le


=cut

sub num_eq {
	my ($self, $expected, $reason) = @_;
	$self->add_test('num_eq', { expected => $expected }, $reason);
}
sub num_ne {
	my ($self, $expected, $reason) = @_;
	$self->add_test('num_ne', { expected => $expected }, $reason);
}
sub num_gt {
	my ($self, $expected, $reason) = @_;
	$self->add_test('num_gt', { expected => $expected }, $reason);
}
sub num_lt {
	my ($self, $expected, $reason) = @_;
	$self->add_test('num_lt', { expected => $expected }, $reason);
}
sub num_ge {
	my ($self, $expected, $reason) = @_;
	$self->add_test('num_ge', { expected => $expected }, $reason);
}
sub num_le {
	my ($self, $expected, $reason) = @_;
	$self->add_test('num_le', { expected => $expected }, $reason);
}


=head3 true, false

Tests if the subject returns true or false in boolean context.

=cut

sub true {
	my ($self, $expected, $reason) = @_;
	$self->add_test('true', { expected => 'true' }, $reason);
}

define_test 'true' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	if($self->subject) {
		return $self->pass; 
	}
	else {
		return $self->fail;
	}
};

sub false {
	my ($self, $expected, $reason) = @_;
	$self->add_test('false', { expected => 'false' }, $reason);
}

define_test 'false' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	if($self->subject) {
		return $self->fail;
	}
	else {
		return $self->pass; 
	}
}; 

=head3 defined, undefined

Tests if the subject is defined/undefined.

=cut

sub defined {
	my ($self, $expected, $reason) = @_;
	$self->add_test('defined', { expected => 'defined' }, $reason);
}

define_test 'defined' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	if(defined $self->subject) {
		return $self->pass;
	}
	else {
		return $self->fail; 
	}
}; 


sub undefined {
	my ($self, $expected, $reason) = @_;
	$self->add_test('undefined', { expected => 'undefined' }, $reason);
}

define_test 'undefined' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	if(defined $self->subject) {
		return $self->fail;
	}
	else {
		return $self->pass; 
	}
}; 

=head3 like, unlike

	p->like(qr/^a$/)->ok('a');
	p->unlike(qr/^a$/)->ok('b');

=cut

sub like {
	my ($self, $expected, $reason) = @_;
	$self->add_test('like', { expected => $expected }, $reason);
}

define_test 'like' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $re = $data->{expected};
	if($self->subject =~ m/$re/) {
		return $self->pass;
	}
	else {
		return $self->fail; 
	}
}; 

sub unlike {
	my ($self, $expected, $reason) = @_;
	$self->add_test('unlike', { expected => $expected }, $reason);
}

define_test 'unlike' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	my $re = $data->{expected};
	if($self->subject !~ m/$re/) {
		return $self->pass;
	}
	else {
		return $self->fail;
	}
}; 


=head3 ref

	p->ref(undef)->ok('b');
	p->ref('less')->ok(less);
	p->ref(qr/[a-z]+/)->ok(less);

Tests the result of the 'ref'. Any prototype will do here.

=cut

sub ref {
	my ($self, $expected, $reason) = @_;
	$self->add_test('ref', { expected => $expected }, $reason);
}

define_test 'ref' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	if(CORE::ref($self->subject) eq $data->{expected}) {
		return $self->pass; 
	}
	else {
		return $self->fail;
	}
}; 

=head3 is_a

	p->is_a('')->ok('b');
	p->is_a('less')->ok(less);

Tests the result of the 'is_a'. Must be a string.

=cut

sub is_a {
	my ($self, $expected, $reason) = @_;
	$self->add_test('is_a', { expected => $expected }, $reason);
}

define_test is_a => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	if((CORE::ref $self->subject) =~ /^(SCALAR|ARRAY|HASH|CODE|REF|GLOB|LVALUE|FORMAT|IO|VSTRING|Regexp)$/) {
		if($1 eq $data->{expected}) {
			return $self->pass;
		}
	}
	elsif(CORE::ref $self->subject) {
		if($self->subject->isa($data->{expected})) {
			return $self->pass; 
		}
	}
	elsif((!defined $data->{expected}) or $data->{expected} eq '') {
		return $self->pass;
	}
	return $self->fail;
};
{
	my %num_eqv = qw(eq == ne != gt > lt < ge >= le <=);
	foreach my $dir (keys %num_eqv){
	
		define_test $dir => sub {
			my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
			my $result;
			eval "\$result = \$self->subject $dir \$data->{expected}";
			if($result) {
				return $self->pass;
			}
			else {
				return $self->fail;
			}
		};

		my $num_dir = $num_eqv{$dir};

		define_test "num_$dir" => sub {
			my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
			my $result;
			eval "\$result = \$self->subject $num_dir \$data->{expected}";
			if($result) {
				return $self->pass;
			}
			else {
				return $self->fail;
			}
		};
	}
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
	$subject = $_ unless exists $_[1];
	if (!defined $context or !CORE::ref($context)){ # if context is not a TestRunner
		$context = Test::Proto::TestRunner->new(subject=>$subject);
	}else{
		$context->subject($subject);
	}
	$self->run_tests($context);
	$context->done;
	return $context;
}

=head3 clone

This method returns a copy of the current object. The new object can have tests added without affecting the existing test.

=cut

sub clone
{
	my $self = shift;
	my $new = bless {
		script=>$self->{'script'}, # that won't work!
	}, CORE::ref $self;
	return $new;
}



=head2 PROTOTYPER METHODS

These are for documentation purposes only.

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

=head3 add_test

This method adds a test to the current object, specifically to the C<user_script>, and returns the prototype object.

This is documented for information purposes only and is not intended to be used except in the maintainance of C<Test::Proto> itself.

=cut

sub add_test{
	my ($self, $name, $data, $reason)  = @_;
	my $package = CORE::ref ($self); 
  
	my $testMethodName = $package.'::TEST_'.$name;
	my $code = sub {
		my $runner = shift;
		my $subject = $runner->subject;
		{
			no strict 'refs';
			eval { &{$testMethodName} ($runner, $data, $reason); };
			$runner->parent->exception($@) if $@;
		}
	};
	push @{ $self->user_script }, Test::Proto::TestCase->new(
		name=>$name,
		code=>$code,
		data=>$data,
		reason=>$reason,
	);
	return $self;
}

=head3 run_test

	$self->run_test($test, $subject, $context);

This method runs a particular test in the object's script, and returns the prototype object. It is called by the C<< ->run_tests >> method.

This is documented for information purposes only and is not intended to be used except in the maintainance of C<Test::Proto> itself.

=cut
use Data::Dumper;
sub run_test{
	my ($self, $test, $context) = @_;
	my $runner =  $context->subtest(test_case=>$test, subject=>$context->subject);
	my $result = $test->code->($runner);
	$runner->exception("Test execution did not return a result. Return value was ". Dumper (\$result)) unless $runner->is_complete;
	return $self;
}


=head3 run_tests

	$self->run_tests($subject, $context);

This method runs all the tests in the prototype object's script (simply calling the C<< ->run_test >> method on each), and returns the prototype object. 

This is documented for information purposes only and is not intended to be used except in the maintainance of C<Test::Proto> itself.

=cut

sub run_tests{
	my ($self, $context) = @_;
	my $runner = $context->subtest(test_case=>$self);
	foreach my $test (@{ $self->script }){
		$self->run_test($test, $runner);
	}
	$runner->done;
	return $self;
}

=head3 define_test

	define_test 'is_uppercase', sub {
		my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
		if ($self->subject =~ !/[a-z]/){ 
			return $self->pass;
		}
		return $self->fail;
	}

=cut


# define_test defined above

=head3 add_test_method

	add_test_method 'is_uppercase', sub { $_[1]->subject =~ !/[a-z]/ }


=cut

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut
1;
