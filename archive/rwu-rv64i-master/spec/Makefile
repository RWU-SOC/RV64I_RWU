TOP := 00_rwurv64i_top

SOURCES := 00_rwurv64i_top.tex

latex:
	pdflatex $(TOP).tex
bib:
	biber $(TOP)
all:
	pdflatex $(TOP).tex
	biber $(TOP) --logfile zzz
	pdflatex $(TOP).tex
	pdflatex $(TOP).tex

#### Clean ####
.phony : clean
clean :
	rm -rf *.blg *.log *.bbl *.xml *.out *. *.bcf *.gz *.toc *.aux *.lof *.lot

