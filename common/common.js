// This file is managed by the altered-wiki-src repository.
// Do not edit it directly on the wiki — changes will be overwritten on the next deploy.
// https://github.com/altered-wiki/altered-wiki-src

// Legal status table — live country filter
mw.hook( 'wikipage.content' ).add( function ( $content ) {
    $content.find( '.legal-status-search' ).each( function () {
        var $container = $( this );
        var $input = $( '<input>' ).attr( {
            type: 'text',
            placeholder: 'Search countries…',
            'aria-label': 'Filter legal status table'
        } ).addClass( 'legal-status-search__input' );

        $container.prepend( $input );

        $input.on( 'input', function () {
            var q = this.value.toLowerCase();
            $container.find( '.legal-status-table tr' ).each( function () {
                var cell = $( this ).find( '.legal-status-table__country' );
                $( this ).toggle( cell.length === 0 || cell.text().toLowerCase().indexOf( q ) !== -1 );
            } );
        } );
    } );
} );
