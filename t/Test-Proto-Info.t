#!perl -T
use strict;
use warnings;

use Test::More;
use Test::Proto::Info;
use Test::Proto::TestRunner;

ok (1, 'ok is ok');
my $runner = Test::Proto::TestRunner->new();
sub test_info { Test::Proto::Info->new($runner, @_) }

ok ref test_info, 'Test::Proto::Info returns an object';
isa_ok test_info, 'Test::Proto::Info', '... is an Info';
isa_ok test_info, 'Test::Proto::RunnerEvent', '... is a RunnerEvent';

ok test_info, '... is true';

is ((test_info() + 1), 2, '... returns 1 by default');

is test_info->is_result, 0, '... is not a result';
is test_info->is_info, 1, '... is info';

done_testing;

