
# Kings Project — NBA Readiness from International Data

Author: Ian Turner  
Stack: R (tidyverse, ggplot2, MASS, caret, pROC), Shiny

## What this is
I predict NBA readiness for international players, engineer archetype scores (post scorer, rebounder, floor spacer, two-way guard, etc.), and surface candidates with high NBA-likeness. Includes 3D visuals and a Shiny browser for filters.

## Repo layout
- `code/` — analysis (`kings_project.Rmd`) and data prep script (`01_convert_json_to_csv.R`)
- `data/` — cleaned inputs and final engineered dataset
- `outputs/` — final report, code appendix, and `plots/`
- `shiny_app/` — app code or link
- Raw JSONs: provided via **GitHub Release** (or `data/raw/` if small)

## Shiny
Launch: <paste-your-hosted-shiny-link>  
Local: `shiny::runApp("shiny_app")`

## Reproduce
1. (Optional) Download raw JSONs from the Release into `data/raw/`
2. Run `code/01_convert_json_to_csv.R`
3. Open `code/kings_project.Rmd` in RStudio → Knit
4. Outputs land in `outputs/` and `outputs/plots/`

## License / Data rights
Code is MIT. Data rights per original provider; raw files included for academic review only.
