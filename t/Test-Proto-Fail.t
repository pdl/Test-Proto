#!perl -T
use Test::More;
use Test::Proto::Fail;
ok (1, 'ok is ok');

sub tpfail {Test::Proto::Fail->new(@_);}

ok (defined tpfail and ref tpfail and tpfail->isa('Test::Proto::Fail'), '->new() works ok');
is (tpfail('Out of turnips'), "\nTest Prototype Failure:\n\tOut of turnips", "->new('Out of turnips') stringifies ok");
is (tpfail('No broth')->because(tpfail('Out of turnips')), "\nTest Prototype Failure:\n\tNo broth\nBecause:\n\tOut of turnips", 'concatenation works ok');
is (tpfail('No broth',tpfail('Out of turnips')), "\nTest Prototype Failure:\n\tNo broth\nBecause:\n\tOut of turnips", 'concatenation on ->new works ok');
is (tpfail('No broth',1), 1, 'boolean true cuts past failure');
is (tpfail(tpfail('Out of turnips')), "\nTest Prototype Failure:\n\tOut of turnips", "Fail replaces fail, no unnecessary nesting");

done_testing;

