#!perl -T
use Test::More;
use Test::Proto qw(pCr);

# TODO: All test scripts should consider not eating own dogfood.

ok (1, 'ok is ok');
ok (pCr, 'pCr returns an object');
pCr->ok(sub{}, 'sub{} is a code ref');
pCr->try_run([], 42)->ok(sub{return 42}, 'sub{return 42} returns 42');
pCr->try_run([42], 42)->ok(sub{return $_[0]}, 'sub{return $_[0]} returns $_[0]');

done_testing;

