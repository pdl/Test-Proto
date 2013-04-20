#!perl -T
use strict;
use warnings;
use Test::More;
use Test::Proto::Common;

isa_ok (upgrade('a'), 'Test::Proto::Base', 'upgrade produces a prototype');
isa_ok (upgrade('a')->validate('a'), 'Test::Proto::TestRunner', 'upgrade produces a prototype that validates to produce a TestRunner');
ok (upgrade('a')->validate('a'), 'upgrade produces a prototype that validates \'a\' as \'a\'');
ok (!upgrade('a')->validate('b'), 'upgrade produces a prototype that validates \'b\' as \'a\' and gives a negative result');

done_testing();
