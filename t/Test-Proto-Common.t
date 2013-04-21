#!perl -T
use strict;
use warnings;
use Test::More;
use Test::Proto::Common;
use Test::Proto::Base;

foreach my $upg (
		[Test::Proto::Base->new()->eq('a'), "Raw prototype"],
		[upgrade('a'), "Upgraded string"],
		[upgrade(qr/^a$/), "Upgraded regex"],
		[upgrade(sub{ $_[0] eq 'a' }), "Upgraded coderef"],
		[upgrade(Test::Proto::Base->new()->eq('a')), "Upgraded prototype"]
	) {
	my $upg_result = $upg->[0];
	my $upg_text = $upg->[1];
	isa_ok ($upg_result, 'Test::Proto::Base', $upg_text.' produces a prototype');
	isa_ok ($upg_result->validate('a'), 'Test::Proto::TestRunner', $upg_text.' produces a prototype that validates to produce a TestRunner');
	ok ($upg_result->validate('a'), $upg_text.' produces a prototype that validates \'a\' as \'a\'');
	ok (!$upg_result->validate('b'), $upg_text.' produces a prototype that validates \'b\' as \'a\' and gives a negative result');
}

done_testing();
