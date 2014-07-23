TARGET = tyrfingr.is:/var/www/sites/kyleisom/

all: build

.PHONY: build
build:
	raco pollen render *.pm
	raco pollen render articles/*.pm

.PHONY: install
install:
	rsync -auvz --exclude-from excludes . $(TARGET)

.PHONY: deploy
deploy: build install

.PHONY: clean
clean:
	find . -perm /a+w -name \*.html -exec rm '{}' \;
