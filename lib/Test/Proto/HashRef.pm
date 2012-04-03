package Test::Proto::HashRef;
use 5.006;
use strict;
use warnings;
use base 'Test::Proto::Base';
use Test::Proto::ArrayRef;

sub initialise
{
	my ($self) = @_;
	$self->is_defined;
	$self->is_a('HASH');
}

sub is_empty
{
	my ($self, $why) = @_;
	$self->add_test(_keys(Test::Proto::ArrayRef->new()->is_empty), $why);
}
sub values
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_values($self->upgrade($expected)), $why);
}
sub keys
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_keys($self->upgrade($expected)), $why);
}
sub key_value
{
	my ($self, $key, $expected, $why) = @_;
	$self->add_test(_key_value($key,$self->upgrade($expected)), $why);
}
sub key_values
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_key_value($_,$self->upgrade($expected->{$_})), $why) foreach (CORE::keys %{$expected}); # TODO: check $expected is a hashref!
	return $self;
}
sub _keys
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = $expected->validate([CORE::keys %$got])};
		return Test::Proto::Base::fail($@) if $@;
		return $result;
	};
}
sub _key_value
{
	my ($key, $expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = $expected->validate($got->{$key})};
		return Test::Proto::Base::fail($@) if $@;
		return $result;
	};
}
sub _values
{
	my ($expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval {$result = $expected->validate([CORE::values %$got])};
		return Test::Proto::Base::fail($@) if $@;
		return $result;
	};
}

return 1; # module loaded ok

=pod
=head1 NAME

Test::Proto::HashRef - Test Prototype for Hash References. 

=head1 SYNOPSIS

	Test::Proto::HashRef->new->ok({a=>undef,b=>2,c=>'three'}); # ok
	Test::Proto::HashRef->new->ok({}); # ok
	Test::Proto::HashRef->new->is_empty->ok({}); # still ok
	Test::Proto::HashRef->new->is_deeply({a=>undef,'c'=>"three", b=>2,})->ok({a=>undef,b=>2,c=>'three'}); # also ok

This is a test prototype which requires that the value it is given is defined and is a hashref. It provides methods for interacting with hashrefs. (To test hashes, make them hashrefs and test them with this module)

=head1 METHODS

See L<Test::Proto::Base> for documentation on common methods.

=head3 keys

=head3 values

=head3 is_empty

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

