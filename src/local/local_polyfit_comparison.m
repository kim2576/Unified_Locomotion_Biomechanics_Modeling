function results = local_polyfit_comparison( ...
    camargo_data_struct, molinaro_data_struct, ...
    targetJoint, targetState, targetBiomech, ...
    targetDirection, fitType, visualize, plotOverrides)

%{
Compare global polynomial fitting vs. local polynomial fitting
for unified locomotion biomechanics across slope and gait phase.

Inputs:
  camargo_data_struct   : Camargo AB reference structure
  molinaro_data_struct  : Molinaro AB reference structure
  targetJoint           : "hip", "knee", or "ankle"
  targetState           : "stance" or "swing"
  targetBiomech         : "moment" or "angle"
  targetDirection       : "ascending", "descending", or "both"
  fitType               : e.g., "poly44"
  visualize             : true or false
  plotOverrides         : optional partial/full visualization settings;
                           missing values are filled with package defaults

Output:
  results               : structure containing arranged data, fitted models,
                          evaluations, and summary tables
%}
    if nargin < 7 || isempty(fitType)
        fitType = "poly44";
    end

    if nargin < 8 || isempty(visualize)
        visualize = false;
    end
    
    if nargin < 9 || isempty(plotOverrides)
        plotOverrides = struct();
    end    

    targetJoint     = lower(string(targetJoint));
    targetState     = lower(string(targetState));
    targetBiomech   = lower(string(targetBiomech));
    targetDirection = lower(string(targetDirection));

    %% Terrain definitions and target-data arrangement
    slopes = get_terrain_slope_sets();

    targetSurface = select_biomechanics_surface( ...
        camargo_data_struct, molinaro_data_struct, ...
        targetJoint, targetState, targetBiomech);

    data = prepare_local_fit_data( ...
        targetSurface, slopes, targetDirection);

    %% Polynomial fitting
    fit = fit_local_biomechanics_models( ...
        data, targetDirection, fitType);

    %% Set evaluation options
    plotOptions = build_local_plot_options( ...
        targetJoint, targetBiomech, visualize, plotOverrides);

    plot_option_global = plotOptions.global;
    plot_option_ascent = plotOptions.ascent;
    plot_option_descent = plotOptions.descent;

    %% Evaluate models    
    eval_global = struct();
    eval_ascent = struct();
    eval_descent = struct();

    legendAdded = false;

    %% Global full-range visualization/evaluation
    if targetDirection == "both"
    
        plot_option = configure_biomechanics_surface_plot( ...
            plot_option_global, targetJoint, targetState, targetBiomech, ...
            "Global Polynomial");

        [eval_global.full.model, eval_global.full.similarity] = evaluate_model( ...
            data.full.surf, slopes.full, ...
            fit.full.fitted, data.full.sortedSlope, plot_option);
    
        if visualize && ~legendAdded
            legend({'Model', 'AB ref'}, ...
                'Location', 'best', ...
                'FontSize', 36);
            legendAdded = true;
        end
    
    end

    if targetDirection == "ascending" || targetDirection == "both"

        plot_option = configure_biomechanics_surface_plot( ...
            plot_option_ascent, targetJoint, targetState, targetBiomech, ...
            "Global Polynomial");

        [eval_ascent.full.model, eval_ascent.full.similarity] = evaluate_model( ...
            data.ascent_full.surf, slopes.ascent.full, ...
            fit.full.fitted, data.full.sortedSlope, plot_option);        

        % Add legend only once
        if visualize && ~legendAdded
            legend({'Model', 'AB ref'}, ...
                'Location', 'best', ...
                'FontSize', 36);
            legendAdded = true;
        end        

        plot_option = configure_biomechanics_surface_plot( ...
            plot_option_ascent, targetJoint, targetState, targetBiomech, ...
            "Full Ascent + Ramp Descent");

        [eval_ascent.ascent_full_with_RD.model, eval_ascent.ascent_full_with_RD.similarity] = evaluate_model( ...
            data.ascent_full.surf, slopes.ascent.full, ...
            fit.ascent_full_with_RD.fitted, data.full.sortedSlope, plot_option);

        plot_option = configure_biomechanics_surface_plot( ...
            plot_option_ascent, targetJoint, targetState, targetBiomech, ...
            "Full Ascent");

        [eval_ascent.ascent_full.model, eval_ascent.ascent_full.similarity] = evaluate_model( ...
            data.ascent_full.surf, slopes.ascent.full, ...
            fit.ascent_full.fitted, data.full.sortedSlope, plot_option);

        plot_option = configure_biomechanics_surface_plot( ...
            plot_option_ascent, targetJoint, targetState, targetBiomech, ...
            "Leave-all-stairs-out");

        [eval_ascent.ascent_ramp.model, eval_ascent.ascent_ramp.similarity] = evaluate_model( ...
            data.ascent_full.surf, slopes.ascent.full, ...
            fit.ascent_ramp.fitted, data.full.sortedSlope, plot_option);

        plot_option = configure_biomechanics_surface_plot( ...
            plot_option_ascent, targetJoint, targetState, targetBiomech, ...
            "Leave-all-ramps-out");

        [eval_ascent.ascent_stair.model, eval_ascent.ascent_stair.similarity] = evaluate_model( ...
            data.ascent_full.surf, slopes.ascent.full, ...
            fit.ascent_stair.fitted, data.full.sortedSlope, plot_option);

    end

    if targetDirection == "descending" || targetDirection == "both"

        plot_option = configure_biomechanics_surface_plot( ...
            plot_option_descent, targetJoint, targetState, targetBiomech, ...
            "Global Polynomial");

        [eval_descent.full.model, eval_descent.full.similarity] = evaluate_model( ...
            data.descent_full.surf, slopes.descent.full, ...
            fit.full.fitted, data.full.sortedSlope, plot_option);

        plot_option = configure_biomechanics_surface_plot( ...
            plot_option_descent, targetJoint, targetState, targetBiomech, ...
            "Full Descent + Ramp Ascent");

        [eval_descent.descent_full_with_RA.model, eval_descent.descent_full_with_RA.similarity] = evaluate_model( ...
            data.descent_full.surf, slopes.descent.full, ...
            fit.descent_full_with_RA.fitted, data.full.sortedSlope, plot_option);

        plot_option = configure_biomechanics_surface_plot( ...
            plot_option_descent, targetJoint, targetState, targetBiomech, ...
            "Full Descent");

        [eval_descent.descent_full.model, eval_descent.descent_full.similarity] = evaluate_model( ...
            data.descent_full.surf, slopes.descent.full, ...
            fit.descent_full.fitted, data.full.sortedSlope, plot_option);

        plot_option = configure_biomechanics_surface_plot( ...
            plot_option_descent, targetJoint, targetState, targetBiomech, ...
            "Leave-all-stairs-out");

        [eval_descent.descent_ramp.model, eval_descent.descent_ramp.similarity] = evaluate_model( ...
            data.descent_full.surf, slopes.descent.full, ...
            fit.descent_ramp.fitted, data.full.sortedSlope, plot_option);

        plot_option = configure_biomechanics_surface_plot( ...
            plot_option_descent, targetJoint, targetState, targetBiomech, ...
            "Leave-all-ramps-out");

        [eval_descent.descent_stair.model, eval_descent.descent_stair.similarity] = evaluate_model( ...
            data.descent_full.surf, slopes.descent.full, ...
            fit.descent_stair.fitted, data.full.sortedSlope, plot_option);

    end

    %% Create summary tables
    summary_global = local_make_summary(eval_global);
    summary_ascent = local_make_summary(eval_ascent);
    summary_descent = local_make_summary(eval_descent);

    %% Set output structure
    results = struct();

    results.targetJoint = targetJoint;
    results.targetState = targetState;
    results.targetBiomech = targetBiomech;
    results.targetDirection = targetDirection;
    results.fitType = fitType;

    results.slopes = slopes;
    results.slope_full = slopes.full;  % backward-compatible alias
    results.data = data;
    results.fit = fit;

    results.eval_global = eval_global;
    results.eval_ascent = eval_ascent;
    results.eval_descent = eval_descent;

    results.summary_global = summary_global;
    results.summary_ascent = summary_ascent;
    results.summary_descent = summary_descent;

    if targetDirection == "ascending" || targetDirection == "both"
        disp("===== ASCENDING MODEL COMPARISON =====")
        disp(summary_ascent)
    end

    if targetDirection == "descending" || targetDirection == "both"
        disp("===== DESCENDING MODEL COMPARISON =====")
        disp(summary_descent)
    end

end

%% Create summary table
function summaryTable = local_make_summary(evalStruct)

    names = fieldnames(evalStruct);

    summaryTable = table();

    if isempty(names)
        return;
    end

    for i = 1:numel(names)
        name = names{i};

        summaryTable.Model{i,1} = name;
        summaryTable.MeanSimilarity(i,1) = mean( ...
            evalStruct.(name).similarity, 'omitnan');
        summaryTable.StdSimilarity(i,1) = std( ...
            evalStruct.(name).similarity, 'omitnan');
    end

end