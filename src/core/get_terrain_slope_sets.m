function slopes = get_terrain_slope_sets()

% Terrain-slope subsets used for the local polynomial comparisons.
% All values are in degrees.


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
