function [camargo_data_struct, molinaro_data_struct] = load_preprocessed_biomechanics(data_dir)

% Load the preprocessed Camargo and Molinaro biomechanics structures.
% Molinaro trajectory rows are reversed here to match ascending slope_info.

    if nargin < 1 || isempty(data_dir)
        error('A data directory must be provided.');
    end

    camargo_file = fullfile(data_dir, 'AB_avgDat_Camargo.mat');
    molinaro_file = fullfile(data_dir, 'AB_avgDat_Molinaro.mat');

    assert(isfile(camargo_file), 'Missing data file: %s', camargo_file);
    assert(isfile(molinaro_file), 'Missing data file: %s', molinaro_file);

    C = load(camargo_file, 'data_struct');
    M = load(molinaro_file, 'data_struct');

    assert(isfield(C, 'data_struct'), ...
        'AB_avgDat_Camargo.mat must contain data_struct.');
    assert(isfield(M, 'data_struct'), ...
        'AB_avgDat_Molinaro.mat must contain data_struct.');

    camargo_data_struct = C.data_struct;
    molinaro_data_struct = M.data_struct;

    expected_slopes = [-35 -30 -24 -20 -11 -9 -7 -5 0 5 7 9 11 20 24 30 35];

    assert(isfield(camargo_data_struct, 'slope_info'), ...
        'Camargo data_struct is missing slope_info.');
    assert(isfield(molinaro_data_struct, 'slope_info'), ...
        'Molinaro data_struct is missing slope_info.');

    assert(isequal(camargo_data_struct.slope_info(:)', expected_slopes), ...
        'Unexpected Camargo slope_info ordering.');
    assert(isequal(molinaro_data_struct.slope_info(:)', expected_slopes), ...
        'Unexpected Molinaro slope_info ordering.');

    %% Align Molinaro rows with ascending slope_info
    trajectory_fields = { ...
        'ankle_moment_stance', ...
        'ankle_angle_stance', ...
        'ankle_angle_swing', ...
        'ankle_angle_dot_stance', ...
        'ankle_angle_dot_swing', ...
        'ankle_angle_dot_stance_norm', ...
        'ankle_angle_dot_swing_norm', ...
        'ankle_force_v_stance', ...
        'ankle_force_h_stance'};

    for i = 1:numel(trajectory_fields)
        field_name = trajectory_fields{i};
        if isfield(molinaro_data_struct, field_name)
            value = molinaro_data_struct.(field_name);
            assert(size(value, 1) == numel(expected_slopes), ...
                'Expected %s to have one row per terrain slope.', field_name);
            molinaro_data_struct.(field_name) = flip(value, 1);
        end
    end
end
