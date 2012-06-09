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
sub key_values # cf. Test::Deep::superhashof
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_key_value($_,$self->upgrade($expected->{$_})), $why) foreach (CORE::keys %{$expected}); # TODO: check $expected is a hashref!
	return $self;
}
sub allow_only # cf. Test::Deep::subhashof
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_keys($self->upgrade([CORE::keys %$expected])), $why);
	$self->add_test(_key_value($_,$self->upgrade($expected->{$_}, 1)), $why) foreach (CORE::keys %{$expected}); # TODO: check $expected is a hashref!
	return $self;
}
sub only_key_values # cf. Test::Deep::cmp_deeply
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_keys($self->upgrade([CORE::keys %$expected])), $why);
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
		return Test::Proto::Base::exception($@) if $@;
		return $result;
	};
}
sub _key_value
{
	my ($key, $expected, $optional) = @_;
	return sub{
		my $got = shift;
		my $result;
		if ($optional)
		{
			eval {$result = $expected->validate($got->{$key})} if exists $got->{$key};
			return Test::Proto::Base::exception($@) if $@;
		}
		else
		{
			eval {$result = $expected->validate($got->{$key})};
			return Test::Proto::Base::exception($@) if $@;
		}
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
		return Test::Proto::Base::exception($@) if $@;
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

	pHr->keys(['a'])->ok({a=>1}, 'Keys of {a=>1} returns ['a']');

Gets the keys of the hash, and validates them as an arrayref. Note that the keys are not likely to be sorted in nay particular order.

=head3 values

	pHr->values([1])->ok({a=>1}, 'Keys of {a=>1} returns [1]');

Gets the values of the hash, and validates them as an arrayref. Note that the values are not likely to be sorted in nay particular order.

=head3 key_value

	pHr->key_value('a', pSt->is_eq('b'))->ok({a=>'b',c=>4});

Gets the value of a particular hash key, and validates it, upgrading the expected value as necessary.

=head3 key_values

	pHr->key_value({'a' => pSt->is_eq('b'), c=>4})->ok({a=>'b',c=>4, e=>'VI'});

Gets the value of several hash keys, and validates them against the value, upgrading the expected value as necessary. Extra hash keys are ignored. 

=head3 allow_only

	pHr->key_value({'a' => pSt->is_eq('b'), c=>4, g=>'eight'})->ok({a=>'b',c=>4, e=>'VI'});

Like C<key_values> but all values in the prototype hash are optional, i.e. 'if present, they must be this'. 

=head3 only_key_values

	pHr->key_value({'a' => pSt->is_eq('b'), c=>4})->ok({a=>'b',c=>4});

Like C<key_values> but no keys are permitted except those specified. This is effectively a deep equality check for the hash, except the key values can be prototypes rather than values.

=head3 is_empty

	pHr->is_empty->ok({});

Fails if the hash is not empty, otherwise succeeds. 

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut

