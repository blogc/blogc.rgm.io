MANPAGES = \
	blogc.1 \
	blogc-git-receiver.1 \
	blogc-runserver.1 \
	blogc-source.7 \
	blogc-template.7 \
	blogc-pagination.7 \
	$(NULL)

BLOGC_RUNSERVER ?= $(shell which blogc-runserver)
MKDIR ?= $(shell which mkdir)
RONN ?= $(shell which ronn)

BLOGC_RUNSERVER_HOST ?= 127.0.0.1
BLOGC_RUNSERVER_PORT ?= 8080
OUTPUT_DIR ?= _build

all: $(addprefix man/, $(addsuffix .html, $(MANPAGES)))

man/%.html: man/%.ronn man/index.txt
	$(MKDIR) -p $(dir $@) && \
		$(RONN) \
			--html \
			--pipe \
			--organization "Rafael G. Martins" \
			--manual "blogc Manual" \
			--style man,toc \
			$< > $@

serve:
	$(BLOGC_RUNSERVER) \
		-t $(BLOGC_RUNSERVER_HOST) \
		-p $(BLOGC_RUNSERVER_PORT) \
		$(OUTPUT_DIR)

.PHONY: all serve
