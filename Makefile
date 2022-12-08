PLUGIN_NAME = custom-data-type-tnadiscovery
PLUGIN_PATH = easydb-custom-data-type-tnadiscovery

L10N_FILES = easydb-library/src/commons.l10n.csv \
    l10n/$(PLUGIN_NAME).csv

INSTALL_FILES = \
    $(WEB)/l10n/cultures.json \
    $(WEB)/l10n/de-DE.json \
    $(WEB)/l10n/en-US.json \
    $(JS) \
    $(CSS) \
    manifest.yml

COFFEE_FILES = easydb-library/src/commons.coffee \
    src/webfrontend/CustomDataTypeTNADiscovery.coffee

CSS_FILE = src/webfrontend/css/main.css

all: build

include easydb-library/tools/base-plugins.make

build: code buildinfojson

code: $(JS) $(L10N)
	    cat $(CSS_FILE) >> build/webfrontend/custom-data-type-tnadiscovery.css

clean: clean-base
