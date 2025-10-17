# 📁 Data Documentation

**Project:** Kings Project — NBA Readiness from International Data  
**Author:** Ian Turner  
**Last Updated:** October 2025  

---

## 🧠 Overview
This folder contains all datasets used in the Kings NBA Readiness project, from raw JSONs to fully processed CSVs.  
The workflow moves through three stages:

1. **Raw JSONs** → Provided data exports containing international and NBA player box scores.  
2. **Intermediate CSVs** → Cleaned, structured versions of the JSONs with unified column names and types.  
3. **Final Augmented Dataset** → Combined and feature-engineered dataset used for modeling and visualization.  

---

## 📂 File Breakdown

### 🧾 Raw Data Files
| File | Description |
|------|--------------|
| `nba_box_player_season.json` | Raw NBA player box score data by season. Includes core per-game and advanced metrics. |
| `international_box_player_season.json` | Raw international league player box score data. Matches the NBA structure for alignment. |
| `player.json` | Player-level metadata (age, birth date). Used for joins and player-level features. |

> ⚠️ These files were not modified except for conversion to CSV.  
> Original formatting (nested JSON structure) is preserved for reference.

---

### 📊 Intermediate CSVs
| File | Description |
|------|--------------|
| `nba_data.csv` | Cleaned and flattened version of the NBA JSON data, with standardized column names and numeric types. |
| `international_data.csv` | Cleaned international player data converted from JSON, formatted to mirror the NBA dataset. |
| `player_data.csv` | Player metadata extracted from `player.json` for consistent joins on player ID. |

> These datasets were used primarily for merging and validation before final augmentation.

---

### 🧩 Final Analytical Dataset
| File | Description |
|------|--------------|
| `full_final_data.csv` | Merged and feature-engineered dataset used for all modeling and visualization. Includes derived features such as age, most recent season played, efficiency metrics, archetype percentiles, and the modeled `nba_probability`. |

---

## 🔧 Data Processing Summary
The raw JSONs were parsed and converted to CSVs using the script:
