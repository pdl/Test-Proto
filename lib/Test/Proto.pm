package Test::Proto;

use 5.006;
use strict;
use warnings;
use Test::Proto::Base;
use Test::Proto::ArrayRef;
use Test::Proto::HashRef;
use Test::Proto::CodeRef;
use Test::Proto::Object;
use Test::Proto::Series;
use Test::Proto::Repeatable;
use Test::Proto::Alternation;
use Test::Proto::Compare;
use Test::Proto::Compare::Numeric;
use Test::Proto::Common ();
use Scalar::Util qw(blessed refaddr);
use base "Exporter";
our @EXPORT_OK = qw(&p &pArray &pHash &pCode &pObject &pSeries &pRepeatable &pAlternation &c &cNumeric); # symbols to export on request

=head1 NAME

Test::Proto - OO test script golf sugar

=head1 VERSION

Version 0.011

=cut

our $VERSION = ${Test::Proto::Base::VERSION};


=head1 SYNOPSIS

This module provides an expressive interface for validating deep structures and objects.

	use Test::Proto qw(p pArray pHash pSeries);
	
	pArray	->contains_only(pSeries('', pHash), 
			"ArrayRef must contain only an empty string followed by a hashref")
		->ok(["", {a=>'b'}]);
		# provides diagnostics, including subtests as TAP, using Test::Builder
	
	p	->like(qr/^\d+$/, 'looks like a positive integer')
		->unlike(qr/^0\d+$/, 'no leading zeros')
		->validate('123');
		# returns an object with a true value
	
	pObject	->is_a('XML::LibXML::Node', 'must inherit from XML::LibXML::Node')
		->is_a('XML::LibXML::Element', 'what it really is')
		->method_exists('findnodes', 'must have the findnodes method')
		->method_scalar_context('localName', [], 
			p->like(qr/blockquote|li|p/, 'We can add normal text here')
		)
		->ok(XML::LibXML::Element->new('li'));
		# have a look at the nested prototype in try_can

The idea behind Test::Proto is that test scripts for code written on modern, OO principles should themselves resemble the target code rather than sequential code. 

Tests for deep structures and objects tend should not be repetitive and should be flexible. Test::Proto allows you to create objects "protoypes" intended to test structures which conform to a known type. 

As in the example above, the way it works is: you create a prototype object, add test cases to the prototype using method calls, and then validate your string/arryref/object/etc. against the prototype using . 

NB: The meaning of "prototype" used here is not related to subroutine prototypes (declaring the arguments expected by a given function or method). 

=head1 FUNCTIONS

=head2 p

Returns a basic prototype. See L<Test::Proto::Base>.

=cut

sub p {
	return Test::Proto::Common::upgrade ($_[0]) if 1 == scalar @_;
	return Test::Proto::Base->new(@_);
}

=head2 pArray

Returns a prototype for an array/ArrayRef. See L<Test::Proto::ArrayRef>.

=cut

sub pArray {
	return Test::Proto::Common::upgrade ($_[0]) if 1 == scalar @_;
	return Test::Proto::ArrayRef->new(@_);
}

=head2 pHash

Returns a prototype for a hash/HashRef. See L<Test::Proto::HashRef>.

=cut

sub pHash {
	return Test::Proto::Common::upgrade ($_[0]) if 1 == scalar @_;
	return Test::Proto::HashRef->new(@_);
}

=head2 pCode

Returns a prototype for a CodeRef. See L<Test::Proto::CodeRef>.

=cut

sub pCode {
	return Test::Proto::CodeRef->new(@_);
}

=head2 pObject

	pObject('')

Returns a prototype for an object. See L<Test::Proto::Object>.

=cut

sub pObject {
	if (1 == scalar @_) {
		my $p = Test::Proto::Object->new();
		if (!ref $_[0]) {
			$p->is_a($_[0]);
		}
		elsif ((blessed $_[0]) and $_[0]->isa('Test::Proto::Base')) {
			$p->is_also($_[0]);
		}
		elsif (ref $_[0] =~ /^(?:HASH|ARRAY)$/) {
			$p->is_also(Test::Proto::Common::upgrade ($_[0]));
		}
		else {
			$p->refaddr(refaddr $_[0]) if blessed $_[0];
		}
		return $p;
	}
	else {
		return Test::Proto::Object->new(@_);
	}
}


=head2 pSeries

Returns a series object for use in validating lists. See L<Test::Proto::Series>.

=cut

sub pSeries {
	return Test::Proto::Series->new(@_);
}

=head2 pRepeatable

Returns a repeatable series object for use in validating lists. See L<Test::Proto::Repeatable>.

=cut

sub pRepeatable {
	return Test::Proto::Repeatable->new(@_);
}

=head2 pAlternation

Returns an alternation for use in validating lists. See L<Test::Proto::Altenration>.

=cut

sub pAlternation {
	return Test::Proto::Alternation->new(@_);
}

=head2 c

Returns a comparison (string,by default). See L<Test::Proto::Compare>.

=cut

sub c {
	return Test::Proto::Compare->new(@_);
}

=head2 cNumeric

Returns a numeric comparison. See L<Test::Proto::Compare::Numeric>.

=cut

sub cNumeric {
	return Test::Proto::Compare::Numeric->new(@_);
}

=head1 AUTHOR

Begun by Daniel Perrett, C<< <perrettdl at googlemail.com> >>

=head1 CONTRIBUTORS

Michael Schwern

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



=head1 LICENSE AND COPYRIGHT

Copyright 2012-2013 Daniel Perrett.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

return 1; # module loaded ok
