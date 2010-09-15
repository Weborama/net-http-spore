use strict;
use warnings;

use Test::More;
use XML::Simple;

use Net::HTTP::Spore;

my $content = { keys => [qw/1 2 3/] };

my $mock_server = {
    '/test_spore/_all_docs' => sub {
        my $req = shift;
        $req->new_response( 200, [ 'Content-Type' => 'text/xml' ],
            XMLout($content) );
    },
};

ok my $client =
  Net::HTTP::Spore->new_from_spec( 't/specs/couchdb.json',
    api_base_url => 'http://localhost:5984' );

$client->enable('Format::XML');
$client->enable( 'Mock', tests => $mock_server );

my $res = $client->get_all_documents( database => 'test_spore' );
is $res->[0],        200;
is_deeply $res->[2], $content;
is $res->header('Content-Type'), 'text/xml';

my $req = $res->request;
is $req->header('Accept'), 'text/xml';

done_testing;
