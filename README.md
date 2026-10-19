# Backend-only MATLAB package

This package starts **after preprocessing**. The two required inputs are already averaged/arranged MATLAB files:

- `data/AB_avgDat_Camargo.mat`
- `data/AB_avgDat_Molinaro.mat`
  
## References
- Camargo, Jonathan, et al. "A comprehensive, open-source dataset of lower limb biomechanics in multiple conditions of stairs, ramps, and level-ground ambulation and transitions." Journal of biomechanics 119 (2021): 110320.
- Molinaro, Dean D., Inseung Kang, and Aaron J. Young. "Estimating human joint moments unifies exoskeleton control, reducing user effort." Science robotics 9.88 (2024): eadi8852.
- Buhmann, Martin Dietrich. "Radial basis functions." Acta numerica 9 (2000): 1-38.

## Final runners

- `run_global_rbf_plot.m`
- `run_local_fits_plot.m`

Run either script from MATLAB. Each runner adds `src/` recursively to the MATLAB path, so no manual path setup is required.

## Dependency structure

```text
run_global_rbf_plot.m
├─ load_preprocessed_biomechanics.m
├─ build_target_biomechanics.m
├─ evaluate_all_biomechanics_with_RBF.m
│  └─ evaluate_selected_biomechanics_with_RBF.m
│     ├─ leave_slopes_out.m
│     ├─ piecewise_2dpoly.m
│     ├─ merge_RBF.m
│     └─ evaluate_model.m
├─ build_rbf_model_struct.m
└─ final_eval_all_MAEs_with_RBF.m
   └─ final_eval_combined_MAEs_with_RBF.m
      └─ evaluate_selected_biomechanics_with_RBF.m

run_local_fits_plot.m
├─ load_preprocessed_biomechanics.m
└─ local_polyfit_comparison.m
   ├─ get_terrain_slope_sets.m
   ├─ select_biomechanics_surface.m
   ├─ prepare_local_fit_data.m
   │  └─ leave_slopes_out.m
   ├─ build_local_plot_options.m
   ├─ fit_local_biomechanics_models.m
   │  └─ piecewise_2dpoly.m
   └─ evaluate_model.m
```

## Folder roles

```text
src/io          Load/standardize the already-preprocessed input data
src/core        Shared surface-selection, polynomial-fit, RBF, and evaluation functions
src/global      Unified/global RBF model construction
src/local       Local polynomial-fit comparison
src/evaluation  Current downstream MAE manuscript evaluation
```

## Required MATLAB toolboxes

Core model construction currently uses:

- Curve Fitting Toolbox (`fit`, `poly44`)
- Statistics and Machine Learning Toolbox (`pdist2`; MAE/statistical comparisons also use statistics functions)

The optional final MAE plotting path attempts `swtest` when available and otherwise falls back to MATLAB's paired `ttest` logic.

## Local-fit runner configuration

`run_local_fits_plot.m` keeps the analysis target at the top of the script:

```matlab
target_joint     = "knee";
target_state     = "stance";
target_biomech   = "angle";
target_direction = "both";
fit_type         = "poly44";
visualize        = true;
```

Plot defaults are centralized in `src/local/build_local_plot_options.m`.
`plot_overrides` in the runner can replace only selected display settings
without redefining the complete plotting structure.

## Surface-plot annotations

All surfaces generated through `evaluate_model.m` now include descriptive
biomechanics metadata and model fidelity directly in the figure:

- title: joint + gait state + biomechanical quantity + model type
- x-axis: `Terrain slope (deg)`
- y-axis: `Gait phase (%)`
- z-axis: joint angle `(deg)` or normalized joint moment `(Nm/kg)`
- second title line: mean ± 1 SD of the per-slope MAE used for that surface

Example:

```text
Hip Stance Moment - Global RBF model
MAE across slopes: 0.083 ± 0.021 Nm/kg (mean ± 1 SD)
```

The MAE annotation is calculated from the same per-slope errors returned by
`evaluate_model.m`; no separate visualization-only metric is introduced.
