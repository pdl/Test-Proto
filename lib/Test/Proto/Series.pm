package Test::Proto::Series;
use 5.006;
use strict;
use warnings;

sub initialise
{
	return $_[0];
}

sub new
{
	my $class = shift;
	my $self = bless {
		contents=>[@_],
		repeat_min=>1,
		repeat_max=>1,
	}, $class;
	return $self->initialise;	
}

sub clone
{
	my $self = shift;
	my $new = bless {
		contents=>$self->{'contents'},
	}, ref $self;
	return $new;
}

sub set_contents
{
	my ($self, $contents) = @_;
	$self->{'contents'} = $contents if defined $contents;
	return $self;
}

sub repeat
{
	my ($self, $min, $max) = @_;
	$self->{'repeat_min'} = $min;
	$self->{'repeat_max'} = $max; # test $max
	return $self;
}

sub validate_many
{
	my ($self, $got) = @_;
	my $remainder = [@$got];
	$self->{'contents'} = [map {$self->upgrade($_)} @{$self->{'contents'}}];
	my $i;
	if ($self->{'repeat_min'})
	{
		for ($i = 1; $i <= $self->{'repeat_min'}; $i++)
		{
			$remainder = $self->_validate_many($remainder);
			return $remainder unless $remainder; # catches fails
		}
	}
	my $successful_remainder = $remainder;
	if ($self->{'repeat_max'} > $self->{'repeat_min'})
	{
		for (1; $i <= $self->{'repeat_max'}; $i++)
		{
			$remainder = $self->_validate_many($remainder);
			return $successful_remainder unless $remainder; # catches fails
			return $successful_remainder unless @$remainder; # catches empty returns
			$successful_remainder = [@$remainder]; # 
		}
	}
	return $successful_remainder;
}
sub _validate_many
{
	my ($self, $got) = @_;
	my @got = @$got;
	foreach my $expect (@{$self->{'contents'}})
	{
		if ($expect->can('validate_many'))
		{
			my $remainder = $expect->validate_many([@got]); # 
			return $remainder unless $remainder;
			@got = @$remainder;
		}
		else
		{
			my $this = shift @got;
			my $result = $expect->validate($this);
			return $result unless $result;
		}
	}
	return [@got];
}

sub validate
{
	my ($self, $got) = @_;
	return $self->validate_many([$got]);
}

sub upgrade {Test::Proto::Base::upgrade(@_);}

return 1; # module loaded ok

=pod

=head1 NAME

Test::Proto::Series - Container for test prototypes.

=head1 SYNOPSIS

	Test::Proto::Series->new(pAr,pHr)

This is a container for test prototypes and is used to create groups, repetition, and options in DTD-like validation methods such as C<Test::Proto::ArrayRef::contains_only>. To validate arrays/lists, consider using L<Test::Proto::ArrayRef>. 

=head1 METHODS

=head3 new

Constructor. Arguments become contents.

=head3 validate_many

	my $remainder = $series->validate_many(['ONION', 'TURNIP', 'SALT']);

Tries to match all the elements in the argumnent withe the contents previously specified. It will return the remaining elements, or the first failure it runs into. 

=head3 validate

	my $remainder = $series->validate('ONION');

Near-alias for C<validate_many>, but wraps the first argument in an arrayref.

=head3 initialise

When C<new> is called, C<initialise> is called on the object just before it is returned. This mostly exists so that subclasses wishing to add initial tests do not have to overload C<new>.

=head3 repeat

	pSeries($valid_key, $integer)->repeat(1,10);

Sets the minimum and maximum repeats allowed. 

=head3 set_contents

	$series->set_contents([$valid_key, $integer]);

Sets the contents allowed in the series. Returns the series.

=head3 clone

	my $series = pSeries($valid_key, $integer)->repeat(1,10);
	$series->clone->repeat(1,20)->validate_many($long_key_list);

Creates a copy of the series. Individual contents remain references.

=head3 upgrade

Works like C<Test::Proto::Base::Upgrade>, s.v.

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut

