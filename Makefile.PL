use inc::Module::Install;

name     'HTML-FormFu-Model-LDAP';
all_from 'lib/HTML/FormFu/Model/LDAP.pm';
author   'Andreas Marienborg <andreas@startsiden.no>';

build_requires 'Test::More';
requires 'Encode';
requires 'Net::LDAP';
requires 'Net::LDAP::Server::Test';
requires 'HTML::FormFu' => '0.02005';
auto_install;

WriteAll;

