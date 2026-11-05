function plotOption = configure_biomechanics_surface_plot( ...
    plotOption, targetJoint, targetState, targetBiomech, modelLabel)

% Add joint/state labels and units to surface-plot options.
% Used by both local polynomial and global RBF plots.


    targetJoint   = lower(string(targetJoint));
    targetState   = lower(string(targetState));
    targetBiomech = lower(string(targetBiomech));
    modelLabel    = string(modelLabel);

    jointLabel = local_title_case(targetJoint);
    stateLabel = local_title_case(targetState);

    switch targetBiomech
        case "angle"
            biomechLabel = "Angle";
            unitLabel = "deg";
        case "moment"
            biomechLabel = "Moment";
            unitLabel = "Nm/kg";
        case "angle_dot"
            biomechLabel = "Angular Velocity (original)";
            unitLabel = "deg/s";
        case "angle_dot_norm"
            biomechLabel = "Angular Velocity (normalized)";
            unitLabel = "deg/s";
        otherwise
            error('Unsupported targetBiomech: %s', targetBiomech);
    end

    plotOption.title = sprintf('%s %s %s - %s', ...
        jointLabel, stateLabel, biomechLabel, modelLabel);
    plotOption.xlabel = 'Terrain slope (deg)';
    plotOption.ylabel = sprintf('%s phase (%%)', stateLabel);
    plotOption.zlabel = sprintf('%s %s (%s)', ...
        jointLabel, lower(biomechLabel), unitLabel);
    plotOption.mae_unit = unitLabel;
end

function label = local_title_case(value)
    value = char(value);
    label = [upper(value(1)), value(2:end)];
end
