# Burnwise: Harmonization of MODIS and VIIRS Hot Spots

A harmonized burning-activity calendar for Egypt, built from NASA FIRMS satellite fire data.
Project of **Team Foul & Fire** for **NASA Space Apps Cairo 2026** (challenge: *Harmonization of MODIS and VIIRS Hot Spots*).

## 🔗 Demo & Links

- **Live Web App:** [Open Live App](https://new-burnwise-4tvx.vercel.app/)
- **App Walkthrough Video:** [Watch App Demo](https://drive.google.com/file/d/1EE9qZfw9YZ1pTFKK1D-8JcT51E600CeC/view)
- **YouTube Project Explanation:** [Watch Explanation on YouTube](https://youtu.be/G6_1jqzwgX8)
## The problem

NASA satellites have detected active-fire hotspots for 20+ years with two sensors: **MODIS** (since 2000, 1 km) and **VIIRS** (since 2012, 375 m). Their counts cannot be compared directly, because the sensors differ in resolution, sensitivity and observation schedule. VIIRS records far more small fires, so simply merging the two files creates an artificial jump in 2013 (+1,341% in our Egypt data, see the proposal). Fire managers therefore lack one consistent history of when and where burning happens.

## What we built

1. **Data pipeline and harmonization** (`notebooks/Burnwise_pipeline.ipynb`): cleaning, gridding, two harmonization methods, validation.
2. **Web app** (`burnwise-app/`): select an area and dates, see a burning calendar, compare each month with its historical median, download results. See `burnwise-app/README.md` for how to run it.
3. **Documents** (`docs/`): the full proposal and the demo slides.

## Method (summary)

| Step | What we did |
|---|---|
| Data | NASA FIRMS archive for Egypt: MODIS Collection 6.1 (Terra, Aqua) and VIIRS S-NPP 375 m |
| Cleaning | 2003 to Jul 2026; duplicates removed; FIRMS type 0 (presumed vegetation fire) only; low-confidence detections removed (MODIS < 30, VIIRS "low") |
| Grid | 0.25 degree cells, monthly counts, empty months set to zero (481 cells x 283 months = 136,123 rows) |
| Quality check | 8 grid cells with non-seasonal, MODIS-only growth excluded from both sensors |
| Harmonization | (a) constant VIIRS/MODIS ratio (13.43), (b) Random Forest (150 trees, depth 12; features: cell location, month, MODIS count), both fitted on the 2013-2022 overlap and applied to MODIS before 2013; real VIIRS from 2013 |
| Analytics | Median per cell and calendar month over complete years (2003-2025); anomaly = count minus median |

Cleaning counts (MODIS / VIIRS): raw 34,956 / 482,784, date window 33,318 / 482,783, vegetation fires only 20,145 / 150,033, confidence filter 19,031 / 136,019. The type filter removes 39.5% of MODIS and 68.9% of VIIRS detections (mostly static sources such as gas flares).

## Results

Error of the predicted VIIRS yearly total for Egypt (lower is better):

| Method | Leave-one-year-out 2013-2022 | Hold-out 2023-2025 (never used for fitting) |
|---|---|---|
| Constant ratio (baseline) | 17.6% | 56.5% |
| Random Forest | **9.1%** | **31.5%** |
| VIIRS-only climatology (ignores MODIS) | 9.8% | 32.2% |

Hold-out error by year (2023 / 2024 / 2025): Random Forest 10.3% / 25.0% / 59.2%, ratio 40.1% / 30.4% / 98.9%, climatology 3.2% / 29.4% / 64.0%.
The 2012 to 2013 jump shrinks from +1,341% (raw merge) to +7.3% (ratio) and -11.6% (Random Forest).

## Limitations

- The Random Forest clearly beats the constant ratio, but **not clearly the climatology baseline** in 2023-2025, so much of its skill may come from learning typical spatial and seasonal patterns, not from the MODIS counts.
- **2025 fails for every method.** VIIRS counts fell sharply while MODIS did not; we have not found the cause.
- Pre-2013 values cannot be validated (no VIIRS), and the Random Forest smooths pre-2013 yearly variability, so extreme years are probably understated.
- The 8 excluded cells were chosen using 2018-2024 behaviour, which can make validation look better than it is.
- Errors are measured on Egypt-wide totals; single cells are much noisier. 2026 covers January to July only. MODIS and VIIRS type and confidence classes are defined differently, so the filters are approximate.

## Repository structure

```
notebooks/   data pipeline, harmonization and validation (Colab notebook)
burnwise-app/ web app (Angular); reads the harmonized CSV in public/data/
docs/        proposal and demo slides (PDF)
Naca_Space_Cairo_datasets.zip   raw FIRMS downloads for Egypt (MODIS and VIIRS)
```

## How to reproduce

1. Open `notebooks/Burnwise_pipeline.ipynb` in Google Colab.
2. Upload the FIRMS archive files from the data zip (or download them again from [NASA FIRMS Archive Download](https://firms.modaps.eosdis.nasa.gov/): country Egypt, MODIS and VIIRS S-NPP, 2000-11-01 to 2026-10-31).
3. Set the file names at the top of the notebook and run all cells.
4. The notebook writes the harmonized monthly table that the app reads.

## Team

| Member | Role |
|---|---|
| Eman Mohammed Essa | Data engineering and harmonization: FIRMS download, cleaning, grid aggregation, ratio baseline, validation |
| Wissam Mahmoud | AI modelling and analytics: Random Forest, SHAP, hold-out tests, anomaly alerts |
| Yomna Mohamed | Web app and interface: map, calendar, charts, CSV export |

## Data and credits

- **NASA Earthdata FIRMS** (Fire Information for Resource Management System): MODIS C6.1 and VIIRS S-NPP 375 m active-fire archive. https://www.earthdata.nasa.gov/data/tools/firms
- Giglio, L., Schroeder, W., Justice, C. O. (2016). The collection 6 MODIS active fire detection algorithm and fire products. *Remote Sensing of Environment*, 178, 31-41.
- Schroeder, W., Oliva, P., Giglio, L., Csiszar, I. A. (2014). The New VIIRS 375 m active fire detection data product. *Remote Sensing of Environment*, 143, 85-96.
- Python: pandas, NumPy, scikit-learn, SHAP, Matplotlib. Google Colab.

## Use of AI

Parts of the code and documentation were developed with the assistance of **Claude (Anthropic)**: planning the approach, drafting and reviewing code, suggesting validation baselines, and editing text. The team ran the code on the real NASA data, checked the outputs, and made the final decisions. Machine learning (a scikit-learn Random Forest) is also part of the solution itself.
