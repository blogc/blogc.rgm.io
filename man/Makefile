all: \
	blogc.1.html \
	blogc-git-receiver.1.html \
	blogc-runserver.1.html \
	blogc-source.7.html \
	blogc-template.7.html \
	blogc-pagination.7.html \
	$(NULL)

%.html: %.ronn index.txt
	ronn \
		--html \
		--pipe \
		--organization "Rafael G. Martins" \
		--manual "blogc Manual" \
		--style man,toc \
		$< > $@

.PHONY: all
