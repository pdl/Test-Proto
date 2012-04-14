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
	$self->{'contents'} = $contents;
}

sub validate_many
{
	my ($self, $got) = @_;
	my @got = @$got;
	foreach my $expect (map {$self->upgrade($_)} @{$self->{'contents'}})
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

	#Test::Proto::Series->new()

This is a container for test prototypes. To validate arrays/lists, consider using L<Test::Proto::ArrayRef>. 

=head1 METHODS

=head3 validate_many

=head3 validate

=head3 set_contents

=head3 new

=head3 clone

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 


