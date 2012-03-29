#!perl -T
use Test::More;
use Test::Proto qw(pHr pAr);
ok (1, 'ok is ok');
ok (pHr, 'pHr returns an object');
pHr->ok({}, '{} is a hr');
pHr->is_a('HASH')->ok({}, '{} is a HASH ref');
pHr->is_also(pHr)->ok({}, '{} is really a hr');
pHr->is_defined->ok({}, '{} is defined');
pHr->keys(pAr)->ok({}, 'Can look at keys of {}');
pHr->keys(pAr->is_empty)->ok({}, 'Can look at keys of {}');


done_testing;

