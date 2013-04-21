package Test::Proto::Formatter::TestBuilder;
use 5.006;
use strict;
use warnings;
use Moo;
extends 'Test::Builder::Module';
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

has '_object_id_register',
	is=> 'rw',
	default => sub { {} };

sub event {
	my $self = shift;
	my $runner = shift;
	my $eventType = shift;
	if ('new' eq $eventType) {
		if (defined $runner->parent){
			$self->_object_id_register->{$runner->object_id} = $self->_object_id_register->{$runner->parent->object_id}->child;
		}
		else {
			$self->_object_id_register->{$runner->object_id} = $CLASS->builder->child;
		}
	}
	elsif ('done' eq $eventType) {
		if ( my $tb = $self->_object_id_register->{$runner->object_id} ){
			$tb->ok($runner, $runner->status . (defined $runner->status_message ?  ': '. $runner->status_message : '') );
			$tb->done_testing;
			$tb->finalize;
		}
		else {
			die ('Have not registered object '. $runner->object_id );
		}
	}
	return $self;
}

sub format {
	my $self = shift;
	my $runner = shift;
	return $self;
}


1;


=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut


