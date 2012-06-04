#!perl -T
use Test::More;
use Test::Proto qw(p);

# TODO: All test scripts should consider not eating own dogfood.

ok (1, 'ok is ok');
ok (p, 'p returns an object');
my $to_clone = p->is_like(qr/\.net$/);
is_deeply($to_clone->clone, $to_clone, 'cloning works');
ok (p->as_string(qr/ARRAY/)->ok([]), 'as_string is ok');
ok (p->as_bool(1)->ok('2'), 'as_bool is ok');
ok (p->as_number(2)->ok(' 2 '), 'as_number is ok');

done_testing;

