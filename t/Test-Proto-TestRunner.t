#!perl -T
use strict;
use warnings;

use Test::More;
use Test::Proto::TestRunner;
ok (1, 'ok is ok');
sub runner { Test::Proto::TestRunner->new(@_) };

ok runner->test_fail()->isa('Test::Proto::Fail');
ok runner->test_pass()->isa('Test::Proto::Pass');
ok runner->test_diag()->isa('Test::Proto::Diag');
ok runner->test_note()->isa('Test::Proto::Diag');

# runner->test_location();
done_testing;

