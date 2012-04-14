#!perl -T
use Test::More;
use Test::Proto qw(pSomething);

# TODO: All test scripts should consider not eating own dogfood.

ok (1, 'ok is ok');
ok (pSomething, 'pSomething returns an object');
my $to_clone = pSomething->is_like(qr/\.net$/);
is_deeply($to_clone->clone, $to_clone, 'cloning works');

done_testing;

