%% RUN_GLOBAL_RBF_PLOT
% Build and visualize the unified RBF biomechanics model from preprocessed
% able-bodied biomechanics data.
%
% Required inputs:
%   data/AB_avgDat_Camargo.mat
%   data/AB_avgDat_Molinaro.mat
%
% Main outputs in the workspace:
%   target_biomechanics_total  - phase-by-slope biomechanics used for fitting
%   evaluation_result_total    - complete fitting/evaluation results
%   RBF_model_full             - compact RBF model structure for downstream use
%   stat_results_total         - optional MAE evaluation results

clear;
close all;
clc;

%% User options
visualize_rbf = true;
run_final_evaluation = true;
moment_positive_zero = false;
save_rbf_model = false;
% save_rbf_model = true;

%% Project paths
project_root = fileparts(mfilename('fullpath'));
src_dir = fullfile(project_root, 'src');
data_dir = fullfile(project_root, 'data');
output_dir = fullfile(project_root, 'outputs', 'global_rbf');

addpath(genpath(src_dir));

if ~isfolder(output_dir)
    mkdir(output_dir);
end

%% Load already-preprocessed biomechanics
[camargo_data_struct, molinaro_data_struct] = ...
    load_preprocessed_biomechanics(data_dir);

target_biomechanics_total = build_target_biomechanics( ...
    camargo_data_struct, molinaro_data_struct);

%% Build and visualize unified RBF biomechanics
evaluation_result_total = evaluate_all_biomechanics_with_RBF( ...
    target_biomechanics_total, visualize_rbf);

%% Create compact model structure for downstream controller derivation
RBF_model_full = build_rbf_model_struct(evaluation_result_total);

if save_rbf_model
    save(fullfile(output_dir, 'RBF_models.mat'), 'RBF_model_full');
    save(fullfile(output_dir, 'AB_refs.mat'), 'target_biomechanics_total');
end

%% Optional final MAE comparison
% This is downstream model evaluation and is not required to construct the
% unified RBF biomechanics surfaces.
if run_final_evaluation
    stat_results_total = final_eval_all_MAEs_with_RBF( ...
        target_biomechanics_total, ...
        moment_positive_zero, ...
        output_dir, ...
        evaluation_result_total);
end
