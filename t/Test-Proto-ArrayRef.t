#!perl -T
use Test::More;
use Test::Proto qw(pSomething pHr pAr pSeries);
ok (1, 'ok is ok');
ok (pAr, 'pAr returns an object');
pAr->ok([], '[] is an ar');
pAr->is_a('ARRAY')->ok([], '[] is an ARRAY ref');
pAr->is_also(pAr)->ok([], '[] is really an ArrayRef');
pAr->is_deeply([])->ok([], '[] is deeply []');
pAr->is_deeply([1,2,3])->ok([1,2,3], '[1,2,3] is deeply [1,2,3]');
pAr->is_defined->ok([], '[] is defined');
pAr->is_empty->ok([], '[] is empty');
pAr->grep(sub{return 1;}, ['a'])->ok(['a'], 'grep is ok');
pAr->map(sub{shift; return ++$_;}, pAr->is_deeply([2,3,4]))->ok([1,2,3], 'map is ok');
pAr->range("0..1", pAr->is_deeply([1,2]))->ok([1,2,3], 'range is ok');
pAr->range("0..-1", pAr->is_deeply([1,2,3]))->ok([1,2,3], 'range of -1 is ok');
pAr->contains_only([1,pSomething,3])->ok([1,2,3], 'contains_only is ok for serial lists');
ok(pAr->contains_only([1,pSomething,3])->validate([1,2,3,4])==0, 'contains_only fails if there are subsequent items');
ok(pAr->begins_with([1,pSomething,3])->validate([1,2,3,4])==1, 'begins_with does not fail if there are subsequent items');
pAr->contains_only([pSeries(1,pSomething,3)])->ok([1,2,3], 'contains_only is ok for simple pSeries');
pAr->contains_only([pSeries(pSeries(1,pSomething),3)])->ok([1,2,3], 'contains_only is ok for nested pSeries');
pAr->contains_only([pSeries(pSeries(1,2)->repeat(1,5),3)])->ok([1,2,1,2,3], 'contains_only is ok for nested pSeries with repeats');
pAr->reduce(sub{return $_[0]+$_[1];},6)->ok([1,2,3], 'reduce by addition: [1,2,3] = 6');
# pAr->dedupe(cNum,[1,2,3])->ok([1,2,3,'3'], 'pAr->dedupe');
# pAr->has_at_least([1,2,3])->ok([1,2,3,3], 'pAr->has_at_least'); # set and bag I found confusing names. Use dedupe where appropriate.
# pAr->has_at_most([1,2,3])->ok([1,2], 'pAr->has_at_most'); 
# pAr->has_exactly([1,2,3])->ok([1,2], 'pAr->has_at_most'); 
# pAr->sort(cNum,[1,2,3])->ok([3,1,2], 'pAr->sort');
# pAr->sort(cNum->reverse,[3,2,1])->ok([3,1,2], 'pAr->sort with reverse');
# pAr->schwartz(cStr, sub{lc $_[0]}, ['A','b','C'])->ok(['C','A','b'], 'pAr->schwartz');

done_testing;

