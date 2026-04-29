# Thesis LaTeX Template

This folder contains a LaTeX template for the master thesis.

## Structure

```text
thesis/
  main.tex
  chapters/
    01_introduction.tex
    02_background.tex
    03_method.tex
    04_results_discussion.tex
    05_conclusion.tex
    appendix.tex
  figures/
  tables/
  refs/
    references.bib
```

## Build

From the `thesis` directory:

```bash
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

Or use `latexmk` if available:

```bash
latexmk -pdf main.tex
```

## Notes

- Replace placeholder author, supervisor, university, and citations.
- Put exported figures in `figures/`.
- Put large tables in `tables/` if they become too long for chapter files.

