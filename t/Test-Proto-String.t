#!perl -T
use Test::More;
use Test::Proto qw(pSt);
ok (1, 'ok is ok');
ok (pSt, 'pSt returns an object');
pSt->ok('a', '"a" is a string');
pSt->is_a('SCALAR')->ok('a', '"a" is a scalar string');
pSt->is_also(pSt)->ok('a', '"a" is really a string');
ok(pSt->validate('a'), 'pSt->validate works');
pSt->is_defined->ok('a', '"a" is defined');
pSt->is_eq('a')->ok('a', '"a" eq "a"');
pSt->is_eq('a')->is_ne('b')->ok('a', '"a" eq "a" ne "b"');
pSt->is_like(qr/a+/)->ok('a' , 'a is like /a+/');
pSt->is_unlike(qr/a+/)->ok('b' , 'b is not like /a+/');

done_testing;

