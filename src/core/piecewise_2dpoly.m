function [fitModel, fitted_surf] = piecewise_2dpoly( ...
    target_2D_surf, original_slope_points, filled_slope_points, ...
    fitOrder, manual_offset)

%{
target_2D_surf: The original 2D surface data you want to fit to a
continuous function. 
For this application, define the surface to have
slope information in columns, phase information in rows
 e.g. 101 x 19 matrix

original_slope_points: discretely defined slope points from opensource data
 e.g. [-35, -30, -24, -20, -11, -9, ..., 9, 11, 20, 24, 30, 35]

filed_slope_points: continuously filled slope range, fit model propagates
into this domain
 e.g. [-35, -34, ... , 0, ..., 34, 35]

fitorder
 e.g. "poly44"

manual_offset
 e.g. 5 (degree), 0.1 (Nm/kg)

%}

% Default phase definition
normalized_phase = linspace(0,100,101);

%% 2D meshgrid of original (discrete) space -> Execute 2d poly fitting
[slopeGrid_discrete, phaseGrid_discrete] = meshgrid(original_slope_points, normalized_phase);

% Flatten XGrid into a column vector -> for model fitting
xData = slopeGrid_discrete(:); 
yData = phaseGrid_discrete(:);
zData = target_2D_surf(:);
fitModel = fit([xData, yData], zData, fitOrder);

%% 2D meshgrid of new (continuously interpolated) space -> Execute interpolation
[slopeGrid_interpolate, phaseGrid_interpolate] = meshgrid(filled_slope_points, normalized_phase);
fitted_surf = fitModel(slopeGrid_interpolate, phaseGrid_interpolate) - manual_offset;

return
end