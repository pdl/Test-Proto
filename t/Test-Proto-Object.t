#!perl -T
use Test::More;
use Test::Proto qw(pOb);
use Data::Dumper;
ok(1, 'ok is ok');
my $dumper = Data::Dumper->new([{'a'=>1}]); # Because Data::Dumper is a core module with an OO interface, we can rely on its presence to test Test::Proto::Object.

pOb->ok($dumper, '$dumper is an object');
pOb->is_a('Data::Dumper')->ok($dumper, '$dumper is a Data::Dumper');
pOb->can('Dump')->ok($dumper);
warn (Dumper [] );
pOb->try_can('Dump',[], "{'a' => 1}")->ok($dumper); 
# 
done_testing;
