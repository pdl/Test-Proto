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

sub reverse
{
	my ($self) = @_;
	$self->{'reverse'} = !$self->{'reverse'};
	return $self;
}

1;


=pod

=head1 NAME

Test::Proto::Compare - base class for comparisons.

=head1 SYNOPSIS

	Test::Proto::Compare->new->compare('aaa', 'aab'); # -1

This is a base class for comparison functions. 

=head1 METHODS

=head3 new

	Test::Proto::Compare->new(sub{lc shift cmp lc shift;});

The new function takes an argument, the coderef which is used to do the comparison. It is optional, and defaults to C<cmp>. 

=head3 compare

	$c->compare($a,$b);

This method will compare two arguments and return the result. 

=head3 reverse

	$c->reverse->compare($a,$b);
	# i.e.   $c->compare($b,$a);

Calling this method will reverse the order in which the arguments are fed to the comparison functions.

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut

