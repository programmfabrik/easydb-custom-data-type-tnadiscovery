PLUGIN_NAME = custom-data-type-tnadiscovery
PLUGIN_PATH = easydb-custom-data-type-tnadiscovery

L10N_FILES = easydb-library/src/commons.l10n.csv \
    l10n/$(PLUGIN_NAME).csv
L10N_GOOGLE_KEY = 1ux8r_kpskdAwTaTjqrk92up5eyyILkpsv4k96QltmI0
L10N_GOOGLE_GID = 578343553

INSTALL_FILES = \
    $(WEB)/l10n/cultures.json \
    $(WEB)/l10n/de-DE.json \
    $(WEB)/l10n/en-US.json \
    $(JS) \
    $(CSS) \
    manifest.yml

COFFEE_FILES = easydb-library/src/commons.coffee \
    src/webfrontend/CustomDataTypeTNADiscovery.coffee

SCSS_FILES = src/webfrontend/css/main.scss

all: build

include easydb-library/tools/base-plugins.make

build: code css buildinfojson

code: $(JS) $(L10N)

clean: clean-base
