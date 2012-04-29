#!perl -T
use Test::More;
use Test::Proto qw(pSomething pHr pAr pSeries c cNum);


# Cursory checks

ok (1, 'ok is ok');
ok (pAr, 'pAr returns an object');
pAr->ok([], '[] is an ar');
pAr->is_a('ARRAY')->ok([], '[] is an ARRAY ref');
pAr->is_also(pAr)->ok([], '[] is really an ArrayRef');
pAr->is_deeply([])->ok([], '[] is deeply []');
pAr->is_deeply([1,2,3])->ok([1,2,3], '[1,2,3] is deeply [1,2,3]');
pAr->is_defined->ok([], '[] is defined');
pAr->is_empty->ok([], '[] is empty');


# 'Core' array features

pAr->grep(sub{return 1;}, ['a'])->ok(['a'], 'grep is ok with coderefs');
pAr->grep(pHr, [{}])->ok([{}], 'grep is ok with prototypes');
pAr->map(sub{shift; return ++$_;}, pAr->is_deeply([2,3,4]))->ok([1,2,3], 'map is ok');
pAr->range("0..1", pAr->is_deeply([1,2]))->ok([1,2,3], 'range is ok');
pAr->range("0..-1", pAr->is_deeply([1,2,3]))->ok([1,2,3], 'range of -1 is ok');
pAr->all(qr/^[abc]$/)->ok(['a','b','c'], 'all works');
pAr->first_match(sub {$_[0]>1},2)->ok([1,2,3], 'first_match works');
pAr->last_match(sub {$_[0]<3},2)->ok([1,2,3], 'last_match works');
pAr->enumerate([[0,'a'],[1,'b'],[2,'c']])->ok(['a','b','c'], 'enumerate works');



# Tests which use comparison functions, see Test::Proto::Compare.

pAr->sort(cNum,[1,2,3])->ok([3,1,2], 'pAr->sort');
pAr->sort(cNum->reverse,[3,2,1])->ok([3,1,2], 'pAr->sort with reverse');
pAr->schwartz(cNum, sub{return shift;}, [1,2,3])->ok([3,1,2], 'pAr->schwartz');
pAr->schwartz(c, sub{lc $_[0];}, ['A','b','C'])->ok(['C','A','b'], 'pAr->schwartz with lc');
pAr->uniq(cNum,[1,2,3])->ok([1,2,3,'3'], 'pAr->uniq');
ok(pAr->uniq(cNum,[1,2,3])->validate([1,2,3,4])==0, 'pAr->uniq fails correctly');
pAr->min(cNum,1)->ok([1,2,3], 'min works');
pAr->max(cNum,3)->ok([1,2,3], 'max works');


# Schematic validation features

pAr->contains_only([1,pSomething,3])->ok([1,2,3], 'contains_only is ok for serial lists');
ok(pAr->contains_only([1,pSomething,3])->validate([1,2,3,4])==0, 'contains_only fails if there are subsequent items');
ok(pAr->begins_with([1,pSomething,3])->validate([1,2,3,4])==1, 'begins_with does not fail if there are subsequent items');
pAr->contains_only([pSeries(1,pSomething,3)])->ok([1,2,3], 'contains_only is ok for simple pSeries');
pAr->contains_only([pSeries(pSeries(1,pSomething),3)])->ok([1,2,3], 'contains_only is ok for nested pSeries');
pAr->contains_only([pSeries(pSeries(1,2)->repeat(1,5),3)])->ok([1,2,1,2,3], 'contains_only is ok for nested pSeries with repeats');
pAr->reduce(sub{return $_[0]+$_[1];},6)->ok([1,2,3], 'reduce by addition: [1,2,3] = 6');
# pAr->has_at_least([1,2,3])->ok([1,2,3,3], 'pAr->has_at_least'); # set and bag I found confusing names. Use dedupe where appropriate.
# pAr->has_at_most([1,2,3])->ok([1,2], 'pAr->has_at_most');
# ok(pAr->has_at_most([1,2,3])->ok([1,2,3,4])==0, 'pAr->has_at_most fails correctly');
# ok(pAr->has_at_least([1,2,3])->ok([1,2])==0, 'pAr->has_at_least fails correctly');
# pAr->has_exactly([1,2,3])->ok([1,2], 'pAr->has_exactly'); # 
# pAr->after([2],[3,4,5])->ok([1,2,3,4,5], 'after works');
# pAr->after_include([2,3],[2,3,4,5])->ok([1,2,3,4,5], 'after_include works');
# pAr->before([4],[1,2,3])->ok([1,2,3,4,5], 'before works');
# pAr->before_include([3,4],[1,2,3,4])->ok([1,2,3,4,5], 'before_include works');


done_testing;

