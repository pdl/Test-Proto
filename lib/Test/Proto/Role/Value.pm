package Test::Proto::Role::Value;
use 5.006;
use strict;
use warnings;
use Test::Proto::Common;
use Moo::Role;

=head1 NAME

Test::Proto::Role::Value - Role containing test case methods for any perl value

=head1 SYNOPSIS

	package MyProtoClass;
	use Moo;
	with 'Test::Proto::Role::Value';

This Moo Role provides methods to L<Test::Proto::Base> for common test case methods like C<eq>, C<defined>, etc. which can potentially be used on any perl value/object.

=head1 METHODS

=head3 eq, ne, gt, lt, ge, le

	p->eq('green')->ok('green'); # passes
	p->lt('green')->ok('grape'); # passes

Performs the relevant string comparison on the subject, comparing against the text supplied. 

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

	p->num_eq(0)->ok(0); # passes
	p->num_lt(256)->ok(255); # passes

Performs the relevant string comparison on the subject, comparing against the number supplied. 

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

	p->true->ok("Strings are true"); # passes
	p->false->ok($undefined); # fails

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

	p->defined("Pretty much anything"); # passes

Note that directly supplying undef into the protoype (as opposed to a variable containing undef, a function which returns undef, etc.) will exhibit different behaviour: it will attempt to use C<$_> instead.

	$_ = 3;
	$undef = undef;
	p->undefined(undef); # fails
	p->undefined($undef); # passes

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

The test subject is validated against the regular expression. Like tests for a match; unlike tests for nonmatching.

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


=head3 try

	p->try( sub { 'a' eq lc shift; } )->ok('A');

Used to execute arbitrary code. Passes if the return value is true.

=cut

sub try {
	my ($self, $expected, $reason) = @_;
	$self->add_test('try', { expected => $expected }, $reason);
}

define_test 'try' => sub {
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	if($data->{expected}->($self->subject)) {
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

=head3 also

	$positive = p->num_gt(0);
	$integer->also($positive);
	$integer->also(qr/[02468]$/);
	$integer->ok(42); # passes

Tests that the subject also matches the protoype given. If the argument given is not a prototype, the argument is upgraded to become one.

=cut

sub also {
	my ($self, $expected, $reason) = @_;
	$self->add_test('also', { expected => $expected }, $reason);
}

define_test also => sub{
	my ($self, $data, $reason) = @_; # self is the runner, NOT the prototype
	return upgrade($data->{expected})->validate($self->subject, $self); 
};

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut

1;