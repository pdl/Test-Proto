#!perl -T
use strict;
use warnings;

use Test::More;
use Data::Dumper;
use Test::Proto::TestRunner2;

sub ok_or_dump {
	ok($_[0], $_[1]);
	unless ($_[0]){
		diag (Dumper( $_[0]));
	}	
}
sub not_ok_or_dump {
	ok(!$_[0], $_[1]);
	if ($_[0]){
		diag (Dumper( $_[0]));
	}	
}
ok (1, 'ok is ok');
sub runner { Test::Proto::TestRunner2->new( @_) };

ok (!defined (runner->parent), 'Default runner parent is undefined');

ok_or_dump (runner->pass, 'Passing runner passes');
is (runner->pass->value, 1, 'Passing runner has value 1');
not_ok_or_dump (runner->fail, 'Failing runner fails');
ok_or_dump (runner->diag, 'Diagnostic runner passes');
ok_or_dump (runner->skip, 'Skipping runner passes');
not_ok_or_dump (runner->exception, 'Exception runner fails');

not_ok_or_dump (runner, 'New runner fails');
ok_or_dump (runner->done, 'Empty done runner passes');
not_ok_or_dump (runner->add_event(runner->pass), 'Incomplete runner with pass fails');
ok_or_dump (runner->add_event(runner->pass)->done, 'Complete runner with pass passes');
not_ok_or_dump (runner->add_event(runner->fail)->done, 'Complete runner with fail fails');
not_ok_or_dump (runner->add_event(runner->fail)->add_event(runner->pass)->done, 'Complete runner with pass and fail fails');


done_testing;

