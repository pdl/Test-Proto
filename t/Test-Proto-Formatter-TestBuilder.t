#!perl -T
use strict;
use warnings;
use Test::More;
use Test::Proto::Base;

sub p { Test::Proto::Base->new(); }

p->num_gt(0)->num_lt(10)->ok(1);
#p->num_gt(0)->num_lt(10)->ok(11);

done_testing;
