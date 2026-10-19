function [sorted_surf, sorted_slope_continuous] = leave_slopes_out( ...
    target_2D_surf, original_slope_points, sorted_slope_points)

%{
target_2D_surf: The original 2D surface data you want to fit to a
continuous function. 
For this application, define the surface to have
slope information in columns, phase information in rows
 e.g. 101 x 19 matrix

original_slope_points: discretely defined slope points from opensource data
 e.g. [-35, -30, -24, -20, -11, -9, ..., 9, 11, 20, 24, 30, 35]

sorted_slope_points: discretely filled slope range
 e.g. [-35, -24, -20, -11, -9, ... , 0, ..., 24, 35]
%}

% Sanity check block
slopes_in_surf = size(target_2D_surf, 2);
slopes_in_points = length(original_slope_points);

sorted_surf=[];
sorted_slope_continuous=[];

if slopes_in_surf ~= slopes_in_points
    disp("Check if dimensions are matching between slope definition and your surface. Terminating")

    return
% else
%     disp("Dimensions match")
end

for slope_id = 1:slopes_in_points
    target_slope = original_slope_points(slope_id);
    if ismember(target_slope, sorted_slope_points)
        % disp("Including")
        sorted_surf = [sorted_surf, target_2D_surf(:, slope_id)];

        % target_slope
    end
    % sorted_slope_points
end

min_slope = min(sorted_slope_points);
max_slope = max(sorted_slope_points);

%% The continuous meshgrid will ignore the effect of leave-one-slope-out validation
sorted_slope_continuous = linspace(min_slope, max_slope, max_slope-min_slope + 1);

return
end