#!perl -T
use strict;
use warnings;

use Test::More;
use Test::Proto::Pass;
use Test::Proto::TestRunner;
ok (1, 'ok is ok');
my $runner = Test::Proto::TestRunner->new();
sub test_pass { Test::Proto::Pass->new($runner, @_) }

ok ref test_pass;
is ref test_pass, 'Test::Proto::Pass';
ok test_pass->isa('Test::Proto::RunnerEvent');

ok test_pass;

is ((test_pass() + 1), 2, 'Pass returns 1 by default');

is test_pass->is_result, 1, 'Pass is a result';
is test_pass->is_info, 0, 'Pass is not info';

done_testing;

