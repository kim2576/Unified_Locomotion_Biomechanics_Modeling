function fit = fit_local_biomechanics_models(data, targetDirection, fitType)

%{
Fit global and local polynomial surfaces.

Inputs:
  data            structure from prepare_local_fit_data()
  targetDirection "ascending", "descending", or "both"
  fitType         MATLAB surface fit type, e.g. "poly44"

Output:
  fit.<subset>.model   fitted MATLAB model object
  fit.<subset>.fitted  model evaluated over the full continuous
                       terrain-slope domain

Notes:
  - Each model is fitted only to the discrete terrain points stored in
    data.<subset>.slopePoints.
  - Every fitted surface is evaluated over data.full.sortedSlope. This
    preserves the original comparison workflow, where local models are
    propagated across the full terrain domain before evaluation.
  - manual_offset is intentionally fixed at zero to preserve the current
    package behavior.
%}

    if nargin < 3 || isempty(fitType)
        fitType = "poly44";
    end

    targetDirection = lower(string(targetDirection));

    validDirections = ["ascending", "descending", "both"];
    if ~any(targetDirection == validDirections)
        error('targetDirection must be "ascending", "descending", or "both".');
    end

    if ~isfield(data, 'full') || ...
            ~isfield(data.full, 'sortedSlope') || ...
            ~isfield(data.full, 'surf') || ...
            ~isfield(data.full, 'slopePoints')
        error('data.full is incomplete. Use prepare_local_fit_data() first.');
    end

    evaluationSlope = data.full.sortedSlope;
    fit = struct();

    %% Full-domain model is always required - the baseline for both ascending and descending comparisons.
    fit.full = local_fit_subset(data.full, evaluationSlope, fitType);

    if targetDirection == "ascending" || targetDirection == "both"
        ascentFields = [ ...
            "ascent_full", ...
            "ascent_full_with_RD", ...
            "ascent_ramp", ...
            "ascent_stair"];

        fit = local_fit_fields(fit, data, ascentFields, evaluationSlope, fitType);
    end

    if targetDirection == "descending" || targetDirection == "both"
        descentFields = [ ...
            "descent_full", ...
            "descent_full_with_RA", ...
            "descent_ramp", ...
            "descent_stair"];

        fit = local_fit_fields(fit, data, descentFields, evaluationSlope, fitType);
    end
end

function fit = local_fit_fields(fit, data, fieldNames, evaluationSlope, fitType)

    for i = 1:numel(fieldNames)
        fieldName = char(fieldNames(i));

        if ~isfield(data, fieldName)
            error('Required local-fit data subset is missing: %s', fieldName);
        end

        fit.(fieldName) = local_fit_subset( ...
            data.(fieldName), evaluationSlope, fitType);
    end
end

function fitResult = local_fit_subset(subset, evaluationSlope, fitType)

    requiredFields = {'surf', 'slopePoints'};
    for i = 1:numel(requiredFields)
        if ~isfield(subset, requiredFields{i})
            error('Local-fit subset is missing required field: %s', ...
                requiredFields{i});
        end
    end

    manualOffset = 0;

    [fitResult.model, fitResult.fitted] = piecewise_2dpoly( ...
        subset.surf, ...
        subset.slopePoints, ...
        evaluationSlope, ...
        fitType, ...
        manualOffset);
end
