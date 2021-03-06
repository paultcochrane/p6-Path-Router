#!/usr/bin/perl6

use v6;

use Test;

use Path::Router;

{
    my $router = Path::Router.new;

    $router.add-route('/foo' =>
        defaults => { a => 'b', c => 'd', e => 'f' }
    );
    $router.add-route('/bar' =>
        defaults => { a => 'b', c => 'd' }
    );

    is($router.uri-for(a => 'b'), 'bar');
}

{
    my $router = Path::Router.new;

    $router.add-route('/bar' =>
        defaults => { a => 'b', c => 'd' }
    );
    $router.add-route('/foo' =>
        defaults => { a => 'b', c => 'd', e => 'f' }
    );

    is($router.uri-for(a => 'b'), 'bar');
}

{
    my $router = Path::Router.new;

    $router.add-route('/foo' =>
        defaults => { a => 'b', c => 'd', e => 'f' }
    );
    $router.add-route('/bar' =>
        defaults => { a => 'b', c => 'd', g => 'h' }
    );

    throws_like(
        { $router.uri-for(a => 'b', c => 'd') },
        X::Path::Router::AmbiguousMatch::ReverseMatch,
        "error when it's actually ambiguous",
        match-keys => *.sort.join(' ') eq 'a c',
        routes     => *.map(*.[0].path).sort.join(' ') eq '/bar /foo',
    );
}

{
    my $router = Path::Router.new;

    $router.add-route('/foo/:bar' => (defaults => { id => 1 }));
    $router.add-route('/foo/bar'  => (defaults => { id => 2 }));

    my $match = $router.match('/foo/bar');
    is($match.mapping.<id>, 2);
}

{
    my $router = Path::Router.new;

    $router.add-route('/foo/bar'  => (defaults => { id => 2 }));
    $router.add-route('/foo/:bar' => (defaults => { id => 1 }));

    my $match = $router.match('/foo/bar');
    is($match.mapping.<id>, 2);
}

{
    my $router = Path::Router.new;

    $router.add-route('/foo/:bar' => (defaults => { id => 1 }));
    $router.add-route('/:foo/bar' => (defaults => { id => 2 }));

    throws_like(
        { $router.match('/foo/bar') },
        X::Path::Router::AmbiguousMatch::PathMatch,
        "error when it's actually ambiguous",
        matches => *.map(*.route.path).sort.join(' ') eq '/:foo/bar /foo/:bar',
        path    => 'foo/bar',
    );
}

{
    my $router = Path::Router.new;

    $router.add-route('/foo/bar/?:baz' => (defaults => { id => 1 }));
    $router.add-route('/foo/:bar'      => (defaults => { id => 2 }));

    my $match = $router.match('/foo/bar');
    is($match.mapping.<id>, 1, "optional components don't matter");
}

{
    my $router = Path::Router.new;

    $router.add-route('/foo/:bar'      => (defaults => { id => 2 }));
    $router.add-route('/foo/bar/?:baz' => (defaults => { id => 1 }));

    my $match = $router.match('/foo/bar');
    is($match.mapping.<id>, 1, "optional components don't matter");
}

done;
