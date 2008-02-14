use inc::Module::Install;

name     'HTML-FormFu-Model-LDAP';
all_from 'lib/HTML/FormFu/Model/LDAP.pm';
author   'Andreas Marienborg <andreas@startsiden.no>';

build_requires 'Test::More';
requires 'Net::LDAP';
requires 'HTML::FormFu' => '0.02000';
auto_install;

WriteAll;

