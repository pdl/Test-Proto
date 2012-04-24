package Test::Proto::Compare;
use 5.006;
use strict;
use warnings;
use overload "&{}"=>\&_as_code;

sub new
{
	my ($class, $code) = @_;
	$code = sub {$_[0] cmp $_[1];} unless defined $code;
	bless {
		'reverse'=>'0',
		'code'=>$code,
	}, $class;
}
sub compare
{
	my ($self, $A, $B) = @_;
	if ($self->{'reverse'})
	{
		return &{$self->{'code'}}($B, $A)
	}
	else
	{
		return &{$self->{'code'}}($A, $B)
	}
}
sub _as_code
{
	my ($self) = @_;
	if ($self->{'reverse'})
	{
		return sub{my $A = shift; my $B = shift; &{$self->{'code'}}($B, $A)};

	}
	else
	{
		return $self->{'code'};
	}
}

1;


=pod
=head1 NAME

Test::Proto::Compare - base class for comparisons.

=head1 SYNOPSIS

	Test::Proto::Compare->new->compare('aaa', 'aab'); # 1

This is a test prototype which requires that the value it is given is defined and is a scalar. It provides methods for interacting with strings.

=head1 METHODS



=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 
=cut
