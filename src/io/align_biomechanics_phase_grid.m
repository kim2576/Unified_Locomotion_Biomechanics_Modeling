function surface = align_biomechanics_phase_grid(rawData, fieldName)
%ALIGN_BIOMECHANICS_PHASE_GRID Standardize trajectories to 101 phase samples.
% Input: slope-by-phase (17x101 for original signals; 17x100 for
% finite-difference angle_dot_norm). Output: phase-by-slope (101x17).
%
% Each diff(angle,1,2) value represents an interval whose center is
% 0.5, 1.5, ..., 99.5 percent of the original 0:100% stance/swing grid.
% Interpolate those midpoint values to the common 0:100% grid, using
% constant endpoint extension (do not extrapolate unstable derivatives).
% The original data_struct arrays are not modified.

    if nargin < 2
        fieldName = 'biomechanics';
    end
    nPhase = size(rawData, 2);
    if nPhase == 101
        surface = rawData';
    elseif nPhase == 100 && contains(string(fieldName), 'angle_dot') && endsWith(string(fieldName), '_norm')
        phaseMid = 0.5:1:99.5;
        phaseQuery = 0:100;
        phaseQuery = min(max(phaseQuery, phaseMid(1)), phaseMid(end));
        surface = interp1(phaseMid, rawData', phaseQuery, 'linear');
    else
        error('align_biomechanics_phase_grid:UnexpectedSize', ...
            'Unexpected %d phase samples in %s. Expected 101, or 100 for angle_dot_norm.', ...
            nPhase, char(string(fieldName)));
    end
    assert(size(surface, 1) == 101, ...
        'Phase alignment must return 101 normalized samples.');
end
