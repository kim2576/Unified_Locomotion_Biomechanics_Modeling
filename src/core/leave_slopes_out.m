function [sorted_surf, sorted_slope_continuous] = leave_slopes_out( ...
    target_2D_surf, original_slope_points, sorted_slope_points)

% Select the requested discrete slope columns and return the continuous
% integer-slope domain spanning those selected conditions.


% Check slope dimensions
slopes_in_surf = size(target_2D_surf, 2);
slopes_in_points = length(original_slope_points);

sorted_surf=[];
sorted_slope_continuous=[];

if slopes_in_surf ~= slopes_in_points
    disp("Check if dimensions are matching between slope definition and your surface. Terminating")

    return
end

for slope_id = 1:slopes_in_points
    target_slope = original_slope_points(slope_id);
    if ismember(target_slope, sorted_slope_points)
        sorted_surf = [sorted_surf, target_2D_surf(:, slope_id)];
    end
end

min_slope = min(sorted_slope_points);
max_slope = max(sorted_slope_points);

%% Continuous evaluation domain
sorted_slope_continuous = linspace(min_slope, max_slope, max_slope-min_slope + 1);

return
end