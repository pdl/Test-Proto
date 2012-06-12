#!perl -T
use Test::More;
use Test::Proto::Exception;
ok (1, 'ok is ok');

sub tpexception {Test::Proto::Exception->new(@_);}

ok (defined tpexception and ref tpexception and tpexception->isa('Test::Proto::Exception'), '->new() works ok');
is (tpexception('Out of turnips'), "\nTest Prototype Exception:\n\tOut of turnips", "->new('Out of turnips') stringifies ok");
is (tpexception('No broth')->because(tpexception('Out of turnips')), "\nTest Prototype Exception:\n\tNo broth\nBecause:\n\tOut of turnips", 'concatenation works ok');
is (tpexception('No broth',tpexception('Out of turnips')), "\nTest Prototype Exception:\n\tNo broth\nBecause:\n\tOut of turnips", 'concatenation on ->new works ok');
is (tpexception('No broth',1), 1, 'boolean true cuts past failure');
is (tpexception(tpexception('Out of turnips')), "\nTest Prototype Exception:\n\tOut of turnips", "Exception replaces exception, no unnecessary nesting");

done_testing;

