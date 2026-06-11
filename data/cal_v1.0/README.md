# MIRI WFSS (P750L) Calibration Suite — MIRI_WFSS_CAL_v1.0

Release date: 2026-06-10 (background refreshed to sky v5 on 2026-06-11).
Built from 5 archival JWST programs with FULL-array P750L exposures: GO-3224
(McKinney), GO-4192 (Alberts/SMILES), GO-4762 (Fujimoto) in GOODS-N; GO-8544
(Helton) in GOODS-S; CAL-9505 (Petric, LMC, true MIR_WFSS) and CAL-9265
(Petric, HD 163466 CALSPEC standard).

This directory is the repository copy of the v1.0 release (flattened layout,
without the example-spectrum products and the summary deck).  SHA-256 hashes
in `MANIFEST.txt` are identical to those of the original release manifest.

## Calibration model

    DN/s(x, y) = R(lambda) x L(x, y) x F_nu(lambda)  +  sky(x, y)

applied to FULL-array P750L rate images (DN/s). Dispersion runs along the
detector y axis (more negative dy = longer wavelength); the illuminated WFSS
region is x = 387-1020, y = 15-1017 (`region_mask_P750L.fits`).

## Files

| File | Content |
|---|---|
| `flat_P750L_F560W.fits`         | flat field (F560W imaging flat) |
| `master_sky_P750L_v5.fits`      | master sky (consensus-patched) + ADDITIVE defect map |
| `eigen_skies_v5_P750L.fits`     | optional PCA sky residual components (outlier-patched, mode B) |
| `region_mask_P750L.fits`        | WFSS illuminated-region mask |
| `DISP_LRS_WFSS_v2.1.dat`        | trace: dx(x0, y0, dy), 30 coefficients |
| `DISPL_LRS_WFSS_P750L_v2.1.dat` | wavelength: dy(x0, y0, lambda), 16 coefficients |
| `FLUXCAL_LRS_WFSS_v2.dat`       | response R(lambda) + per-bin anchor provenance |
| `hd163466_R_direct.ecsv`        | CALSPEC-direct response measurement |
| `LFLAT_LRS_WFSS_v2.fits`        | L(x, y) = identity (validated) |
| `VERSION`                       | release version stamp |
| `MANIFEST.txt`                  | sha256 manifest of this directory |

## Usage (per source at direct-image position x0, y0)

1. Calibrate the rate frame: divide by the flat, subtract the scaled master
   sky (mode A; optionally fit the PCA components, mode B), then remove a
   sigma-clipped median from every detector row of the residual (computed
   over source-masked WFSS pixels) to suppress EMI banding and row-wise
   gradients. Use `master_sky_P750L_v5.fits`; before the scale fit, subtract
   its ADDITIVE extension from the flat-fielded frame unscaled (it maps
   additive detector defects in DN/s, derived from a 304-frame
   consensus-residual regression) and treat |ADDITIVE| > 0.5 DN/s pixels as
   DO_NOT_USE. The mode-B PCA components (`eigen_skies_v5`) are
   outlier-patched against an along-row running median so that compact
   imprints of imperfectly masked sources cannot be stamped into corrected
   frames; if you use mode B, difference the result against its mode-A
   counterpart before trusting compact faint sources.
2. Trace: dx_s(x0, y0, dy_s) from `DISP_LRS_WFSS_v2.1.dat`
   (polynomial form `fit_disp_order23`; x, y offset by -1024 internally).
3. Wavelength per row: invert dy_s(x0, y0, lambda) from
   `DISPL_LRS_WFSS_P750L_v2.1.dat` (`fit_disp_order32`,
   Delta-lambda = lambda - 3.95 um). Vacuum wavelengths; apply your own
   barycentric correction (VELOSYS) as needed.
4. Extract: sum DN/s over the cross-dispersion aperture per row
   (local background from the cutout edges).
5. Flux: F_nu [Jy] = DN/s(row) / R(lambda_row), with R from
   `FLUXCAL_LRS_WFSS_v2.dat` (no position term needed: L = 1).
   The table's `anchor` column: 1 = measured directly on the CALSPEC
   standard HD 163466 (7.44-13.81 um); 0 = G/K-ensemble shape rescaled to
   the CALSPEC overlap (blue of the standard's saturation limit).

The notebook at the root of this repository
(`MIRI_WFSS_extraction_example_FSun.ipynb`) implements all five steps.

## Accuracy

| Component | Accuracy |
|---|---|
| trace            | MAD 0.055 px (LMC point sources); STScI specwcs_0146: 1.02 px RMS |
| wavelength       | 220-610 km/s RMS = 0.1-0.25 resel (7.9-13.1 um); ~0.4 resel at 5.6-6.2 um |
| flux (7.4-13.8)  | CALSPEC-direct; sigma(R)/R median 0.3 %; absolute ~1-2 % (CALSPEC) |
| flux (4.5-7.4)   | ensemble shape, sigma(R)/R median ~5 %; tied through the 7.4-9.5 um overlap |
| L-flat           | identity; CALSPEC 5-position grid max |L-1| = 0.010 (MAD 0.008); GN/GS repeats MAD 0.044 |

Independent validation: a G=17.1 field star (2MASS/WISE SED) gives
obs/expected = 1.016 +- 0.042; six GOODS-N G/K stars give 0.90-1.07.

## References
- JWST absolute flux calibration approach: Gordon et al. 2022, AJ 163, 267.
- CALSPEC: hd163466_stis_007.fits,
  https://www.stsci.edu/hst/instrumentation/reference-data-for-calibration-and-tools/astronomical-catalogs/calspec
- Wavelength anchors: ISO PN line atlas (Bernard-Salas et al. 2001) + LMC PN
  LHA 120-N 133 + GOODS-N spec-z galaxy lines.

Contact: Fengwu Sun.
