TARGET = tyrfingr.is:/var/www/sites/kyleisom/

all: build

.PHONY: build
build:
	raco pollen render
	raco pollen render articles/
	raco pollen render projects/
	raco pollen render projects/*/

.PHONY: install
install:
	rsync -auvz --exclude-from excludes . $(TARGET)

.PHONY: deploy
deploy: build install

.PHONY: serve
serve:
	raco pollen start

.PHONY: clean
clean:
	find . -perm /a+w -name \*.html -exec rm '{}' \;
