TEXMFHOME=$(shell kpsewhich -var-value=TEXMFHOME)
INSTALL_DIR=$(TEXMFHOME)/tex/latex/pltheme
FILE=slides
OUTPUT=$(FILE)_final.pdf

all: $(OUTPUT)

background.png: makebackground.jl
	julia $<

.PHONY: clean install

jl2md: $(wildcard $(FILE).jl)
	@$(if $(wildcard $(FILE).jl),julia --project assets/literate.jl $<,echo "No jl file found")

jmd2md: $(wildcard $(FILE).Jmd)
	@$(if $(wildcard $(FILE).Jmd),julia --project assets/weave.jl $<,echo "No Jmd file found")

$(FILE).md: jmd2md

$(FILE).tex: $(FILE).md
	pandoc $< -t beamer --slide-level 2 -o $@ --template ./template/pl.tex

$(FILE).pdf: $(FILE).tex
	xelatex --shell-escape $<

$(OUTPUT): $(FILE).pdf
	cp $< $@

clean:
	latexmk	-c
	rm *.{vrb,nav,snm}

install:
	mkdir -p $(INSTALL_DIR)
	cp *.sty $(INSTALL_DIR)
