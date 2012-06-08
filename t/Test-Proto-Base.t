#!perl -T
use Test::More;
use Test::Proto qw(p);

# TODO: All test scripts should consider not eating own dogfood.

ok (1, 'ok is ok');
ok (p, 'p returns an object');
p->ok('a', 'p can ok');
p->is_a('SCALAR')->ok('a', '"a" is_a STRING');
p->is_also(p)->ok('a', '"a" p and is_also p');
ok(p->validate('a'), 'p->validate works');
p->is_defined->ok('a', '"a" is defined');
# upgrading sub{}, qr//, []. {} not working at the moment
p->is_also(sub{$_[0] eq 'a'})->ok('a', 'can upgrade subs');
p->is_also(qr/^[a-z]$/)->ok('a', 'can upgrade qr//');
p->is_also(['a'])->ok(['a'], 'can upgrade arrayrefs');
ok(p->is_also({'a'=>1})->validate({'a'=>1}), 'can upgrade hashrefs');
my $to_clone = p->is_like(qr/\.net$/);
is_deeply($to_clone->clone, $to_clone, 'cloning works');
ok (p->as_string(qr/ARRAY/)->ok([]), 'as_string is ok');
ok (p->as_bool(1)->ok('2'), 'as_bool is ok');
ok (p->as_number(2)->ok(' 2 '), 'as_number is ok');

done_testing;

