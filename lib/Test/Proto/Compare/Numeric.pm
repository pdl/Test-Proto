package Test::Proto::Compare::Numeric;
use 5.006;
use strict;
use warnings;
use base 'Test::Proto::Compare';

sub new
{
	my ($class) = @_;
	my $code = sub {$_[0] <=> $_[1];};
	bless {
		'reverse'=>'0',
		'code'=>$code,
	}, $class;
}

1;

=pod

=head1 NAME

Test::Proto::Compare::Numeric - class for numeric comparison.

=head1 SYNOPSIS

	Test::Proto::Compare::Numeric->new->compare('11', '2'); # -1

This is a class for comparing numbers, derived from L<Test::Proto::Compare>. It has no additional methods; the new function does not take a coderef

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut

