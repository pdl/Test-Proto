#!perl -T
use strict;
use warnings;

use Test::More;
use Test::Proto::Pass;
use Test::Proto::TestRunner;

ok (1, 'ok is ok');
my $runner = Test::Proto::TestRunner->new();
sub test_pass { Test::Proto::Pass->new($runner, @_) }

ok ref test_pass, 'Test::Proto::Pass returns an object';
isa_ok test_pass, 'Test::Proto::Pass', '... is a Pass';
isa_ok test_pass, 'Test::Proto::RunnerEvent', '... is a RunnerEvent';

ok test_pass, '... is true';

is ((test_pass() + 1), 2, '... returns 1 by default');

is test_pass->is_result, 1, '... is a result';
is test_pass->is_info, 0, '... is not info';

done_testing;

