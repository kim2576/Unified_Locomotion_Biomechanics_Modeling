function [model_matched, similarity] = evaluate_model( ...
    ref_AB_surf, ref_AB_slopes, ...
    fitted_surf, fitted_surf_slopes, plot_option)

%{
Evaluate a continuous surface at discrete reference slopes.

Inputs use the package convention:
  rows    = normalized gait phase
  columns = terrain slope

Output:
  model_matched : fitted trajectories at the reference slopes
  similarity    : legacy field name; contains per-slope MAE values

When visualization is enabled, the surface title reports the mean +/-
1 SD of the per-slope MAE values shown by this evaluation.
%}
    similarity = [];

    slopes_in_ref = length(ref_AB_slopes);

    %% Default phase definition
    normalized_phase = linspace(0,100,101);
    model_matched = [];

    [slopeGrid_discrete, phaseGrid_discrete] = ...
        meshgrid(ref_AB_slopes, normalized_phase);

    xData = slopeGrid_discrete(:);
    yData = phaseGrid_discrete(:);
    zData = ref_AB_surf(:);

    for slope_id = 1:slopes_in_ref
        target_slope = ref_AB_slopes(slope_id);

        if ismember(target_slope, fitted_surf_slopes)
            slope_id_in_fitted_surf = find( ...
                fitted_surf_slopes == target_slope, 1);

            MAE = mean(abs( ...
                ref_AB_surf(:, slope_id) - ...
                fitted_surf(:, slope_id_in_fitted_surf)), ...
                'omitnan');

            model_matched = [model_matched, ...
                fitted_surf(:, slope_id_in_fitted_surf)]; %#ok<AGROW>
            similarity = [similarity, MAE]; %#ok<AGROW>
        end
    end

    if plot_option.visualize
        disp("Visualization enabled")

        mae_mean = mean(similarity, 'omitnan');
        mae_std = std(similarity, 'omitnan');

        figure;
        surf(fitted_surf_slopes, normalized_phase, fitted_surf, ...
            'EdgeColor', 'k', 'FaceAlpha', 0.5);
        hold on
        grid off
        scatter3(xData, yData, zData, ...
            MarkerEdgeColor="red", SizeData=50, LineWidth=0.5)

        set(gca, fontsize=24)
        set(gcf, 'Position', [100, 100, 1100, 700])

        xlim(plot_option.xlim)
        ylim(plot_option.ylim)
        zlim(plot_option.zlim)
        view(plot_option.view)
        clim(plot_option.clim)

        xlabel(local_get_plot_field( ...
            plot_option, 'xlabel', 'Terrain slope (deg)'));
        ylabel(local_get_plot_field( ...
            plot_option, 'ylabel', 'Normalized phase (%)'));
        zlabel(local_get_plot_field( ...
            plot_option, 'zlabel', 'Biomechanics'));

        mainTitle = local_get_plot_field( ...
            plot_option, 'title', 'Biomechanics surface');
        maeUnit = local_get_plot_field(plot_option, 'mae_unit', '');

        pm = char(177);
        if strlength(string(maeUnit)) > 0
            maeText = sprintf( ...
                'MAE across slopes: %.3f %c %.3f %s (mean %c 1 SD)', ...
                mae_mean, pm, mae_std, maeUnit, pm);
        else
            maeText = sprintf( ...
                'MAE across slopes: %.3f %c %.3f (mean %c 1 SD)', ...
                mae_mean, pm, mae_std, pm);
        end

        title({mainTitle; maeText}, 'Interpreter', 'none');
        hold off
    end
end

function value = local_get_plot_field(plotOption, fieldName, defaultValue)
    if isfield(plotOption, fieldName) && ~isempty(plotOption.(fieldName))
        value = plotOption.(fieldName);
    else
        value = defaultValue;
    end
end
