# MIRI WFSS (P750L) Calibration Suite — MIRI_WFSS_CAL_v1.1

Release date: 2026-08-08 (v1.1; first release 2026-06-11).  Built from 5 archival JWST programs with FULL-array
P750L exposures: GO-3224 (McKinney), GO-4192 (Alberts), GO-4762
(Fujimoto) in GOODS-N; GO-8544 (Helton) in GOODS-S; CAL-9505 (Petric, LMC,
true MIR_WFSS) and CAL-9265 (Petric, HD 163466 CALSPEC standard).

This directory is the v1.1 calibration suite (flattened layout, without the
example-spectrum products).  v1.1 corrects the wavelength calibration: the red
anchor previously identified as [Ar V] 13.102 um is [Ne II] 12.814 um.
Wavelengths shift by -41/-238/-353 nm at 11/12.8/13.5 um relative to v1.0, and
the response is re-derived on the corrected scale (CALSPEC-direct over
7.44-13.45 um).  At fixed observed wavelength, calibrated flux densities change
by <2% blueward of 11 um and by up to ~+25% at 13.4 um.

## Calibration model

    DN/s(x, y) = fR(lambda) x L(x, y) x F_nu(lambda)  +  sky(x, y)

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
| `DISPL_LRS_WFSS_P750L_v3.1.dat` | wavelength: dy(x0, y0, lambda), 16 coefficients |
| `FLUXCAL_LRS_WFSS_v3.1.dat`     | response fR(lambda) + per-bin anchor provenance |
| `hd163466_R_direct.ecsv`        | CALSPEC-direct response measurement |
| `VERSION`                       | release version stamp |
| `MANIFEST.txt`                  | sha256 manifest of this directory |

## Usage (per source at direct-image position x0, y0)

1. Calibrate the rate frame: divide by the flat; subtract the ADDITIVE
   extension of the master-sky file unscaled (additive detector defects in
   DN/s; treat |ADDITIVE| > 0.5 DN/s pixels as DO_NOT_USE); subtract the
   scaled master sky (mode A; optionally fit the 5 PCA components
   simultaneously, mode B); then remove a sigma-clipped median from every
   detector row of the residual (computed over source-masked WFSS pixels)
   to suppress EMI banding and row-wise gradients. If you use mode B,
   difference the result against its mode-A counterpart before trusting
   compact faint sources.
2. Trace: dx_s(x0, y0, dy_s) from `DISP_LRS_WFSS_v2.1.dat`
   (polynomial form `fit_disp_order23`; x, y offset by -1024 internally).
3. Wavelength per row: invert dy_s(x0, y0, lambda) from
   `DISPL_LRS_WFSS_P750L_v3.1.dat` (`fit_disp_order32`,
   Delta-lambda = lambda - 3.95 um). Vacuum wavelengths; apply your own
   barycentric correction (VELOSYS) as needed.
4. Extract: sum DN/s over the cross-dispersion aperture per row
   (local background from the cutout edges).
5. Flux: F_nu [Jy] = DN/s(row) / fR(lambda_row), with fR from
   `FLUXCAL_LRS_WFSS_v3.1.dat`. No positional (L-flat) term is applied: the
   position dependence of the response was tested and is consistent with
   identity (CALSPEC 5-position grid max |L-1| = 0.016, MAD 0.003; repeated
   GOODS-N star spectra MAD 0.014), so no L-flat file is needed.
   The table's `anchor` column: 1 = measured directly on the CALSPEC
   standard HD 163466 (7.44-13.45 um); 0 = G/K-ensemble shape rescaled to
   the CALSPEC overlap (blue of the standard's saturation limit).

The notebook at the root of this repository
(`MIRI_WFSS_extraction_example_FSun.ipynb`) implements all five steps.

## Accuracy

| Component | Accuracy |
|---|---|
| trace            | MAD 0.055 px (LMC point sources); STScI specwcs_0146: 1.02 px RMS |
| wavelength       | 87-144 km/s RMS = 0.03-0.08 resel (7.9-12.8 um); ~0.2 resel at 5.6-6.2 um |
| flux (7.4-13.45) | CALSPEC-direct; sigma(fR)/fR median 0.3 %; absolute ~1-2 % (CALSPEC) |
| flux (4.5-7.4)   | ensemble shape, sigma(fR)/fR median ~5 %; tied through the 7.5-9.0 um CALSPEC overlap (scale 1.0492) |
| L-flat           | identity; CALSPEC 5-position grid max |L-1| = 0.016 (MAD 0.003); GN/GS star repeats MAD 0.014 |

Independent validation: six GOODS-N G/K stars give per-star medians of
0.89-1.07 against the v1.1 response; a G=17.1 field star (2MASS/WISE SED)
gives obs/expected = 1.016 +- 0.042 (v1.0 measurement; the response changes
by <2% over its 5-11 um fit range in v1.1).

## References
- JWST absolute flux calibration approach: Gordon et al. 2022, AJ 163, 267.
- CALSPEC: hd163466_stis_007.fits,
  https://www.stsci.edu/hst/instrumentation/reference-data-for-calibration-and-tools/astronomical-catalogs/calspec
- Wavelength anchors: ISO PN line atlas (Bernard-Salas et al. 2001) + LMC PN LHA 120-N 133 + GOODS-N spec-z 
galaxy lines compiled from literature (mostly available on SIMBAD).

Contact: Fengwu Sun (Harvard University → Westlake University; sunfengwu在westlake.edu.cn).
