#!perl -T
use Test::More;
use Test::Proto::Compare;
sub pCmp {Test::Proto::Compare->new}
ok (1, 'ok is ok');
ok (defined pCmp, 'pCmp returns an object');
is ('aaa' cmp 'aab',-1, 'aaa cmp aab == -1');
is (pCmp->compare('aaa', 'aab'),-1, 'pCmp aaa aab == -1');

done_testing();
