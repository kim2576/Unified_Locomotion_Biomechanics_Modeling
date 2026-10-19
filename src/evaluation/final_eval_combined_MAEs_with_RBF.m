function results_all = final_eval_combined_MAEs_with_RBF( ...
    target_biomechanics_total, ...
    moment_positive_zero, ...
    savedir)

%% Plot options for RBF evaluation
plot_option_full = struct('visualize', false, ...
    'xlim', [-40 40], 'ylim', [0 120], 'zlim', [-75 75], ...
    'view', [20, 30], 'clim', [-75 75]);

plot_option_ascent = struct('visualize', false, ...
    'xlim', [0 40], 'ylim', [0 120], 'zlim', [-75 75], ...
    'view', [-20, 30], 'clim', [-75 75]);

plot_option_descent = struct('visualize', false, ...
    'xlim', [-40 0], 'ylim', [0 120], 'zlim', [-75 75], ...
    'view', [20, 30], 'clim', [-75 75]);

%% Evaluate knee/ankle only
varList = {
    'avg_knee_angle_stance_total'
    'avg_knee_angle_swing_total'
    'avg_ankle_angle_stance_total'
    'avg_ankle_angle_swing_total'
    'avg_knee_moment_stance_total'
    'avg_ankle_moment_stance_total'
};

results_all = struct;

for i = 1:numel(varList)
    name = varList{i};

    if ~isfield(target_biomechanics_total, name)
        warning('%s not found. Skipping.', name);
        continue
    end

    results_all.(name) = evaluate_selected_biomechanics_with_RBF( ...
        target_biomechanics_total.(name), 10e-8, ...
        plot_option_full, ...
        plot_option_ascent, ...
        plot_option_descent, ...
        moment_positive_zero);
end

%% Kinematics
kinematicNames = {
    'avg_knee_angle_stance_total',  'Knee stance'
    'avg_knee_angle_swing_total',   'Knee swing'
    'avg_ankle_angle_stance_total', 'Ankle stance'
    'avg_ankle_angle_swing_total',  'Ankle swing'
};

plot_combined_MAE_comparison(results_all, kinematicNames, ...
    'local', 'Kinematic local model comparison', ...
    'MAE angle (deg)', [0 11]);
set(gcf, 'Units', 'normalized');
set(gcf, 'OuterPosition', [0 0 1 1]);   % Full screen
drawnow;
exportgraphics(gcf, fullfile(savedir, 'combined_local_kinematics.png'), ...
    'Resolution', 300);

plot_combined_MAE_comparison(results_all, kinematicNames, ...
    'global', 'Kinematic global model comparison', ...
    'MAE angle (deg)', [0 11]);
set(gcf, 'Units', 'normalized');
set(gcf, 'OuterPosition', [0 0 1 1]);   % Full screen
drawnow;
exportgraphics(gcf, fullfile(savedir, 'combined_global_kinematics.png'), ...
    'Resolution', 300);

%% Kinetics
kineticNames = {
    'avg_knee_moment_stance_total',  'Knee stance'
    'avg_ankle_moment_stance_total', 'Ankle stance'
};

plot_combined_MAE_comparison(results_all, kineticNames, ...
    'local', 'Kinetic local model comparison', ...
    'MAE moment (Nm/kg)', [0 0.4]);
set(gcf, 'Units', 'normalized');
set(gcf, 'OuterPosition', [0 0 1 1]);   % Full screen
drawnow;
exportgraphics(gcf, fullfile(savedir, 'combined_local_kinetics.png'), ...
    'Resolution', 300);

plot_combined_MAE_comparison(results_all, kineticNames, ...
    'global', 'Kinetic global model comparison', ...
    'MAE moment (Nm/kg)', [0 0.4]);
set(gcf, 'Units', 'normalized');
set(gcf, 'OuterPosition', [0 0 1 1]);   % Full screen
drawnow;
exportgraphics(gcf, fullfile(savedir, 'combined_global_kinetics.png'), ...
    'Resolution', 300);

end


function plot_combined_MAE_comparison(results_all, nameLabelPairs, ...
    comparisonType, figTitle, yLabelText, yLimits)

directions = {'ascent', 'descent'};

groupLabels = {};
meanMat = [];
stdMat = [];
pMat = [];

%% Universal model color map
% 1 = RBF
% 2 = Full modes
% 3 = Full local
% 4 = Leave-ramp
% 5 = Leave-stair
modelNames = { ...
    'RBF-Unified', ...
    'Global Polynomial', ...
    'Best Partitioned Polynomial', ...
    'Leave-ramp', ...
    'Leave-stair'};

% modelNames = { ...
%     'RBF', ...
%     'Full modes', ...
%     'Full local', ...
%     'Leave-ramp', ...
%     % 'Leave-stair'
%     };

% 
% cmap = [
%     0.20 0.45 0.85;    % RBF
%     0.90 0.55 0.15;    % Full modes
%     0.20 0.65 0.35;    % Full local
%     0.75 0.25 0.25;    % Leave-ramp
%     0.55 0.35 0.75;    % Leave-stair
% ];

cmap = [
    [167 232 255]/255;        % RBF (#00B0F0)

    [90 90 90]/255;         % Full modes - dark grey
    [0 176 240]/255;      % Full local - light grey

    0.75 0.25 0.25;         % Leave-ramp
    0.55 0.35 0.75;         % Leave-stair
];

%% Select model order
switch comparisonType
    case 'local'
        % After S(3)=[]:
        % 3 = Full local
        % 4 = Leave-ramp
        % 5 = Leave-stair
        dataIdx  = [3 4 5];
        colorIdx = [3 4 5];

    case 'global'
        % After S(3)=[]:
        % 1 = RBF
        % 2 = Full modes
        % 3 = Full local
        dataIdx  = [1 2 3];
        colorIdx = [1 2 3];

    otherwise
        error('comparisonType must be either local or global.');
end

%% Gather means, stds, and p-values
for i = 1:size(nameLabelPairs, 1)
    fieldName = nameLabelPairs{i,1};
    baseLabel = nameLabelPairs{i,2};

    if ~isfield(results_all, fieldName)
        warning('%s not found in results_all. Skipping.', fieldName);
        continue
    end

    R = results_all.(fieldName);

    for d = 1:numel(directions)
        direction = directions{d};

        switch direction
            case 'ascent'
                S = R.similarities_ascent;
                dirLabel = 'asc';

            case 'descent'
                S = R.similarities_descent;
                dirLabel = 'desc';
        end

        S(3) = [];

        groupMean = zeros(1, numel(dataIdx));
        groupStd  = zeros(1, numel(dataIdx));

        for k = 1:numel(dataIdx)
            vals = S{dataIdx(k)};
            groupMean(k) = mean(vals);
            groupStd(k)  = std(vals);
        end

        meanMat = [meanMat; groupMean];
        stdMat  = [stdMat; groupStd];
        groupLabels{end+1} = [baseLabel ' ' dirLabel];

        %% Statistics only for global model comparison
        if strcmp(comparisonType, 'global')
            % Bar 1 = RBF
            % Bar 2 = Full modes
            % Bar 3 = Full local
            %
            % Paired tests:
            % RBF vs Full modes
            % RBF vs Full local
            p1 = paired_test_pvalue(S{dataIdx(1)}, S{dataIdx(2)});
            p2 = paired_test_pvalue(S{dataIdx(1)}, S{dataIdx(3)});
        else
            p1 = nan;
            p2 = nan;
        end

        pMat = [pMat; p1 p2];
    end
end

%% Plot
figure; hold on;
fig = gcf;
fig.Units = 'inches';
fig.Position = [1 1 10 4.5];

ymin = yLimits(1);
ymax = yLimits(2);
barTop = ymax * 0.9;

meanPlot = meanMat;
offscaleMask = meanMat > ymax;
meanPlot(offscaleMask) = barTop;

bh = bar(meanPlot, 'grouped');

for k = 1:numel(bh)
    bh(k).FaceColor = 'flat';
    bh(k).CData = repmat(cmap(colorIdx(k),:), size(meanPlot,1), 1);
end

%% Error bars and offscale markers
for k = 1:numel(bh)
    x = bh(k).XEndPoints;

    visibleIdx = ~offscaleMask(:,k);

    errorbar(x(visibleIdx), meanMat(visibleIdx,k), stdMat(visibleIdx,k), ...
        '.k', 'LineStyle', 'none', 'LineWidth', 1.0);

    offIdx = find(offscaleMask(:,k));

    for ii = offIdx'
        plot(x(ii), barTop, '^k', ...
            'MarkerSize', 8, ...
            'MarkerFaceColor', 'k');

        text(x(ii), barTop, ...
            sprintf('%.1f', meanMat(ii,k)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontSize', 24, ...
            'Color', [0.85 0.3 0.3]);
    end
end

%% Significance stars only for global comparison
if strcmp(comparisonType, 'global')
    for g = 1:size(meanPlot,1)

        % Comparison 1: RBF vs Full modes
        add_sig_star(gca, bh, g, 1, 2, pMat(g,1), yLimits, 1);

        % Comparison 2: RBF vs Full local
        add_sig_star(gca, bh, g, 1, 3, pMat(g,2), yLimits, 2);
    end
end

%% Axis formatting
ylim([ymin ymax]);
ylabel(yLabelText);
title(figTitle);

set(gca, ...
    'XTick', 1:numel(groupLabels), ...
    'XTickLabel', groupLabels, ...
    'FontSize', 24);

xtickangle(35);
xlim([0.5, numel(groupLabels) + 0.5]);

%% Universal 5-color legend
h = gobjects(1, numel(modelNames));

for k = 1:numel(modelNames)
    h(k) = bar(nan, nan, ...
        'FaceColor', cmap(k,:), ...
        'EdgeColor', 'k');
end

lgd = legend(h, modelNames, ...
    'Location', 'northoutside', ...
    'Orientation', 'horizontal', ...
    'NumColumns', 3, ...
    'Box', 'off');

lgd.FontSize = 16;

box off;
hold off;

end


function p = paired_test_pvalue(x, y)

x = x(:);
y = y(:);

valid = ~isnan(x) & ~isnan(y);
x = x(valid);
y = y(valid);

if numel(x) < 3
    p = nan;
    return
end

d = x - y;

try
    [h_norm, ~] = swtest(d);

    if h_norm == 0
        [~, p] = ttest(x, y);
    else
        p = signrank(x, y);
    end
catch
    [~, p] = ttest(x, y);
end

end


function starText = p_to_star(p)

if isnan(p)
    starText = '';
elseif p < 0.001
    starText = '***';
elseif p < 0.01
    starText = '**';
elseif p < 0.05
    starText = '*';
else
    starText = '';
end

end


function add_sig_star(ax, bh, groupIdx, barA, barB, p, yLimits, level)

starText = p_to_star(p);

if isempty(starText)
    return
end

ymin = yLimits(1);
ymax = yLimits(2);
yrange = ymax - ymin;

x1 = bh(barA).XEndPoints(groupIdx);
x2 = bh(barB).XEndPoints(groupIdx);

y1 = bh(barA).YData(groupIdx);
y2 = bh(barB).YData(groupIdx);

% baseY = max([y1, y2]);
% 
% lineY = baseY + (0.1 + 0.07*(level-1)) * yrange;
% textY = lineY + 0.2 * yrange;
% 
% % Keep annotation inside axis
% if textY > ymax
%     % lineY = ymax - (0.12 - 0.04*(level-1)) * yrange;
%     lineY = ymax - (0.14 - 0.045*(level-1)) * yrange;
%     textY = lineY + 0.2 * yrange;
% end

baseY = max([y1, y2]);

starOffset    = 0.01 * yrange;
% starOffset    = 0;
bracketOffset = 0.4 + 0.01*(level-1);

lineY = baseY + bracketOffset * yrange;
textY = lineY + starOffset;

% If too high, shift BOTH down together
shift = max(0, textY - (ymax - 0.02*yrange));

lineY = lineY - shift;
textY = textY - shift;

tickH = 0.012 * yrange;

plot(ax, [x1 x1 x2 x2], ...
    [lineY-tickH lineY lineY lineY-tickH], ...
    '-k', 'LineWidth', 1.0);

text(ax, mean([x1 x2]), textY, starText, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'FontSize', 36, ...
    'Color', 'red');

end
