function slopes = get_terrain_slope_sets()

%{
Terrain subsets used by the biomechanics models.

All values are terrain angles in degrees. The full set matches the
preprocessed AB datasets. The local subsets preserve the original model
definitions used for ramp/stair and cross-direction comparisons.

Output fields:
  slopes.full
  slopes.ascent.full
  slopes.ascent.full_with_RD
  slopes.ascent.ramp
  slopes.ascent.stair
  slopes.descent.full
  slopes.descent.full_with_RA
  slopes.descent.ramp
  slopes.descent.stair
%}

    slopes = struct();

    slopes.full = [-35, -30, -24, -20, ...
                   -11, -9, -7, -5, 0, ...
                    5, 7, 9, 11, ...
                    20, 24, 30, 35];

    slopes.ascent = struct();
    slopes.ascent.full = [0, 5, 7, 9, 11, 20, 24, 30, 35];
    slopes.ascent.full_with_RD = [-11, -9, -7, -5, 0, ...
                                   5, 7, 9, 11, ...
                                   20, 24, 30, 35];
    slopes.ascent.ramp = [0, 5, 7, 9, 11];
    slopes.ascent.stair = [0, 20, 24, 30, 35];

    slopes.descent = struct();
    slopes.descent.full = [-35, -30, -24, -20, -11, -9, -7, -5, 0];
    slopes.descent.full_with_RA = [-35, -30, -24, -20, ...
                                   -11, -9, -7, -5, 0, ...
                                    5, 7, 9, 11];
    slopes.descent.ramp = [-11, -9, -7, -5, 0];
    slopes.descent.stair = [-35, -30, -24, -20, 0];
end
