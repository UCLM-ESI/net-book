.PHONY: all buildpdf check clean code-checks

BOOK_SOURCES := *.md *.ipynb
BOOK_PDF = _build/latex/book.pdf

all: check _build

_build: ${BOOK_SOURCES}
	jb build -W .

# ${BOOK_PDF}: ${BOOK_SOURCES}
# 	jb build -W -n --builder pdflatex .

# publish: _build ${BOOK_PDF}
publish: _build
	mv _build/html $@
	cp -r src $@
	# mv ${BOOK_PDF} $@/ssdd-lab.pdf
	# cp -r assets $@

clean:
	jb clean .
	find . -name "*~" -delete
	rm -rf _build publish

check:
	pre-commit run --all

code-checks:
	pylint src/*/*.py
	pycodestyle src/*/**.py
	pydocstyle src/*/*.pydocstyle
