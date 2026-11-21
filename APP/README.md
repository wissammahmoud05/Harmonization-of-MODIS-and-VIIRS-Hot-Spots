# Burnwise

Angular + Leaflet map for `harmonized_monthly.csv` (0.25° grid cells, monthly counts).

## Run
```
npm install
npm start          # http://localhost:4200
```

## Build / deploy (Vercel)
`vercel.json` already sets the build command and output folder (`dist/burnwise-step6-map/browser`).
Just push to GitHub and import the repo in Vercel (Framework preset: Angular or Other).

## Data
- `public/data/harmonized_monthly_AI.csv` loads automatically on start. Replace it to change the default data.
- Filters: Region (map area), Latitude line, Longitude line, Year, Month. No start/end dates.
- If production shows no data, open `https://<your-site>/data/harmonized_monthly_AI.csv`: if it does not download, the file was not pushed/deployed.
- "Data files" lets you load more CSV/Excel files with the same columns; each file gets its own colour.
- Required columns: `lat_cell, lon_cell, year, month`. Optional: `modis_count, viirs_count, harmonized_count, median_count, anomaly, is_partial_year`.
- To use a real API later, change only `src/app/core/data/data.service.ts`.

## Run without npm (pre-built)
Double-click `START.bat` (needs Python). It serves the pre-built site in `ready-to-run/` at http://localhost:4200.
After you change the code, run `npm install` then `npm run build` and copy `dist/burnwise-step6-map/browser/*` into `ready-to-run/`.
