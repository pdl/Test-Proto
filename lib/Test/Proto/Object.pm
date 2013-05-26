package Test::Proto::Object;
use 5.006;
use strict;
use warnings;
use Moo;
extends 'Test::Proto::Base';
use Test::Proto::Common;

=head1 NAME

Test::Proto::Object - Test an object's behaviour

=head3 method

	$p->method('open', ['test.txt','>'], [$fh])->ok($subject);

Takes three arguments, a method, the arguments to use with the method, and the expected return value. Calls the method on the test subject, with the arguments, and tests the return value. 

The arguments and return value should be arrayrefs; the method is evaluated in list context.

=cut

sub method {
	my ($self) = shift;
	$self->method_list_context(@_);
}

=head3 method_void_context

	$p->method('open', ['test.txt','>'])->ok($subject);

Takes two arguments, a method, and the arguments to use with the method. Calls the method on the test subject, with the arguments. 

The arguments should be na arrayref; the method is evaluated in void context. This test will always pass, unless the method dies (or does not exist).

=cut


sub method_void_context {
	my ($self, $method, $args, $reason) = @_;
	$self->add_test('method_void_context', {
		method => $method,
		args => $args,
	}, $reason);
}

define_test "method_void_context" => sub {
	my ($self, $data, $reason) = @_; # self is the runner
	my $args = $data->{args};
	my $method = $data->{method};
	$self->subject->$method(@$args);
	return $self->pass; # void context so we pass unless it dies.
};

=head3 method_scalar_context

	$p->method_scalar_context('open', ['test.txt','>'], $true)->ok($subject);

Takes three arguments, a method, the arguments to use with the method, and the expected return value. Calls the method on the test subject, with the arguments, and tests the return value. 

The arguments should be an arrayref, and the expected value should be a prototype evaluating the returned scalar, as the method is evaluated in scalar context.

=cut


sub method_scalar_context {
	my ($self, $method, $args, $expected, $reason) = @_;
	$self->add_test('method_scalar_context', {
		method => $method,
		args => $args,
		expected => $expected 
	}, $reason);
}

define_test "method_scalar_context" => sub {
	my ($self, $data, $reason) = @_; # self is the runner
	my $args = $data->{args};
	my $method = $data->{method};
	my $expected = upgrade($data->{expected});
	my $response = $self->subject->$method(@$args);
	return $expected->validate($response, $self);
};

=head3 method_list_context

	$p->method_list_context('open', ['test.txt','>'], [$true])->ok($subject);

Takes three arguments, a method, the arguments to use with the method, and the expected return value. Calls the method on the test subject, with the arguments, and tests the return value. 

The arguments and return value should be arrayrefs; the method is evaluated in list context.

=cut


sub method_list_context {
	my ($self, $method, $args, $expected, $reason) = @_;
	$self->add_test('method_list_context', {
		method => $method,
		args => $args,
		expected => $expected 
	}, $reason);
}

define_test method_list_context => sub {
	my ($self, $data, $reason) = @_; # self is the runner
	my $args = $data->{args};
	my $method = $data->{method};
	my $expected = upgrade($data->{expected});
	my $response = [$self->subject->$method(@$args)];
	return $expected->validate($response, $self);
};

1;
