# define the building tool
TEX = pdflatex
BIB = bibtex

# verbose mode
VERB ?= 0

# dummy targets
.PHONY: all clean realclean spell force extract \
	chap0 chap1 chap2 chap3 chap4 chap5

# useful custom variables
THIS=Makefile
TARGET_FILE=thesis.pdf
GRAY=gray.pdf
GRAYSCRIPT="./toGray.sh"
SUB="tmp.pdf"

# environment variables
WRKDIR=tmp
PWD!=pwd
ENV=env \
	TEXINPUTS=".:${PWD}/:${PWD}/Styles/:${PWD}/Figures/:" \
	BIBINPUTS="${PWD}:${PWD}/Styles/:" \
	BSTINPUTS=".:${PWD}/:${PWD}/Styles/:"\
	LXDINPUTS=".:./Styles/:./Figures/:"
NAME=thesis
NAME_CHAP=standalone_chapter
NAME_outCHAP=standalone_chapter
BIBSRC = biblioComplete.bib

# SOURCES
STYLES=Styles/*.sty

# FIGURE_DIR=Figures
# FIGURES += $(wildcard $(FIGURE_DIR)/*.tikz)
# FIGURES += $(wildcard $(FIGURE_DIR)/*.png)
# FIGURES += $(wildcard $(FIGURE_DIR)/*.jpg)
# FIGURES += $(wildcard $(FIGURE_DIR)/*.svg)
# FIGURES += $(wildcard $(FIGURE_DIR)/*/*.png)
# FIGURES += $(wildcard $(FIGURE_DIR)/*/*.jpg)

# SPELLCHECKER
SPELLCHECK=hunspell
SPELLOPT=-d en_GB -t

all: $(TARGET_FILE)

# documents
$(TARGET_FILE): *.tex $(BIBSRC) $(STYLES) chapters/* chapters/*/*
	# @make -s figure
	@mkdir -p ${WRKDIR} 
	@cd ${WRKDIR}; ${ENV} ${TEX} -halt-on-error -draftmode ${NAME} 
	@cd ${WRKDIR}; ${ENV} ${BIB} ${NAME} 
	@cd ${WRKDIR}; ${ENV} ${TEX} -halt-on-error -draftmode ${NAME} 
	@cd ${WRKDIR}; ${ENV} ${TEX} -halt-on-error -draftmode ${NAME} 
	@cd ${WRKDIR}; ${ENV} ${TEX} -halt-on-error ${NAME} 
	@mv ${WRKDIR}/$@ $@

# documents
fast: *.tex $(BIBSRC) $(STYLES) chapters/* chapters/*/*
	# @make -s figure
	@mkdir -p ${WRKDIR}
	@cd ${WRKDIR}; ${ENV} ${TEX} -halt-on-error ${NAME}
	@mv ${WRKDIR}/${NAME}.pdf ${NAME}.pdf

chapters: *.tex $(BIBSRC) $(STYLES)
	@mkdir -p ${WRKDIR} 
	@cd ${WRKDIR}; ${ENV} ${TEX} -halt-on-error ${NAME_CHAP} 
	@mv ${WRKDIR}/${NAME_CHAP}.pdf ${NAME_outCHAP}.pdf
	@cd ${WRKDIR}; ${ENV} ${BIB} ${NAME_CHAP} 
	@cd ${WRKDIR}; ${ENV} ${TEX} -halt-on-error -draftmode ${NAME_CHAP} 
	@cd ${WRKDIR}; ${ENV} ${TEX} -halt-on-error -draftmode ${NAME_CHAP} 
	@cd ${WRKDIR}; ${ENV} ${TEX} -halt-on-error ${NAME_CHAP} 
	@mv ${WRKDIR}/${NAME_CHAP}.pdf ${NAME_outCHAP}.pdf

# we put the setcounter to number of chapter-1
chap0: chapters/Introduction/*.tex
	@sed -i '2c \\\setcounter{chapter}{0}' standalone_chapter.tex
	@make chapters NAME_outCHAP="chapter0"

chap1: chapters/airseaSCM/*.tex
	@sed -i '2c \\\setcounter{chapter}{0}' standalone_chapter.tex
	@make chapters NAME_outCHAP="chapter1"

chap2: chapters/discreteSchwarzAnalysis/*.tex
	@sed -i '2c \\\setcounter{chapter}{1}' standalone_chapter.tex
	@make chapters NAME_outCHAP="chapter2"

chap3: chapters/approximatedDiscreteSchwarz/*.tex
	@sed -i '2c \\\setcounter{chapter}{2}' standalone_chapter.tex
	@make chapters NAME_outCHAP="chapter3"

chap4: chapters/ND/*.tex
	@sed -i '2c \\\setcounter{chapter}{3}' standalone_chapter.tex
	@make chapters NAME_outCHAP="chapter4"

chap5: chapters/OASchwarz/*.tex
	@sed -i '2c \\\setcounter{chapter}{4}' standalone_chapter.tex
	@make chapters NAME_outCHAP="chapter5"

# sub makefile if anything needed to compile the Figures
figure: $(FIGURES)
	@cd $(FIGURE_DIR); make -s

# used to check that grayscale is readable 
# 	particularly useful to check if the document is colorblind friendly
gray: $(GRAY)
$(GRAY): $(TARGET_FILE)
	@$(GRAYSCRIPT) $(TARGET_FILE) $@

# extract a particular sub-range from the pdf
# 	useful to print only a subset of the document
# usage: make extract RANGE=<first>-<last>
extract: $(TARGET_FILE)
	@pdftk $< cat $(RANGE) output $(SUB)

# check for spelling mistake against a word dictionary
# usage: make spell FILE=chapterX.tex
spell:
	@$(SPELLCHECK) $(SPELLOPT) ${FILE}

# count the number of used citations in the final document
countCite:
	@pdftotext $(TARGET_FILE) $(WRKDIR)/tmp.txt
	@cat $(WRKDIR)/tmp.txt | grep "(Cited" | wc -l

# count the number of words in the final document
countWord:
	@pdftotext $(TARGET_FILE) $(WRKDIR)/tmp.txt
	@cat $(WRKDIR)/tmp.txt | wc -w

# auxilary
clean:
	@rm -Rf ${WRKDIR}/*
	@rm -f *~ *.pdf
#	rm -f *.aux *.bbl *.blg *.out *.nav *.snm *.brf *.idx *.loa *.lof *.lot *.log *.toc *.dvi *.ps *.pfg *.bak *.tdo

realclean: clean
	@cd $(FIGURE_DIR); make -s clean VERB=$(VERB)

# force regeneration
force: clean
	@make
