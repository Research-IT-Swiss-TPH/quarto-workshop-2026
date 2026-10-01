# Quarto Workshop

Hands-on introduction to [Quarto](https://quarto.org) for reproducible reports at Swiss TPH.

- **Audience:** R / RStudio users with basic R knowledge
- **Duration:** ~2 hours (lecture + hands-on)

## Before you arrive

- Install RStudio from Swiss TPH company portal.
- Install R packages
```{r}
install.packages(c("knitr", "readr", "dplyr", "ggplot2", "scales"))
```
- Install TinyTex (optional, if you would like to render PDF reports with Latex)
```{r}
install.packages("tinytex")
tinytex::install_tinytex()
```

## Get the materials

```bash
git clone https://github.com/Research-IT-Swiss-TPH/quarto-workshop-2026.git
cd quarto-workshop
```

Or download the ZIP from the green **Code** button.

## What's in here

- `exercises/report-instructions.qmd`: the exercise handout; render this file
  to PDF before the workshop.
- `exercises/report-starter.qmd`: the minimal file participants edit.
- `exercises/data/cases.csv`: the data used in the exercise.
- `slides/lecture.pptx`: the workshop slides.

## License

Unless otherwise noted, the workshop materials are licensed under
[Creative Commons Attribution 4.0 International (CC BY 4.0)](LICENSE).
When reusing them, credit the authors, link to the license, and indicate
any changes.
