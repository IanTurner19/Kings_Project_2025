# Data README

## Files
- `intl_per_game_clean.csv` — cleaned table created from the raw JSON drops; columns aligned to the schema used in the model.
- `final_augmented_dataset.csv` — engineered features used for modeling (percentiles, archetype scores, etc.).

## Raw data
Raw JSONs are provided here: [GitHub Release “raw-jsons”](<paste-release-link>)  
(Or: placed in `data/raw/` if small.)

## How to rebuild
1. Put the raw JSONs in `data/raw/`.
2. Run `code/01_convert_json_to_csv.R` to produce cleaned CSVs.
3. Knit `code/kings_project.Rmd` to rebuild the analysis and figures.

## Notes
- Personally identifiable or confidential fields: none (double-check before sharing).
- Units: per-game stats; percentiles computed within-league-season where applicable.
- Missing values: imputed as described in the report (see “Modeling Approach”).
