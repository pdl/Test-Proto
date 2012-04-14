#!perl -T
use Test::More;
use Test::Proto qw(pSomething pHr pAr pSeries);
ok (1, 'ok is ok');
ok (pAr, 'pAr returns an object');
pAr->ok([], '[] is an ar');
pAr->is_a('ARRAY')->ok([], '[] is an ARRAY ref');
pAr->is_also(pAr)->ok([], '[] is really an ArrayRef');
pAr->is_deeply([])->ok([], '[] is deeply []');
pAr->is_deeply([1,2,3])->ok([1,2,3], '[] is deeply []');
pAr->is_defined->ok([], '[] is defined');
pAr->is_empty->ok([], '[] is empty');
pAr->is_empty->ok([], '[] is empty');
pAr->grep(sub{return 1;}, pAr)->ok(['a'], 'grep is ok');
pAr->map(sub{shift; return ++$_;}, pAr->is_deeply([2,3,4]))->ok([1,2,3], 'map is ok');
pAr->range("0..-1", pAr->is_deeply([1,2,3]))->ok([1,2,3], 'range is ok');
pAr->contains_only([1,pSomething,3])->ok([1,2,3], 'contains_only is ok for serial lists');
pAr->contains_only([pSeries(1,pSomething,3)])->ok([1,2,3], 'contains_only is ok for simple pSeries');
pAr->contains_only([pSeries(pSeries(1,pSomething),3)])->ok([1,2,3], 'contains_only is ok for nested pSeries');


done_testing;

