package Test::Proto::HashRef;
use 5.006;
use strict;
use warnings;
use base 'Test::Proto::Base';

sub keys
{
	my ($self, $expected, $why) = @_;
	$self->add_test(_keys($expected), $why);
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

1;

