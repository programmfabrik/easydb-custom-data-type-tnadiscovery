# easydb-custom-data-type-tnadiscovery
Custom Data Type "TNADiscovery" for easydb

This is a plugin for [easyDB 5](http://5.easydb.de/) with Custom Data Type `CustomDataTypeTNADiscovery` for references to entities of the [Nationalarchives-Discovery-System](<http://discovery.nationalarchives.gov.uk/>).

The Plugins uses <http://discovery.nationalarchives.gov.uk/API/> for the autocomplete-suggestions and additional informations about Nationalarchives-entities.

## configuration

There is no custom configuration yet.

## saved data
* conceptName
    * Preferred label of the linked record
* conceptURI
    * URI to linked record
* discoveryID
    * ID in discovery-system
* discoveryURL
    * URL in discovery-system
* referenceNumber
* locationHeld
* title
* description
* _fulltext
    * easydb-fulltext
* _standard
    * easydb-standard

## sources

The source code of this plugin is managed in a git repository at <https://github.com/programmfabrik/easydb-custom-data-type-tnadiscovery>. Please use [the issue tracker](https://github.com/programmfabrik/easydb-custom-data-type-tnadiscovery/issues) for bug reports and feature requests!



