#!perl -T
use Test::More;
use Test::Proto qw(pHr pAr);
ok (1, 'ok is ok');
ok (pAr, 'pAr returns an object');
pHr->ok([], '[] is an ar');
pHr->is_a('ARRAY')->ok([], '[] is an ARRAY ref');
pHr->is_also(pAr)->ok([], '[] is really a ar');
pHr->is_defined->ok([], '[] is defined');
pAr->is_empty->ok([], '[] is empty');
pAr->is_empty->ok([], '[] is empty');
pAr->grep(sub{return 1;}, pAr)->ok(['a'], 'grep is ok');


done_testing;

