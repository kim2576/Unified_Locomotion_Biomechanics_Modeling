%% VALIDATE_ANGLE_DOT_INPUTS
% Fast input-only checks for both original and averaged-angle derivatives.
% No polynomial fitting, pdist2, or RBF solve is required.
clear;
clc;
project_root = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(project_root, 'src')));
[C, M] = load_preprocessed_biomechanics(fullfile(project_root, 'data'));
T = build_target_biomechanics(C, M);

for joint = ["knee", "hip", "ankle"]
    if joint == "ankle"
        input = M; % Already ordered by ascending slope in loader.
    else
        input = C;
    end
    for state = ["stance", "swing"]
        original = char(joint + "_angle_dot_" + state);
        derivative = [original '_norm'];
        assert(isfield(input, original) && isfield(input, derivative), ...
            'Missing angular-velocity field for %s %s.', joint, state);
        assert(isequal(size(input.(original)), [17 101]));
        assert(isequal(size(input.(derivative)), [17 100]));
        angle = input.(char(joint + "_angle_" + state));
        expected = diff(angle, 1, 2) * 100/60 * 100;
        diffMagnitude = abs(expected - input.(derivative));
        storedDerivative = input.(derivative);
        valid = (diffMagnitude < 1e-8) | ...
            (isnan(expected) & isnan(storedDerivative));
        assert(all(valid(:)), ...
            'Normalized angular velocity does not match angle derivative.');
        for suffix = ["", "_norm"]
            fieldName = original + suffix;
            key = char("avg_" + fieldName + "_total");
            assert(isfield(T, key), 'Missing modeled input %s.', key);
            assert(isequal(size(T.(key)), [101 17]));
            fprintf('PASS %-43s  input %s  model %s\n', ...
                key, mat2str(size(input.(char(fieldName)))), ...
                mat2str(size(T.(key))));
        end
    end
end
fprintf('\nPASS: All 12 angular-velocity inputs are correctly aligned.\n');
