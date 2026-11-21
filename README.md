# 🔥 Burnwise: Harmonization of MODIS and VIIRS Hot Spots

**NASA Space Apps Cairo 2026 · Team "Foul & Fire"**

Burnwise is a web application that merges two decades of satellite active-fire records (MODIS and VIIRS) into one consistent **burning activity calendar**. It helps emergency responders, scientists, and land managers answer one question quickly: **"Is this fire season unusual?"**

---

## The Problem

MODIS (since 2000, 1 km) and VIIRS (since 2012, 375 m) detect fires at different resolutions, so simply joining them creates a false jump. In our Egypt data, VIIRS records 8,605 vegetation hotspots in 2013 against 597 for MODIS in 2012, a **+1,341% rise that is a sensor artifact, not a fire season**.

On top of that, 69% of Egyptian VIIRS detections (and 40% of MODIS) are not vegetation fires (gas flares, industry), which hides the seasonal burning that matters.

## What Burnwise Does

- **Harmonizes** MODIS and VIIRS into one series (283 months, Jan 2003 to Jul 2026)
- **Filters** to vegetation fires only (FIRMS type 0) with a confidence filter
- **Select an area** on a Leaflet map (draw a rectangle or type coordinates) and a year range
- **Burning calendar**: year × month heat map using the color-blind-safe viridis ramp
- **Historical comparison**: each month versus the historical median, with an anomaly view (diverging blue–red ramp)
- **Early-warning alerts**: five levels based on a robust z-score
- **High-risk clusters**: HDBSCAN groups monthly hotspots into clusters ranked by fire radiative power
- **Export**: CSV of the monthly table, and PNG of the calendar and chart

## Data

| Sensor | Source | Detections | Period |
|---|---|---|---|
| MODIS Collection 6.1 (Terra + Aqua, 1 km) | NASA FIRMS | 34,956 | Nov 2000 – Aug 2026 |
| VIIRS S-NPP 375 m | NASA FIRMS | 482,784 | Jan 2012 – Jul 2026 |

Coverage is all of Egypt, with the **Nile Delta** (30.0–31.75°N, 29.5–32.5°E) as the study site. The raw files are included in this repository. Source: [NASA FIRMS Archive](https://firms.modaps.eosdis.nasa.gov/).

## Pipeline

```
FIRMS archive → cleaning → 0.25° monthly grid → harmonization
  (Random Forest, ratio as baseline) → harmonized_monthly.csv → API → web app
```

1. **Cleaning**: remove duplicates, keep 2003-01-01 onward, keep vegetation fires only, apply confidence filter (MODIS ≥ 30; VIIRS nominal or high). Eight grid cells with extreme MODIS growth are excluded.
2. **Grid**: detections counted per 0.25° cell (~27 km) per month, with empty months filled as zeros (481 cells × 283 months = 136,123 rows).
3. **Harmonization**, fitted on the 2013–2022 overlap and applied to MODIS counts before 2013:
   - **Ratio baseline**: constant VIIRS/MODIS ratio (13.43)
   - **Random Forest**: 150 trees, depth 12, predicts monthly VIIRS count from MODIS count, month, and location (SHAP used for inspection)
4. **Analytics**: monthly medians (2003–2025), anomaly = count − median, robust z-score alerts, HDBSCAN clustering.

## Results

| Method | 2012→2013 jump | Leave-one-year-out error (2013–2022) | Holdout error 2023–2025 |
|---|---|---|---|
| Raw merge | +1,341% | – | – |
| Constant ratio (13.43) | +7.3% | 17.6% | 56.5% |
| **Random Forest** | **−11.6%** | **9.1%** | **31.5%** |
| Climatology baseline | – | – | 32.2% |

- Both methods remove more than 99% of the artificial jump.
- The Delta holds 41% of Egypt's vegetation hotspots in 15% of grid cells, and its October median is **4.3×** the average of other months (the rice-straw "black cloud" season).

### Alert levels

Robust z-score = 0.6745 × (value − median) / MAD, compared with the same month in other years:

| Level | Threshold |
|---|---|
| Watch | ≥ 1 |
| High | ≥ 2 |
| Critical | ≥ 3 |
| Unusually low | ≤ −2 |

## Limitations

We report these openly:

- In 2023–2025 the Random Forest does **not clearly beat** a simple climatology baseline (31.5% vs 32.2%).
- **2025 fails for every method**; VIIRS counts fell 41% between 2023 and 2025 and we have not tested the cause.
- The Random Forest smooths pre-2013 variability (5.9% vs 11.5% for real VIIRS), so extreme early years are probably understated.
- Excluding eight cells used 2018–2024 behaviour, so the headline holdout figure is probably optimistic (about 43% without the exclusion).
- Validation is on Egypt-wide totals; Delta-only and single-cell accuracy were not validated. 2026 covers January–July only.
- Persistent heat sources labelled as vegetation can survive filtering, and alert thresholds are not yet calibrated against known events.

## Tech Stack

- **Data and modelling**: Python, pandas, NumPy, scikit-learn, SHAP, HDBSCAN, Google Colab
- **Backend**: FastAPI (reads the harmonized CSV once and answers area and date queries)
- **Frontend**: Leaflet, leaflet-draw, Chart.js

## Getting Started

> Adjust the file names and commands below to match your repository structure.

```bash
# 1. Clone the repository
git clone https://github.com/yomnamohamed07/new-Burnwise.git
cd new-Burnwise

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run the API (replace main:app with your actual module)
uvicorn main:app --reload

# 4. Open the web app in your browser
# http://127.0.0.1:8000
```

## Team "Foul & Fire"

| Member | Role |
|---|---|
| Eman Mohammed Essa | Data engineering and harmonization |
| Wissam Mahmoud | AI modelling and analytics |
| Yomna Mohamed | Backend, frontend, and repository |

## AI Assistance

A generative AI assistant (Claude, by Anthropic) helped draft and debug code, suggest validation baselines, and edit the proposal. The team ran all code, checked the numbers against the outputs, and made every decision.

## References

1. L. Giglio, W. Schroeder, C. O. Justice, "The Collection 6 MODIS active fire detection algorithm and fire products," *Remote Sens. Environ.*, 2016. doi:10.1016/j.rse.2016.02.054
2. W. Schroeder et al., "The New VIIRS 375 m active fire detection data product," *Remote Sens. Environ.*, 2014. doi:10.1016/j.rse.2013.12.008
3. M. J. Wooster et al., "Satellite remote sensing of active fires: History and current status," *Remote Sens. Environ.*, 2021. doi:10.1016/j.rse.2021.112694
4. H. S. Marey et al., "Study of the formation of the 'black cloud' and its dynamics over Cairo, Egypt, using MODIS and MISR sensors," *J. Geophys. Res. Atmos.*, 2010. doi:10.1029/2010JD014384
5. L. McInnes, J. Healy, S. Astels, "hdbscan: Hierarchical density based clustering," *JOSS*, 2017. doi:10.21105/joss.00205
6. NASA FIRMS: https://firms.modaps.eosdis.nasa.gov/
