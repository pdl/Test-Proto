package Test::Proto::Formatter;
use 5.006;
use strict;
use warnings;
use Moo;
use base 'Test::Builder::Module';
my $CLASS= __PACKAGE__;

=pod

=head1 NAME

Test::Proto::Formatter - handles output, formatting of RunnerEvents.

=head1 SYNOPSIS

	my $formatter = Test::Proto::Formatter->new();
	$formatter->begin($testRunner); #? -> current_state?
	$formatter->format($_) foreach @runnerEvents; # no, this doesn't look right
	$formatter->end($testRunner);

The formatter is only used by the L<Test::Proto::TestRunner> class. There is no reason to call it anywhere else. However, if you are writing a test script you might want to write your own formatter to give it to the TestRunner. 

This minimal formatter does precisely nothing.

=head1 METHODS

=cut

sub event {
	my $self = shift;
	my $target = shift;
	my $eventType = shift;
	if ('new' eq $eventType) {
		# ...
	}
	elsif ('done' eq $eventType) {
		# ...
	}
	return $self;
}

sub format {
	my $self = shift;
	my $target = shift;
	return $self;
}


1;


=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut


