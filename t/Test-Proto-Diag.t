#!perl -T
use strict;
use warnings;

use Test::More;
use Test::Proto::Diag;
use Test::Proto::TestRunner;

ok (1, 'ok is ok');
my $runner = Test::Proto::TestRunner->new();
sub test_diag { Test::Proto::Diag->new($runner, @_) }

ok ref test_diag, 'Test::Proto::Diag returns an object';
isa_ok test_diag, 'Test::Proto::Diag', '... is a Diag';
isa_ok test_diag, 'Test::Proto::RunnerEvent', '... is a RunnerEvent';

ok test_diag, '... is true';

is ((test_diag() + 1), 2, '... returns 1 by default');

is test_diag->is_result, 0, '... is not a result';
is test_diag->is_info, 1, '... is info';

done_testing;

