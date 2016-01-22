# Content

LATEST_RELEASE = 0.7.1

AUTHOR_NAME = "Rafael G. Martins"
AUTHOR_EMAIL = "rafael@rafaelmartins.eng.br"
SITE_TITLE = "blogc"
SITE_TAGLINE = "A blog compiler."
LOCALE = "en_US.utf-8"

POSTS_PER_PAGE = 4
POSTS_PER_PAGE_ATOM = 10

POSTS = \
	blogc-0.7.1 \
	blogc-0.7 \
	blogc-0.6.1 \
	blogc-0.6 \
	blogc-0.5.1 \
	blogc-0.5 \
	blogc-0.4 \
	blogc-0.3 \
	blogc-0.2.1 \
	blogc-0.1 \
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
BLOGC_RUNSERVER ?= $(shell which blogc-runserver)
MKDIR ?= $(shell which mkdir)
CP ?= $(shell which cp)
RONN ?= $(shell which ronn)

BLOGC_RUNSERVER_HOST ?= 127.0.0.1
BLOGC_RUNSERVER_PORT ?= 8080

OUTPUT_DIR ?= _build
BASE_DOMAIN ?= https://blogc.rgm.io
BASE_URL ?=

DATE_FORMAT = "%b %d, %Y, %I:%M %p GMT"
DATE_FORMAT_ATOM = "%Y-%m-%dT%H:%M:%SZ"

BLOGC_COMMAND = \
	LC_ALL=$(LOCALE) \
	$(BLOGC) \
		-D LATEST_RELEASE=$(LATEST_RELEASE) \
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

$(OUTPUT_DIR)/news/index.html: $(addprefix content/news/, $(addsuffix .txt, $(POSTS))) templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_PAGE=1 \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
		-D MENU=news \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(addprefix content/news/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/news/page/%/index.html: $(addprefix content/news/, $(addsuffix .txt, $(POSTS))) templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_PAGE=$(shell echo $@ | sed -e 's,^$(OUTPUT_DIR)/news/page/,,' -e 's,/index\.html$$,,') \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
		-D MENU=news \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(addprefix content/news/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/atom.xml: $(addprefix content/news/, $(addsuffix .txt, $(POSTS))) templates/atom.tmpl Makefile
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

$(OUTPUT_DIR)/%/index.html: content/%.txt templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D MENU=$(MENU) \
		$(shell test "$(IS_POST)" -eq 1 && echo -D IS_POST=1) \
		-o $@ \
		-t templates/main.tmpl \
		$<

$(OUTPUT_DIR)/index.html: content/index.txt templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D MENU=home \
		-o $@ \
		-t templates/main.tmpl \
		$<

$(OUTPUT_DIR)/man/%.html: content/man/%.ronn Makefile
	$(MKDIR) -p $(dir $@) && \
		$(RONN) \
			--html \
			--pipe \
			--organization $(AUTHOR_NAME) \
			--manual "blogc Manual" \
			--style man,toc \
			$< > $@

$(OUTPUT_DIR)/assets/%: assets/% Makefile
	$(MKDIR) -p $(dir $@) && \
		$(CP) $< $@

serve: all
	$(BLOGC_RUNSERVER) \
		-t $(BLOGC_RUNSERVER_HOST) \
		-p $(BLOGC_RUNSERVER_PORT) \
		$(OUTPUT_DIR)

clean:
	rm -rf "$(OUTPUT_DIR)"

.PHONY: all serve clean
