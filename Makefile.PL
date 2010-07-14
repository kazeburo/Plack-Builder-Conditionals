use inc::Module::Install;
name 'Plack-Builder-Conditions';
all_from 'lib/Plack/Builder/Conditions.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
