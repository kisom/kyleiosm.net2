TARGET = port.tyrfingr.is:site/

all: build

.PHONY: build
build:
	find . -name \*.pm -exec raco pollen render '{}' \;
	find . -name \*.pmd -exec raco pollen render '{}' \;

.PHONY: install
install:
	rsync --progress -auvz --exclude-from excludes . $(TARGET)

.PHONY: deploy
deploy: build install

.PHONY: serve
serve:
	raco pollen start

.PHONY: clean
clean:
	find . -perm /a+w -name \*.html -exec rm '{}' \;
