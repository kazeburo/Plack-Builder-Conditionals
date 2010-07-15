use inc::Module::Install;
name 'Plack-Builder-Conditions';
all_from 'lib/Plack/Builder/Conditions.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

requires 'Plack', 0.9941;
requires 'Net::CIDR::Lite';
requires 'List::MoreUtils';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
