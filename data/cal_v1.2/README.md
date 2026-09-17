# MIRI WFSS (P750L) Calibration Suite — MIRI_WFSS_CAL_v1.2

Release date: 2026-09-17 (v1.2; first release 2026-06-11).  Built from 5 archival JWST programs with FULL-array
P750L exposures: GO-3224 (McKinney), GO-4192 (Alberts), GO-4762
(Fujimoto) in GOODS-N; GO-8544 (Helton) in GOODS-S; CAL-9505 (Petric, LMC,
true MIR_WFSS) and CAL-9265 (Petric, HD 163466 CALSPEC standard).

This directory is the v1.2 calibration suite (flattened layout, without the
example-spectrum products).  v1.2 rebuilds the wavelength calibration on an
external reference: the MIRI/MRS spectrum of the wavelength-calibration
planetary nebula (SMP LMC 058 = LHA 120-N 133; Jones et al. 2023,
MNRAS 523, 2519; program CAL-1049), degraded to the WFSS
resolution and cross-correlated
feature by feature.  Two previously adopted anchor identifications were wrong
([Mg V] 5.610 um is the PAH 5.698 um band; [Ar V] 7.902 um is the PAH 7.834 um
complex blended with Pfund-alpha 7.460 / Humphreys-beta 7.502): the v3.1
solution was blueshifted by up to 54 nm (1.3 px) at 6.3 um while accurate
redward of 9 um.  Wavelengths shift by +53/+49/+35/+21/+9/-2/-3/+5 nm at
5/6/7/8/9/10.5/12/13.4 um relative to v3.1, and the response is re-derived on
the corrected scale.  At fixed observed wavelength, calibrated flux densities
change by <1.5% everywhere except the bluest bin (4.7 um, -5%).

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
| `DISPL_LRS_WFSS_P750L_v4.dat`   | wavelength: dy(x0, y0, lambda), 16 coefficients |
| `FLUXCAL_LRS_WFSS_v4.dat`       | response fR(lambda) + per-bin anchor provenance |
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
   `DISPL_LRS_WFSS_P750L_v4.dat` (`fit_disp_order32`,
   Delta-lambda = lambda - 3.95 um). Vacuum wavelengths; apply your own
   barycentric correction (VELOSYS) as needed.
4. Extract: sum DN/s over the cross-dispersion aperture per row
   (local background from the cutout edges).
5. Flux: F_nu [Jy] = DN/s(row) / fR(lambda_row), with fR from
   `FLUXCAL_LRS_WFSS_v4.dat`. No positional (L-flat) term is applied: the
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
| wavelength       | RMS 9 nm, max 14 nm (~0.1 resel) over 6.3-12.6 um, validated externally against the MIRI/MRS spectrum of the calibration PN; anchor RMS 0.41 px (0.15 resel) |
| flux (7.4-13.45) | CALSPEC-direct; sigma(fR)/fR median 0.3 %; absolute ~1-2 % (CALSPEC) |
| flux (4.5-7.4)   | ensemble shape, sigma(fR)/fR median ~5 %; tied through the 7.5-9.0 um CALSPEC overlap (scale 1.0535) |
| L-flat           | identity; CALSPEC 5-position grid max |L-1| = 0.016 (MAD 0.003); GN/GS star repeats MAD 0.014 |

Independent validation: six GOODS-N G/K stars give per-star medians of
0.89-1.07 against the v1.2 response; a G=17.1 field star (2MASS/WISE SED)
gives obs/expected = 1.016 +- 0.042 (v1.0 measurement; the response changes
by <2% over its 5-11 um fit range between v1.0 and v1.2).

## References
- JWST absolute flux calibration approach: Gordon et al. 2022, AJ 163, 267.
- CALSPEC: hd163466_stis_007.fits,
  https://www.stsci.edu/hst/instrumentation/reference-data-for-calibration-and-tools/astronomical-catalogs/calspec
- Wavelength reference: MIRI/MRS spectrum of SMP LMC 058 (Jones et al. 2023,
  MNRAS 523, 2519, doi:10.1093/mnras/stad1609; JWST program CAL-1049), degraded to the
  WFSS line-spread function; plus GOODS-N spec-z galaxy PAH/line anchors
  compiled from the literature (mostly available on SIMBAD).

Contact: Fengwu Sun (Harvard University → Westlake University; sunfengwu在westlake.edu.cn).
