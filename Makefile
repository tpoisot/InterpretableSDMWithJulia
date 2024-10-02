TEXMFHOME=$(shell kpsewhich -var-value=TEXMFHOME)
INSTALL_DIR=$(TEXMFHOME)/tex/latex/pltheme
FILE=slides
OUTPUT=$(FILE)_final.pdf
JLC=julia --threads=auto --project

all: $(OUTPUT)

background.png: makebackground.jl
	julia $<

.PHONY: clean install

literate: $(wildcard $(FILE).jl)
	@$(if $(wildcard $(FILE).jl),$(JLC) template/literate.jl $<,echo "No jl file found")

tangle: $(wildcard $(FILE).Jmd)
	@$(if $(wildcard $(FILE).Jmd),$(JLC) template/tangle.jl $<,echo "No Jmd file found")

weave: $(wildcard $(FILE).Jmd)
	@$(if $(wildcard $(FILE).Jmd),$(JLC) template/weave.jl $<,echo "No Jmd file found")

template/$(FILE).tex: $(FILE).md
	pandoc $< -t beamer --slide-level 2 -o $@ --template ./template/pl.tex

$(FILE).pdf: template/$(FILE).tex
	ln -fs figures template/figures
	latexmk $<

$(OUTPUT): $(FILE).pdf
	cp $< $@

clean:
	latexmk	-c
	rm *.{vrb,nav,snm}

install:
	mkdir -p $(INSTALL_DIR)
	cp *.sty $(INSTALL_DIR)
