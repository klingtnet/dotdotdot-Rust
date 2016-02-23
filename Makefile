.PHONY: clean clean-all watch open upload

REVEAL_VER:=3.2.0
PANDOC_OPTS:=--standalone\
	--mathjax\
	--variable theme:white\
	--variable transition:slide\
	--variable fragments:false\
	--variable transitionSpeed:fast\
	--variable history\
	--incremental\
	--to revealjs

all: slides.html

reveal.js:
	curl -Ls "https://github.com/hakimel/reveal.js/archive/$(REVEAL_VER).tar.gz" | tar -xvzf -
	ln -sf reveal.js-$(REVEAL_VER) reveal.js

slides.html: reveal.js slides.md
	pandoc $(PANDOC_OPTS) slides.md --output $@

open: slides.html
	xdg-open $<

publish: PANDOC_OPTS += --self-contained
publish: clean slides.html upload

upload: slides.html
	scp $< kn:/var/www/sites/files.klingt.net/slides/dotdotdot-Rust.html

clean:
	rm -f slides.html

clean-all: clean
	rm -rf reveal.js reveal.js-$(REVEAL_VER)
