TEXMFHOME=$(shell kpsewhich -var-value=TEXMFHOME)
INSTALL_DIR=$(TEXMFHOME)/tex/latex/pltheme
FILE=slides
OUTPUT=$(FILE)_final.pdf

all: $(OUTPUT)

background.png: makebackground.jl
	julia $<

.PHONY: clean install

literate: $(wildcard $(FILE).jl)
	@$(if $(wildcard $(FILE).jl),julia --project assets/literate.jl $<,echo "No jl file found")

weave: $(wildcard $(FILE).Jmd)
	@$(if $(wildcard $(FILE).Jmd),julia --project assets/weave.jl $<,echo "No Jmd file found")

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
