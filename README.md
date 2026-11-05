# Unified Locomotion Biomechanics Modeling

MATLAB code for constructing continuous lower-limb biomechanics models across level walking, ramps, and stairs. The package starts from preprocessed able-bodied (AB) biomechanics and reproduces the polynomial-fitting and Gaussian RBF-unification workflow used in the associated manuscript.

The main outputs are continuous joint-angle, angular-velocity, and stance-moment surfaces parameterized by terrain slope and gait phase. These models can also be exported for downstream impedance parameterization.

## Data

The repository includes two preprocessed input files:

- `data/AB_avgDat_Camargo.mat`
- `data/AB_avgDat_Molinaro.mat`

The modeled terrain conditions are level walking (0 deg), ramps (±5, ±7, ±9, ±11 deg), and stairs (±20, ±24, ±30, ±35 deg). The unified RBF model is evaluated at 1-deg increments from -35 to +35 deg.

## Requirements

Tested with MATLAB R2024b. The main workflow uses:

- Curve Fitting Toolbox (`fit`, `poly44`)
- Statistics and Machine Learning Toolbox (`pdist2` and statistical comparisons)

The final MAE plotting routine uses `swtest` when available; otherwise it falls back to MATLAB's paired `ttest` logic.

## Main scripts

### Unified RBF model

Run:

```matlab
run_global_rbf_plot
```

The checked-in options are near the top of the script:

```matlab
visualize_rbf = true;
run_final_evaluation = true;
moment_positive_zero = false;
save_rbf_model = false;
```

The script:

1. loads the preprocessed Camargo and Molinaro data;
2. arranges each signal on a common phase-by-slope grid;
3. fits full ascent and full descent fourth-order polynomial surfaces;
4. merges the two domains with Gaussian RBF interpolation;
5. evaluates the unified model against the AB reference slopes; and
6. optionally generates the manuscript MAE comparisons.

Set `save_rbf_model = true` to write:

```text
outputs/global_rbf/RBF_models.mat
outputs/global_rbf/AB_refs.mat
```

`RBF_models.mat` contains the continuous model structures used by the downstream impedance-parameterization repository.

### Local polynomial comparison

Run:

```matlab
run_local_fits_plot
```

Choose the signal at the top of the script:

```matlab
target_joint     = "knee";      % "hip", "knee", or "ankle"
target_state     = "stance";    % "stance" or "swing"
target_biomech   = "angle_dot"; % "angle", "moment", "angle_dot", "angle_dot_norm"
target_direction = "both";      % "ascending", "descending", or "both"
fit_type         = "poly44";
visualize        = true;
```

Not every joint/state/signal combination is present in the source datasets. For example, joint moments are modeled over stance only.

## Terrain partitions

The local-fit comparison uses the same terrain partitions as the manuscript:

- **Full ascent:** level walking + ramp ascent + stair ascent
- **Full descent:** level walking + ramp descent + stair descent
- **Leave-all-ramps-out:** level walking + stairs
- **Leave-all-stairs-out:** level walking + ramps
- **Global polynomial:** all available terrain conditions

The selected full-ascent and full-descent polynomial surfaces are subsequently unified with the Gaussian RBF model.

## Example analyses

The defaults reproduce the repository's current analysis workflow. The following examples are useful for exploring the released data without modifying the core functions.

### 1. Knee stance angle

```matlab
target_joint     = "knee";
target_state     = "stance";
target_biomech   = "angle";
target_direction = "both";
```

This is useful for inspecting heel-contact behavior and the transition from ramps to stairs.

### 2. Ankle stance moment

```matlab
target_joint     = "ankle";
target_state     = "stance";
target_biomech   = "moment";
target_direction = "both";
```

This highlights where a single global polynomial loses fidelity relative to the partitioned models.

### 3. Hip stance angular velocity

```matlab
target_joint     = "hip";
target_state     = "stance";
target_biomech   = "angle_dot";
target_direction = "both";
```

Use `angle_dot_norm` instead to inspect the phase-normalized derivative representation.

### 4. Ascent-only knee swing angle

```matlab
target_joint     = "knee";
target_state     = "swing";
target_biomech   = "angle";
target_direction = "ascending";
```

This isolates the level-walking/ramp-ascent/stair-ascent partition.

### 5. Compare original and normalized angular velocity

Run the same joint/state combination twice, changing only:

```matlab
target_biomech = "angle_dot";
```

to

```matlab
target_biomech = "angle_dot_norm";
```

The normalized derivative is constructed from the phase-normalized angle trajectory and aligned to the common 101-sample phase grid.

### 6. Change visualization without changing the model

`plot_overrides` in `run_local_fits_plot.m` can modify selected display settings:

```matlab
plot_overrides = struct();
plot_overrides.global = struct( ...
    'view', [25 20], ...
    'zlim', [-20 100]);
```

Unspecified plotting fields retain their defaults.

### 7. Test a different RBF regularization value

The manuscript configuration uses:

```matlab
r_coeff = 1e-8;
```

inside `src/global/evaluate_all_biomechanics_with_RBF.m`. A user can test a larger value such as `1e-6` to examine the tradeoff between interpolation fidelity and numerical regularization. Changing this value is exploratory and will not reproduce the manuscript results.

### 8. Inspect the optional stance-moment onset adjustment

`run_global_rbf_plot.m` defines:

```matlab
moment_positive_zero = false;
```

Setting it to `true` activates the optional moment-onset adjustment in `merge_RBF.m`. The manuscript/default RBF results use the checked-in setting.

## Outputs

`run_global_rbf_plot.m` can produce:

```text
outputs/global_rbf/
├─ RBF_models.mat
├─ AB_refs.mat
├─ combined_global_kinematics.png
├─ combined_global_kinetics.png
├─ combined_global_angle_dot.png
├─ combined_global_angle_dot_norm.png
├─ combined_local_kinematics.png
├─ combined_local_kinetics.png
├─ combined_local_angle_dot.png
└─ combined_local_angle_dot_norm.png
```

The `.mat` files are written when `save_rbf_model = true`. Plot files are generated by the final evaluation path.

## Code organization

```text
run_global_rbf_plot.m
run_local_fits_plot.m

data/
  AB_avgDat_Camargo.mat
  AB_avgDat_Molinaro.mat

src/
  io/          data loading and signal selection
  core/        polynomial fitting, RBF interpolation, and model evaluation
  global/      unified RBF model construction
  local/       partitioned polynomial comparisons
  evaluation/  manuscript MAE comparisons

outputs/
  global_rbf/
```

Both runner scripts add `src/` recursively to the MATLAB path.

## References

- Camargo J, Ramanathan A, Flanagan W, Young AJ. *A comprehensive, open-source dataset of lower limb biomechanics in multiple conditions of stairs, ramps, and level-ground ambulation and transitions.* Journal of Biomechanics. 2021;119:110320.
- Molinaro DD, Kang I, Young AJ. *Estimating human joint moments unifies exoskeleton control, reducing user effort.* Science Robotics. 2024;9(88):eadi8852.
- Buhmann MD. *Radial basis functions.* Acta Numerica. 2000;9:1-38.
