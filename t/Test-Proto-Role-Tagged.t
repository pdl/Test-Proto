use Test::More;

use Test::Proto::Base;
use Test::Proto::TestCase;

sub tc {Test::Proto::TestCase->new(@_)}

my $obj = tc;

# tags attribute
can_ok($obj, 'tags');
is_deeply( $obj->tags, [], 'tags begins as []');
is( $obj->has_tag('nope'), 0, 'Tags begins as []');

# add_tag
can_ok($obj, 'add_tag');
isa_ok($obj->add_tag('yep'), ref $obj, 'add_tag returns the object');
ok($obj->has_tag('yep'), 'add_tag does indeed add the tag');
ok(!$obj->has_tag('nope'), 'add_tag does not add any other tag');
ok(!$obj->has_tag('YEP'), 'add_tag is case sensitive');
is_deeply($obj->tags, ['yep']);

# remove_tag
can_ok($obj, 'remove_tag');
isa_ok($obj->remove_tag('yep'), ref $obj, 'remove_tag returns the object');
is_deeply($obj->tags, [], 'remove_tag does indeed remove the tag');

done_testing();
