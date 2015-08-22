# Content

AUTHOR_NAME = "Rafael G. Martins"
AUTHOR_EMAIL = "rafael@rafaelmartins.eng.br"
SITE_TITLE = "blogc"
SITE_TAGLINE = "A blog compiler."
LOCALE = "en_US.utf-8"

POSTS_PER_PAGE = 4
POSTS_PER_PAGE_ATOM = 10

POSTS = \
	hello-world \
	$(NULL)

PAGES = \
	$(NULL)

ASSETS = \
	assets/custom.css \
	$(NULL)

MANPAGES = \
	blogc.1 \
	blogc-source.7 \
	blogc-template.7 \
	$(NULL)


# Arguments

BLOGC ?= $(shell which blogc)
INSTALL ?= $(shell which install)
RONN ?= $(shell which ronn)
GIT ?= $(shell which git)
GITHUB_PAGES_PUBLISH ?= $(shell which github-pages-publish)
OUTPUT_DIR ?= _build
BASE_DOMAIN ?= http://blogc.org
BASE_URL ?=

DATE_FORMAT = "%b %d, %Y, %I:%M %p GMT"
DATE_FORMAT_ATOM = "%Y-%m-%dT%H:%M:%SZ"

BLOGC_COMMAND = \
	LC_ALL=$(LOCALE) \
	$(BLOGC) \
		-D AUTHOR_NAME=$(AUTHOR_NAME) \
		-D AUTHOR_EMAIL=$(AUTHOR_EMAIL) \
		-D SITE_TITLE=$(SITE_TITLE) \
		-D SITE_TAGLINE=$(SITE_TAGLINE) \
		-D BASE_DOMAIN=$(BASE_DOMAIN) \
		-D BASE_URL=$(BASE_URL) \
	$(NULL)


# Rules

LAST_PAGE = $(shell $(BLOGC_COMMAND) \
	-D FILTER_PAGE=1 \
	-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
	-p LAST_PAGE \
	-l \
	$(addprefix content/news/, $(addsuffix .txt, $(POSTS))))

all: \
	$(OUTPUT_DIR)/index.html \
	$(OUTPUT_DIR)/news/index.html \
	$(OUTPUT_DIR)/atom.xml \
	$(addprefix $(OUTPUT_DIR)/, $(ASSETS)) \
	$(addprefix $(OUTPUT_DIR)/news/, $(addsuffix /index.html, $(POSTS))) \
	$(addprefix $(OUTPUT_DIR)/, $(addsuffix /index.html, $(PAGES))) \
	$(addprefix $(OUTPUT_DIR)/news/page/, $(addsuffix /index.html, \
		$(shell for i in {1..$(LAST_PAGE)}; do echo $$i; done))) \
	$(addprefix $(OUTPUT_DIR)/man/, $(addsuffix .html, $(MANPAGES))) \
	$(NULL)

$(OUTPUT_DIR)/news/index.html: $(addprefix content/news/, $(addsuffix .txt, $(POSTS))) templates/main.tmpl
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_PAGE=1 \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
		-D MENU=news \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(addprefix content/news/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/news/page/%/index.html: $(addprefix content/news/, $(addsuffix .txt, $(POSTS))) templates/main.tmpl
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_PAGE=$(shell echo $@ | sed -e 's,^$(OUTPUT_DIR)/news/page/,,' -e 's,/index\.html$$,,') \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
		-D MENU=news \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(addprefix content/news/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/atom.xml: $(addprefix content/news/, $(addsuffix .txt, $(POSTS))) templates/atom.tmpl
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT_ATOM) \
		-D FILTER_PAGE=1 \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE_ATOM) \
		-l \
		-o $@ \
		-t templates/atom.tmpl \
		$(addprefix content/news/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/news/%/index.html: MENU = news
$(OUTPUT_DIR)/news/%/index.html: IS_POST = 1

$(OUTPUT_DIR)/%/index.html: content/%.txt templates/main.tmpl
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D MENU=$(MENU) \
		$(shell test "$(IS_POST)" -eq 1 && echo -D IS_POST=1) \
		-o $@ \
		-t templates/main.tmpl \
		$<

$(OUTPUT_DIR)/index.html: content/index.txt templates/main.tmpl
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D MENU=home \
		-o $@ \
		-t templates/main.tmpl \
		$<

$(OUTPUT_DIR)/man/%.html: content/man/%.ronn
	$(INSTALL) -d -m 0755 $(shell dirname $@) && \
		$(RONN) \
			--html \
			--pipe \
			--organization $(AUTHOR_NAME) \
			--manual "blogc Manual" \
			--style man,toc \
			$< > $@

$(OUTPUT_DIR)/assets/%: assets/%
	$(INSTALL) -d -m 0755 $(dir $@) && \
		$(INSTALL) -m 0644 $< $@

deploy: all
	$(GITHUB_PAGES_PUBLISH) \
		--verbose \
		--cname blogc.org \
		. \
		$(OUTPUT_DIR)

clean:
	rm -rf "$(OUTPUT_DIR)"

.PHONY: all all-local deploy clean
