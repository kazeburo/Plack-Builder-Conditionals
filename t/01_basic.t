use strict;
use Test::More tests => 19;

use Plack::Builder::Conditionals;

ok( addr('192.168.2.0/24')->({ REMOTE_ADDR => '192.168.2.1' }) );
ok( addr(['192.168.2.0/24','127.0.0.1'])->({ REMOTE_ADDR => '192.168.2.1' }) );
ok( addr('!',['192.168.3.0/24'])->({ REMOTE_ADDR => '192.168.2.1' }) );

ok( path('/')->({ PATH_INFO => '/' }) );
ok( ! path('/')->() );
ok( ! path('/foo')->({ PATH_INFO => '/' }) );
ok( path(qr!^/foo!)->({ PATH_INFO => '/foo/bar' }) );
ok( path('!', qr!^/foo!)->({ PATH_INFO => '/baz/bar' }) );

ok( method()->({ REQUEST_METHOD => 'GET' }) );
ok( method('GET')->({ REQUEST_METHOD => 'GET' }) );
ok( method('get')->({ REQUEST_METHOD => 'GET' }) );
ok( method('!','post')->({ REQUEST_METHOD => 'GET' }) );
ok( method(qr/^(get|head)$/)->({ REQUEST_METHOD => 'GET' }) );
ok( method('!',qr/^(post|put)$/)->({ REQUEST_METHOD => 'GET' }) );

ok( header('X-Foo')->({  HTTP_X_FOO => '100' }) );
ok( ! header('X-Foo')->({  HTTP_X_BAA => '100' }) );
ok( header('X-Foo','100')->({  HTTP_X_FOO => '100' }) );
ok( header('X-Foo', '!', '100')->({  HTTP_X_BAA => '100' }) );
ok( header('X-Foo',qr/\d+/)->({  HTTP_X_FOO => '100' }) );
