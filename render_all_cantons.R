# Batch-render canton-report.qmd once per canton.
# Each render overrides params$canton and writes its own PDF.

library(quarto)
library(readr)

qmd <- "canton-report.qmd"
outdir <- "reports"
dir.create(outdir, showWarnings = FALSE)

# Canton list: read from the same dataset the report uses.
# To render only a subset, replace this with e.g.
#   cantons <- c("Zürich", "Genève", "Ticino")
cantons <- read_csv("swiss_cantons_dummy.csv", show_col_types = FALSE)$canton

for (ct in cantons) {
  message("Rendering: ", ct)

  # Safe file name (spaces/slashes -> underscore).
  safe <- gsub("[^A-Za-z0-9]+", "_", ct)

  quarto_render(
    input          = qmd,
    output_file    = paste0("canton-report-", safe, ".pdf"),
    execute_params = list(canton = ct)
  )

  # quarto writes output next to the .qmd; move it into outdir.
  file.rename(
    paste0("canton-report-", safe, ".pdf"),
    file.path(outdir, paste0("canton-report-", safe, ".pdf"))
  )
}

message("Done. PDFs in ./", outdir, "/")
