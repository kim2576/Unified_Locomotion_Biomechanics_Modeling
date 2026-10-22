%% RUN_LOCAL_FITS_PLOT
% Local polynomial-fit comparison runner.
%
% This script starts from the already-preprocessed biomechanics stored in
% ./data. Change only the analysis settings below to inspect a different
% joint, gait state, biomechanical quantity, or fitting direction.

clear;
close all;
clc;

%% Analysis settings
target_joint     = "knee";       % "hip", "knee", or "ankle"
target_state     = "stance";     % "stance" or "swing"
target_biomech   = "angle_dot";      % "angle", "moment", "angle_dot", "angle_dot_norm"
target_direction = "both";       % "ascending", "descending", or "both"
fit_type         = "poly44";
visualize        = true;

%% Project paths
project_root = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(project_root, 'src')));
data_dir = fullfile(project_root, 'data');

%% Load already-preprocessed biomechanics
[camargo_data_struct, molinaro_data_struct] = ...
    load_preprocessed_biomechanics(data_dir);

%% Optional visualization overrides
% Leave empty to use package defaults. Any supplied fields override only the
% corresponding defaults; all unspecified fields are retained.
plot_overrides = struct();
% Example:
% plot_overrides.global = struct('view', [25 20], 'zlim', [-20 100]);

%% Compare global and local polynomial fits
local_results = local_polyfit_comparison( ...
    camargo_data_struct, ...
    molinaro_data_struct, ...
    target_joint, ...
    target_state, ...
    target_biomech, ...
    target_direction, ...
    fit_type, ...
    visualize, ...
    plot_overrides);
