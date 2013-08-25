use strict;
use warnings;
use Test::More;
use Test::Proto::Base;

sub p { Test::Proto::Base->new(); }

# test by visual inspection till I figure out something better
# this script also verifies that the code runs without dying.

p->num_gt(0)->num_lt(10)->ok(1);
# p->num_gt(0)->num_lt(10)->ok(11);

use Test::Proto::ArrayRef;
Test::Proto::ArrayRef->new->in_groups(2,[['a','b'],['c','d'],['e']])->ok(['a','b','c','d','e'], 'Because...');

done_testing;
