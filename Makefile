.PHONY: clean clean-all watch open

CLEAVER:=node_modules/cleaver/bin/cleaver
CLEAVER_OPTS:=

all: slides.html

node_modules:
	npm install

slides.html: node_modules slides.md
	$(CLEAVER) $(CLEAVER_OPTS) slides.md

open: slides.html
	xdg-open $<

watch: slides.md
	$(CLEAVER) watch slides.md &> cleaver.log &
	
clean:
	rm slides.html

clean-all: clean
	rm -rf node_modules
