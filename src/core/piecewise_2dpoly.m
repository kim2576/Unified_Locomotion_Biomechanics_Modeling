function [fitModel, fitted_surf] = piecewise_2dpoly( ...
    target_2D_surf, original_slope_points, filled_slope_points, ...
    fitOrder, manual_offset)

% Fit a 2-D polynomial surface to discrete slope-phase data and evaluate
% it over the requested continuous terrain-slope domain.


% Phase grid
normalized_phase = linspace(0,100,101);

%% Fit on discrete slope-phase samples
[slopeGrid_discrete, phaseGrid_discrete] = meshgrid(original_slope_points, normalized_phase);

% Flatten for Curve Fitting Toolbox
xData = slopeGrid_discrete(:); 
yData = phaseGrid_discrete(:);
zData = target_2D_surf(:);
fitModel = fit([xData, yData], zData, fitOrder);

%% Evaluate on the continuous slope domain
[slopeGrid_interpolate, phaseGrid_interpolate] = meshgrid(filled_slope_points, normalized_phase);
fitted_surf = fitModel(slopeGrid_interpolate, phaseGrid_interpolate) - manual_offset;

return
end