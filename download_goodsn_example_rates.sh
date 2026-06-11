#!/bin/sh
# Download the example JWST MIRI WFSS (P750L FULL) rate files from MAST.
#
# Program GO-4192 (PI: S. Alberts; SMILES), GOODS-N.
# Observation 3 (2024-05-20) + its repeat, observation 103 (2025-05-17):
# 8 exposures x ~21 MB = ~170 MB total. All files are public (no token needed).
#
# The exposures cover the bright PAH-emitting group at (RA, Dec) ~ (189.11, +62.21)
# listed in data/catalogs/goodsn_example_sources.csv.

mkdir -p ./data/rates/

i=0
for f in \
    jw04192003001_02101_00001_mirimage_rate.fits \
    jw04192003001_02101_00002_mirimage_rate.fits \
    jw04192003001_02103_00001_mirimage_rate.fits \
    jw04192003001_02103_00002_mirimage_rate.fits \
    jw04192103001_03103_00001_mirimage_rate.fits \
    jw04192103001_03103_00002_mirimage_rate.fits \
    jw04192103001_03105_00001_mirimage_rate.fits \
    jw04192103001_03105_00002_mirimage_rate.fits
do
    i=$((i+1))
    if [ -s "./data/rates/$f" ]; then
        echo "<<< File [$i/8] already exists, skipping: $f"
        continue
    fi
    echo "<<< Downloading File [$i/8]: $f"
    curl --globoff --location-trusted -f --progress-bar \
         --output "./data/rates/$f" \
         "https://mast.stsci.edu/api/v0.1/Download/file?uri=mast:JWST/product/$f"
done

echo "Done. Files are in ./data/rates/"
