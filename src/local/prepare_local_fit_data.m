function data = prepare_local_fit_data(targetSurface, slopes, targetDirection)

%{
Arrange one biomechanics surface by terrain subset.

Inputs:
  targetSurface   phase x slope matrix on slopes.full
  slopes          structure from get_terrain_slope_sets()
  targetDirection "ascending", "descending", or "both"

Output:
  data.(subset).surf        selected experimental surface
  data.(subset).sortedSlope continuous evaluation slope vector
  data.(subset).slopePoints discrete terrain points defining that subset
%}

    targetDirection = lower(string(targetDirection));

    validDirections = ["ascending", "descending", "both"];
    if ~any(targetDirection == validDirections)
        error('targetDirection must be "ascending", "descending", or "both".');
    end

    if size(targetSurface, 2) ~= numel(slopes.full)
        error([ ...
            'targetSurface must have one column per full terrain slope. ' ...
            'Expected %d columns, received %d.'], ...
            numel(slopes.full), size(targetSurface, 2));
    end

    data = struct();
    data.full = local_select_subset(targetSurface, slopes.full, slopes.full);

    if targetDirection == "ascending" || targetDirection == "both"
        data.ascent_full = local_select_subset( ...
            targetSurface, slopes.full, slopes.ascent.full);
        data.ascent_full_with_RD = local_select_subset( ...
            targetSurface, slopes.full, slopes.ascent.full_with_RD);
        data.ascent_ramp = local_select_subset( ...
            targetSurface, slopes.full, slopes.ascent.ramp);
        data.ascent_stair = local_select_subset( ...
            targetSurface, slopes.full, slopes.ascent.stair);
    end

    if targetDirection == "descending" || targetDirection == "both"
        data.descent_full = local_select_subset( ...
            targetSurface, slopes.full, slopes.descent.full);
        data.descent_full_with_RA = local_select_subset( ...
            targetSurface, slopes.full, slopes.descent.full_with_RA);
        data.descent_ramp = local_select_subset( ...
            targetSurface, slopes.full, slopes.descent.ramp);
        data.descent_stair = local_select_subset( ...
            targetSurface, slopes.full, slopes.descent.stair);
    end
end

function subset = local_select_subset(targetSurface, fullSlopes, subsetSlopes)

    [subset.surf, subset.sortedSlope] = leave_slopes_out( ...
        targetSurface, fullSlopes, subsetSlopes);

    subset.slopePoints = subsetSlopes;
end
