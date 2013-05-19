requires 'List::MoreUtils';
requires 'Net::CIDR::Lite';
requires 'Plack', '0.9941';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.36';
    requires 'Test::More';
};
