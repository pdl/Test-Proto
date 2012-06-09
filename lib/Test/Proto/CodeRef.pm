package Test::Proto::CodeRef;
use 5.006;
use strict;
use warnings;
use base 'Test::Proto::Base';

sub initialise
{
	my ($self) = @_;
	$self->is_defined;
	$self->is_a('CODE');
}

sub try_run
{
	my ($self, $args, $expected, $why) = @_;
	$self->add_test(_try_run($args, $self->upgrade($expected)), $why);
}

sub _try_run
{
	my ($args, $expected) = @_;
	return sub{
		my $got = shift;
		my $result;
		eval { $result = $expected->validate(&{$got}(@$args)); };
		return $result if defined $result;
		return exception ($@) if $@;
	}
}

return 1; # module loaded ok

=pod

=head1 NAME

Test::Proto::CodeRef - Test Prototype for CodeRefs.

=head1 SYNOPSIS

	Test::Proto::CodeRef->new->ok(sub{}); # ok
	Test::Proto::CodeRef->new->ok(undef); # not ok

This is a test prototype which requires that the value it is given is defined and is a a CodeRef. In addition to methods inherited from L<Test::Proto::Base>, it provides the C<try_run> method.

=head1 METHODS

=head3 try_run

	pCr->try_run([42], 43)->ok(sub{return $_[0]+1;});

Passes the contents of the first arrayref as arguments to the coderef, evaluating it in scalar context and comparing it to the second value (which will be upgraded). 

=head1 OTHER INFORMATION

For author, version, bug reports, support, etc, please see L<Test::Proto>. 

=cut

