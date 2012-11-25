#!perl -T
use strict;
use warnings;

use Test::More;
use Test::Proto::TestRunner;
ok (1, 'ok is ok');
sub runner { Test::Proto::TestRunner->new(@_) };

ok runner->test_fail()->isa('Test::Proto::Fail'), 'runner->test_fail() returns the correct sort of object';
ok runner->test_pass()->isa('Test::Proto::Pass'), 'runner->test_pass() returns the correct sort of object';
ok runner->test_diag()->isa('Test::Proto::Diag'), 'runner->test_fail() returns the correct sort of object';
ok runner->test_note()->isa('Test::Proto::Diag'), 'runner->test_note() returns the correct sort of object';

my $pass_runner = runner;
$pass_runner->test_pass();
ok($pass_runner, 'A runner with a pass passes');
my $fail_runner = runner;
$fail_runner->test_fail();
ok(!$fail_runner, 'A runner with a fail fails');
$fail_runner->test_pass();
ok(!$fail_runner, 'A runner with a fail then a pass still fails');

# runner->test_location();
done_testing;

