#!perl -T
use Test::More;
use Test::Proto qw(pHr pAr pSt);
ok (1, 'ok is ok');
ok (pHr, 'pHr returns an object');
pHr->ok({}, '{} is a hr');
pHr->is_a('HASH')->ok({}, '{} is a HASH ref');
pHr->is_also(pHr)->ok({}, '{} is really a hr');
pHr->is_defined->ok({}, '{} is defined');
pHr->keys(pAr)->ok({}, 'Can look at keys of {}');
pHr->keys(['a'])->ok({a=>1}, 'Keys of {a=>1} returns [\'a\']');
pHr->keys(pAr->is_empty)->ok({}, 'No keys of {}');
# pHr->keys(pAr->is_deeply(['a','c']))->ok({a=>'b',c=>4}, 'Can look at keys'); #sort/set/bag
pHr->key_value('a', pSt->is_eq('b'))->ok({a=>'b',c=>4}, 'Can test a particular key');
pHr->key_value('a', 'b')->ok({a=>'b',c=>4}, 'Can test a particular key and upgrade appropriately');
pHr->key_values({'a'=>'b', c=>4})->ok({a=>'b',c=>4}, 'Can test keys');


done_testing;

