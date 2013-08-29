package Test::Proto::TestCase;
use 5.006;
use strict;
use warnings;
use Moo;
with('Test::Proto::Role::Tagged');

=head1 NAME

Test::Proto::TestCase - an individual test case

=head1 SYNOPSIS


Note that it is a Moo class.

Unless otherwise specified, the return value is itself.

=cut

=head2 ATTRIBUTES

=cut

=head3 name

Returns the name of the test.

=cut

has 'name' => default => sub { '[Anonymous Test Case]' },
	is     => 'rw';

=head3 code

Returns the code.

=cut

has 'code' => is => 'rw';

=head3 data

Returns the data.

=cut

has 'data'  => is  => 'rw',
	default => sub { {}; };

1;
