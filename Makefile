TEXMFHOME=$(shell kpsewhich -var-value=TEXMFHOME)
INSTALL_DIR=$(TEXMFHOME)/tex/latex/pltheme
FILE=slides
OUTPUT=$(FILE)_final.pdf

all: $(OUTPUT)

background.png: makebackground.jl
	julia $<

.PHONY: clean install

jmd2md: $(wildcard $(FILE).Jmd)
	@$(if $(wildcard $(FILE).Jmd),julia --project -e 'using Weave; weave("$<", doctype="pandoc", cache=:on, fig_ext=".pdf")',echo "No Jmd file found")

$(FILE).md: jmd2md

$(FILE).tex: $(FILE).md
	pandoc $< -t beamer --slide-level 2 -o $@ --template ./template/pl.tex

$(FILE).pdf: $(FILE).tex
	latexmk

$(OUTPUT): $(FILE).pdf
	cp $< $@

clean:
	latexmk	-c
	rm *.{vrb,nav,snm}

install:
	mkdir -p $(INSTALL_DIR)
	cp *.sty $(INSTALL_DIR)
