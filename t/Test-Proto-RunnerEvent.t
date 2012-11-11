#!perl -T
use strict;
use warnings;

use Test::More;
use Test::Proto::RunnerEvent;
ok (1, 'ok is ok');

sub event { Test::Proto::RunnerEvent->new(@_) }

ok ref event;
is ref event, 'Test::Proto::RunnerEvent';

ok event;

is ((event() + 1), 2, 'RunnerEvent returns 1 by default');

is event.'', 'Undefined event';

is event->is_result, 0;
is event->is_info, 0;

done_testing;

