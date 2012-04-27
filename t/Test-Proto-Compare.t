#!perl -T
use Test::More;
use Test::Proto  qw(c cNum);
use Test::Proto::Compare;
ok (1, 'ok is ok');
ok (defined c, 'c returns an object');
is ('aaa' cmp 'aab',-1, 'aaa cmp aab == -1');
is (c->compare('aaa', 'aab'),-1, 'c aaa aab == -1');
is (c->reverse->compare('aaa', 'aab'),1, 'c->reverse aaa aab == 1');
is (c->reverse->reverse->compare('aaa', 'aab'),-1, 'c->reverse->->reverse aaa aab == -1');
is (0 <=> 1,-1, '0 <=> 1 == -1');
is (cNum->compare(0, 1),-1, 'cNum 0 1 == -1');
is (cNum->reverse->compare(0, 1),1, 'cNum->reverse 0 1 == 1');
done_testing();
