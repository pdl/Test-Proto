package Test::Proto;

use 5.006;
use strict;
use warnings;
use Test::Proto::String;
use Test::Proto::Base;
# use Test::Proto::Undef;
use Test::Proto::HashRef;
use Test::Proto::ArrayRef;
use Test::Proto::Fail; # need we load this here?
# use Test::Proto::CodeRef; # 
use Test::Proto::Object;
use base "Exporter";
our @EXPORT_OK = qw(&pSomething &pSt &pOb &pHr &pAr); # symbols to export on request

=head1 NAME

Test::Proto - OO test script golf sugar

=head1 VERSION

Version 0.01

=cut

our $VERSION = ${Test::Proto::Base::VERSION};


=head1 SYNOPSIS

This module simplifies writing tests for deep structures and objects.

    use Test::Proto;
	
    pAr->contains_only(pSc, pHr)->ok(["",{a=>'b'}], "This arrayref contains a string followed by a hashref");
	pSt	->is_like(qr/^\d+$/, '+ve ints please')
		->is_unlike(qr/^0\d+$/, 'no leading zeros')
		->ok('123');
	
	pOb
		->is_a('Dung::Spreader')
		->is_a('Dung::Spreader::Champion')
		->can_do('launch', 'Core competency: make it fly for miles')
		->try_can('smell',pAr->is_empty,)
		->ok(Dung::Spreader::Champion->new);

The idea behind Test Proto is that test scripts for code written on modern, OO principles should themselves resemble the target code rather than sequential code. 

Tests for deep structures and objects tend should not be repetitive and should be flexible so that when you decide you need C<< $got->{'wurple'}{'diddle'}{'do'} >> to look like C<< $got->{'wurple'}->diddle->[$i]{'do'} >> you can make a much smaller change to your script. Test::Proto is a framework primarily for testing the same thing for multiple conditions, and testing the things it contains/produces in a similar manner. 

The way it works is that you create a "prototype" (using a subclass of L<Test::Proto::Base>), add tests to the prototype, and validate then your string/arryref/object against the prototype. 

=head1 FUNCTIONS

=head2 pSomething

Returns a string prototype. See L<Test::Proto::String>.

=cut

sub pSomething {
	return Test::Proto::Base->new();
}

=head2 pSt

Returns a string prototype. See L<Test::Proto::String>.

=cut

sub pSt {
	return Test::Proto::String->new();
}

=head2 pOb

Returns an object prototype. See L<Test::Proto::Object>.

=cut

sub pOb {
	return Test::Proto::Object->new();
}

=head2 pAr

Returns an arrayref prototype. See L<Test::Proto::ArrayRef>.

=cut

sub pAr {
	return Test::Proto::ArrayRef->new();
}

=head2 pHr

Returns a hashref prototype. See L<Test::Proto::HashRef>.

=cut

sub pHr {
	return Test::Proto::HashRef->new();
}

=head1 AUTHOR

Daniel Perrett, C<< <perrettdl at googlemail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-proto at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-Proto>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::Proto


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Proto>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-Proto>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test-Proto>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-Proto/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Daniel Perrett.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Test::Proto
