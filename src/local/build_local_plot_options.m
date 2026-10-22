function plotOptions = build_local_plot_options( ...
    targetJoint, targetBiomech, visualize, overrides)
%{
BUILD_LOCAL_PLOT_OPTIONS
Create visualization settings for local polynomial-fit comparisons.

Inputs:
targetJoint   : "hip", "knee", or "ankle"
targetBiomech : "angle" or "moment"
visualize     : logical visualization switch
overrides     : optional partial structure with fields
                   .global, .ascent, and/or .descent

Output:
plotOptions   : complete plot-option structure expected by
                   local_polyfit_comparison/evaluate_model.

The function centralizes presentation defaults so the runner only needs
to define what biomechanics should be analyzed. Any values supplied in
overrides replace the corresponding defaults while unspecified values
are retained.
%}
    if nargin < 4 || isempty(overrides)
        overrides = struct();
    end

    targetJoint   = lower(string(targetJoint));
    targetBiomech = lower(string(targetBiomech));

    zlim_use = local_get_zlim(targetJoint, targetBiomech);

    plotOptions.global = struct( ...
        'visualize', visualize, ...
        'xlim', [-35 35], ...
        'ylim', [0 100], ...
        'zlim', zlim_use, ...
        'view', [40 30], ...
        'clim', [0 2]);

    plotOptions.ascent = struct( ...
        'visualize', visualize, ...
        'xlim', [0 35], ...
        'ylim', [0 100], ...
        'zlim', zlim_use, ...
        'view', [40 30], ...
        'clim', [0 2]);

    plotOptions.descent = struct( ...
        'visualize', visualize, ...
        'xlim', [-35 0], ...
        'ylim', [0 100], ...
        'zlim', zlim_use, ...
        'view', [40 30], ...
        'clim', [0 2]);

    %% Velocity surfaces include signed data, so use a symmetric color axis.
    if targetBiomech == "angle_dot" || targetBiomech == "angle_dot_norm"
        plotOptions.global.clim = zlim_use;
        plotOptions.ascent.clim = zlim_use;
        plotOptions.descent.clim = zlim_use;
    end

    %% Preserve the presentation used by the original final local runner for its default knee-angle example.
    if targetJoint == "knee" && targetBiomech == "angle"
        plotOptions.global.xlim = [-40 40];
        plotOptions.ascent.xlim = [0 40];
        plotOptions.descent.xlim = [-40 0];

        plotOptions.global.zlim = [-10 100];
        plotOptions.ascent.zlim = [-10 100];
        plotOptions.descent.zlim = [-10 100];

        plotOptions.global.view = [15 10];
        plotOptions.ascent.view = [15 10];
        plotOptions.descent.view = [15 10];

        plotOptions.global.clim = [-10 100];
        plotOptions.ascent.clim = [-10 100];
        plotOptions.descent.clim = [-10 100];
    end

    sectionNames = ["global", "ascent", "descent"];
    for i = 1:numel(sectionNames)
        sectionName = sectionNames(i);
        sectionField = char(sectionName);

        if isfield(overrides, sectionField)
            plotOptions.(sectionField) = local_merge_struct( ...
                plotOptions.(sectionField), overrides.(sectionField));
        end
    end
end

function zlim_use = local_get_zlim(targetJoint, targetBiomech)

    if targetBiomech == "moment"
        if targetJoint == "hip"
            zlim_use = [-0.75 1];
        else
            zlim_use = [-1 2];
        end
    elseif targetBiomech == "angle"
        if targetJoint == "hip"
            zlim_use = [-75 75];
        elseif targetJoint == "knee"
            zlim_use = [-10 90];
        elseif targetJoint == "ankle"
            zlim_use = [-40 40];
        else
            zlim_use = [-30 30];
        end
    elseif targetBiomech == "angle_dot" || targetBiomech == "angle_dot_norm"
        % Shared symmetric angular-velocity axis; can be overridden by runner.
        if targetJoint == "hip"
            zlim_use = [-550 550];
        elseif targetJoint == "knee"
            zlim_use = [-700 700];
        else
            zlim_use = [-550 550];
        end
    else
        zlim_use = [-1 1];
    end
end

function merged = local_merge_struct(base, override)
    merged = base;

    fields = fieldnames(override);
    for i = 1:numel(fields)
        merged.(fields{i}) = override.(fields{i});
    end
end
