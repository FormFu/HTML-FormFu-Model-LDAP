use Test::More tests => 6;

use HTML::FormFu;
use HTML::FormFu::Model::LDAP;

use Net::LDAP::Server::Test;
use Net::LDAP;

# Starting a LDAP test server
ok( my $server = Net::LDAP::Server::Test->new(8080), "LDAP server spawned" );
ok( my $ldap = Net::LDAP->new( 'localhost', port => 8080 ),"new connection" );

# Getting one entry
$res = $ldap->search( base => '', filter => '(sn=value1)');
ok($res->{resultCode} == 0, "Result code is 0");
my $e = $res->entry(1);

# Creating a FormFu form
my $form = HTML::FormFu->new;
$form->load_config_file('t/form.yml');

# Populating with LDAP values, and checking result
$form->model->default_values( $e );
my $elm = $form->get_element({name => 'sn'});
is ($elm->value, "value1", "sn has value: value1");
$elm = $form->get_element({name => 'cn'});
is ($elm->value, "value1", "cn has value: value1");

# Disconnect
ok($ldap->unbind(), "LDAP server unbound");
