package Test::Proto::Base;
use 5.006;
use strict;
use warnings;
use base 'Test::Builder::Module';
use Test::Deep::NoTest; # provides eq_deeply for _is_deeply. Consider removing this dependency.
use Test::Proto::Test;
use Test::Proto::Fail;
use Test::Proto::Exception;
use Data::Dumper; # not used in canonical but keep for the moment for development
$Data::Dumper::Indent = 0;
$Data::Dumper::Terse = 1;
$Data::Dumper::Sortkeys = 1;
our $VERSION = '0.011';
my $CLASS = __PACKAGE__;

sub initialise
{
	return $_[0];
}

sub new
{
	my $class = shift;
	my $self = bless {
		tests=>[],
	}, $class;
	return $self->initialise;
}

sub clone
{
	my $self = shift;
	my $new = bless {
		tests=>$self->{'tests'},
	}, ref $self;
	return $new;
}

sub add_test #???
{
	my ($self, $testtype, @args) = @_;
	my $test = Test::Proto::Test->new($testtype, @args);

	if (defined $test)
	{
		push @{$self->{'tests'}}, $test;
	}
	else
	{
		warn 'Failed to create test!'; # exception?
		return undef;
	}

	return $self;
}
sub _is_defined
{
	return sub{
		my $got = shift;
		return fail('undef') unless defined $got;
		return 1;
	};
}
sub _can_be_string
{
	return sub{
		eval {$_[0] .= ''};
		return exception($@) if $@;
		return 1;
	};
}
sub as_string
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_as_string($self->upgrade($expected)), $why);
}

sub _as_string
{
	my ($expected) = @_;
	return sub{
		return $expected->validate("$_[0]");
	};
}
sub as_number
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_as_number($self->upgrade($expected)), $why);
}
sub _as_number
{
	my ($expected) = @_;
	return sub{
		return $expected->validate(0+$_[0]);
	};
}
sub as_bool
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_as_bool($self->upgrade($expected)), $why);
}
sub _as_bool
{
	my ($expected) = @_;
	return sub{
		return $expected->validate($_[0] ? 1 : 0);
	};
}

sub _is_a
{
	my ($type) = @_;
	return sub{
		my $got = shift;
		$type = ref $type if (ref $type);
		unless (ref $got)
		{
			return 'SCALAR' eq $type ? 1 : fail('SCALAR ne '.$type) ;
		}
		foreach (qw(
		SCALAR
		ARRAY
		HASH
		CODE
		REF
		GLOB
		LVALUE
		FORMAT
		IO
		VSTRING
		Regexp))
		{
			if (ref $got eq $_)
			{
				return $_ eq $type ? 1 : fail ("$_ ne $type");
			}
		}
		return $got->isa($type);
	}
}
sub _is_ne
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = "$got" ne "$expected"};
		return exception($@) if $@;
		return $result ? 1 : fail("\"$got\" eq \"$expected\"");
	};
}
sub _is_also
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = $expected->validate($got)};
		return exception($@) if $@;
		return $result;
	};
}

sub validate
{
	my ($self, $got) = @_;
	foreach (@{$self->{'tests'}})
	{
		my $result = $_->run($got);
		return $result unless $result;
	}
	return 1;
}
sub is_also
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_also($self->upgrade($expected)), $why);
}

sub is_a
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_a($expected), $why);
}
sub is_defined
{
	my ($self, $why) = @_;
	$self->add_test(_is_defined(), $why);
}
sub ok
{
	my($self, $got, $why) = @_;
	my $tb = $CLASS->builder;
	my $result = $self->validate($got);
	# output failure:
	$tb->diag($result) unless $result;
	return $tb->ok($result, $why);
}
sub eq
{
	my ($self, $cmp, $expected, $why) = @_;
	$self->add_test(_cmp($cmp, 'eq', $expected), $why);
}
sub ne
{
	my ($self, $cmp, $expected, $why) = @_;
	$self->add_test(_cmp($cmp, 'ne', $expected), $why);
}
sub gt
{
	my ($self, $cmp, $expected, $why) = @_;
	$self->add_test(_cmp($cmp, 'gt', $expected), $why);
}
sub ge
{
	my ($self, $cmp, $expected, $why) = @_;
	$self->add_test(_cmp($cmp, 'ge', $expected), $why);
}
sub lt
{
	my ($self, $cmp, $expected, $why) = @_;
	$self->add_test(_cmp($cmp, 'lt', $expected), $why);
}
sub le
{
	my ($self, $cmp, $expected, $why) = @_;
	$self->add_test(_cmp($cmp, 'le', $expected), $why);
}

sub is_eq
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_eq($expected), $why);
}
sub is_ne
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_ne($expected), $why);
}
sub is_deeply
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_deeply($expected), $why);
}
sub is_like
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_like($expected), $why);
}
sub is_unlike
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_is_unlike($expected), $why);
}
sub _is_eq
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = "$got" eq "$expected"};
		return exception($@) if $@;
		return $result ? 1 : fail("\"$got\" ne \"$expected\"");
	};
}
sub _cmp
{
	my ($cmp, $type, $expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		my $success=0;
		eval {$result = &{$cmp}($got,$expected)};
		return exception($@) if $@;
		if ($result > 0 and $type =~ /ge|gt|ne/)
		{
			$success = 1;
		}
		elsif ($result == 0 and $type =~ /ge|le|eq/)
		{
			$success = 1;
		}
		elsif ($result < 0 and $type =~ /lt|le|ne/)
		{
			$success = 1;
		}
		return $success ? 1 : fail("\"$got\" !$type \"$expected\"");
	};
}
sub _is_deeply
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result=eq_deeply ($got, $expected)}; # consider replacing this with something more 'native' later. 
		return exception($@) if $@;
		return $result ? 1 : fail(Dumper ($got). " !is_deeply ". Dumper($expected));
	};
}
sub _is_like
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = "$got" =~ m/$expected/};
		return exception($@) if $@;
		return $result ? 1 : fail("\"$got\" !~ /$expected/");
	};
}
sub _is_unlike
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = "$got" !~ m/$expected/};
		return exception($@) if $@;
		return $result ? 1 : fail("\"$got\" =~ /$expected/");
	};
}

sub try
{
	my ($self, $code, $why) = @_;
	$self->add_test(_try($code), $why);
}
sub _try
{
	my ($code) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = &{$code}($got)};
		return exception($@) if $@;
		return $result ? 1 : fail("try returned ".$result);
	};
}
sub upgrade
{
	my ($self, $expected, $why) = @_;
	if (&{_is_a('SCALAR')}($expected))
	{
		return Test::Proto::Base->new($why)->is_eq($expected);
	}
	# returns => implicit elses
	if (&{_is_a('Test::Proto::Base')}($expected) or &{_is_a('Test::Proto::Series')}($expected))
	{
		return $expected;
	}
	if (&{_is_a('Regexp')}($expected))
	{
		return Test::Proto::Base->new($why)->is_like($expected);
	}
	if (&{_is_a('ARRAY')}($expected))
	{
		return Test::Proto::ArrayRef->new($why)->is_deeply($expected); # iterate?
	}
	if (&{_is_a('HASH')}($expected))
	{
		return Test::Proto::HashRef->new($why)->is_deeply($expected);
	}
	if (&{_is_a('CODE')}($expected))
	{
		return Test::Proto::Base->new($why)->add_test($expected);
	}
	if (ref $expected)
	{
		return Test::Proto::Object->new($why)->is_a(ref $expected);
	}
	return $expected; # exception?
}

sub fail
{
	# should there be a metasugar module for things like this?
	# More detailed interface to T::P::Fail? (More detailed T::P::F first!)
	my ($why) = @_;
	# warn $why; # results in false positives
	return Test::Proto::Fail->new($why);
}

sub exception
{
	my ($why) = @_;
	return Test::Proto::Exception->new($why);
}


#sub fail
#{
#	my ($self, $name, $why) = @_;
#	return Test::Proto::Fail->new();
#}

return 1; # module loaded ok

=pod

=head1 NAME

Test::Proto::HashRef - Test Prototype for Hash References. 

=head1 SYNOPSIS

	my $p = Test::Proto::Base->new->is_eq(-5);
	$p->ok ($temperature) # will fail unless $temperature is -5
	$p->ok ($score) # you can use the same test multple times
	ok($p->validate($score)) # If you like your "ok"s first

This is a test prototype which requires that the value it is given is defined and is a hashref. It provides methods for interacting with hashrefs. (To test hashes, make them hashrefs and test them with this module)

=head1 METHODS

=head3 new

	my $test = Test::Proto::Base->new();

Creates a new Test::Proto::Base object. 

=head3 initialise

When C<new> is called, C<initialise> is called on the object just before it is returned. This mostly exists so that subclasses wishing to add initial tests do not have to overload C<new>.

=head3 validate

	my $result = $p->validate($input);
	warn $result unless $result;

Runs through the tests in the prototype and checks that they all pass. If they do, returns true. If not, returns the appropriate fail or exception object. 

=head3 ok

	my $result = $p->ok($input, '$input must be valid');

Like validate but attached to L<Test::Builder>, like L<Test::More>'s C<ok>.

=head3 add_test

	my $result = $p->add_test(sub{return $_[0] ne '';})->ok($input, '$input must be nonempty');

Adds a test to the end of the list of tests to be performed when C<validate> or C<ok> is called. It is normally better to use C<try>, as that wraps your code in an C<eval> block.

=head3 upgrade

	my $pInt = $p->upgrade(qr/^[a-z]+$/);
	my $pAnswer = $p->upgrade(42);

Upgrading is an internal funciton but is documented here as it as an important concept. Basically, it is a Do What I Mean function for parameters to many arguments, e.g. if you require an array value to be C<qr/^[a-z]+$/>, then rather than expecting an identical regex object, the regex is 'upgraded' to a Test::Proto::Base object with a single test: C<is_like(qr/^[a-z]+$/)>. This works for strings, arrayrefs and hashrefs too.

=head3 is_a

	p->is_a('SCALAR')->ok('String');
	p->is_a('HASH')->ok({a=>1});
	p->is_a('XML::LibXML::Node')->ok(XML::LibXML::Element->new());
	p->is_a('XML::LibXML::Element')->ok(XML::LibXML::Element->new());

Like Perl's C<ref> and C<isa> rolled into one.

=head3 is_also

	my $nonempty = p->is_like(qr/\w+/);
	my $lowercase = p->is_unlike(qr/[A-Z]/)->is_also($nonempty);

Allows you to effectively import all the tests of another prototype. 

This is not to be confused with C<is_a>!

=head3 is_defined

	p->is_defined->ok($input);

Succeeds unless the value is C<undef>. 

=head3 is_eq

	p->is_eq('ONION')->ok($input);

Tests for string equality.

=head3 is_ne

	p->is_ne('GARLIC')->ok($input);

Tests for string inequality.

=head3 is_deeply

	p->is_deeply({ingredient=>'ONION', qty=>3})->ok($input);

Recursively test using C<Test::More::is_deeply>

=head3 is_like

	p->is_like(qr/^[a-z]+$/)->ok($input);

Tests if the value matches a regex.

=head3 is_unlike

	p->is_unlike(qr/^[a-z]+$/)->ok($input);

Tests if the value fails to match a regex.

=head3 clone

	my $keyword = p->is_unlike(qr/^[a-z]+$/);
	$keyword->clone->is_ne('undef')->ok($perlword);
	$keyword->clone->is_ne('null')->ok($jsonword);

Creates a clone of the current C<Test::Proto::Base> object. Child tests are not recursively cloned, they remain references, but the list of tests can be added to independently. 

=head3 as_string

	p->as_string(p->is_like(qr/<html>/))->ok($input);
	p->as_string(qr/<html>/)->ok($input);

Coerces the value to a string, then tests the result against the prototpye which is the first argument.

=head3 as_number

	p->as_number(p->eq(cNum,42))->ok($input);
	p->as_number(42)->ok($input);

Coerces the value to a number, then tests the result against the prototpye which is the first argument.

=head3 as_bool

	p->as_bool(1)->ok($input);

Coerces the value to a boolean, then tests the result against the prototpye which is the first argument. 

=head3 eq, ne, gt, lt, ge, lt, le

	p->ge(c, 'a')->ok('b');
	p->ge(cNum, 2)->ok(10);

Tests sort order against a comparator. The first argument is a comparison function, see C<Test::Proto::Compare>. The second argument is the comparator.

=head3 try

	$p->try(sub{return $_[0] ne '';})->ok($input, '$input must be nonempty');

Execute arbitrary code.

=head3 fail

This is a subroutine which is an alias for C<Test::Proto::Fail->new()>.

=head3 exception

This is a subroutine which is an alias for C<Test::Proto::Exception->new()>.

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut

