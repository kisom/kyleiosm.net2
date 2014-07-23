TARGET = tyrfingr.is:/var/www/sites/kyleisom/

all: build

.PHONY: build
build:
	raco pollen render
	raco pollen render articles/

.PHONY: install
install:
	rsync -auvz --exclude-from excludes

.PHONY: deploy
deploy: build install

.PHONY: clean
clean:
	find . -name \*.html -exec rm '{}' \;
