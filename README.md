# 🏀 Kings Project — NBA Readiness from International Data

**Author:** Ian Turner  
**Date:** October 2025  
**Tools:** R, ggplot2, MASS, caret, pROC, Shiny, Plotly  

---

## 🧠 Overview
This project analyzes international basketball players to predict **NBA readiness** using logistic regression, archetype analysis, and data visualization.  
It was designed to simulate a front-office scouting workflow for the Sacramento Kings.  

The pipeline converts raw JSONs into structured datasets, engineers player archetypes (Post Scorer, Rebounder, Floor Spacer, Two-Way Guard, etc.), and computes an **NBA Probability Score** to identify players most similar to current NBA talent.  

Final outputs include:
- A full reproducible RMarkdown workflow  
- A polished final report  
- Interactive Shiny app for player exploration  
- Cleaned data and model outputs  

---

## 📂 Folder Breakdown

### **code/**
Contains all analysis scripts and documentation.
- `KingsProject.Rmd` — Main RMarkdown analysis notebook (data prep → modeling → visualization).  
- `KingsProject.pdf` — Knitted document showing all code and outputs.  
- `01_convert_json_to_csv.R` — Helper script that extracts and converts JSONs into CSVs.

---

### **data/**
All data files used for analysis, from raw to processed.
- `nba_box_player_season.json`, `international_box_player_season.json`, `player.json` — Original JSONs provided.  
- `nba_data.csv`, `international_data.csv`, `player_data.csv` — Cleaned CSVs.  
- `full_final_data.csv` — Final merged and augmented dataset used for modeling.  
- `Data_README.md` — Descriptions for all datasets and variable meanings.

---

### **outputs/**
Final project deliverables and visualizations.
- `Kings_Project_2025_Report_Final.pdf` — Final written report.  
- `plots/` — Folder with exported figures (`3&D plot`, `Archetype overlap`, etc.).  

---

### **shiny_app/**
Interactive web application.
- `app.R` — Shiny app for exploring player archetypes and NBA probability interactively.
-  `README.md` 
- Shiny Application Link: https://ianturner25.shinyapps.io/kings-player-finder/](https://ianturner25.shinyapps.io/kings-player-finder/)

---

### **Kings_Project_2025.Rproj**
RStudio project file for easy setup and reproducibility.

### **README.md**
This file — full project summary and structure.

---

## ⚙️ Reproducibility Instructions

1. **Open** `Kings_Project_2025.Rproj` in RStudio.  
2. **Install required packages:**
   ```r
   install.packages(c(
     "jsonlite", "dplyr", "lubridate", "MASS", "pROC",
     "caret", "ggplot2", "scatterplot3d", "tidyr",
     "shiny", "DT", "plotly"
   ))
