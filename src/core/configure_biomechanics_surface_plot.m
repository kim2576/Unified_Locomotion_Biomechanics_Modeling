function plotOption = configure_biomechanics_surface_plot( ...
    plotOption, targetJoint, targetState, targetBiomech, modelLabel)

%{
Add descriptive surface-plot metadata.

This helper keeps biomechanics naming and units consistent across the
local polynomial-fit and global RBF visualization paths.

Inputs:
  plotOption    : existing visualization option structure
  targetJoint   : "hip", "knee", or "ankle"
  targetState   : "stance" or "swing"
  targetBiomech : "angle" or "moment"
  modelLabel    : descriptive model name shown in the title

Output fields added to plotOption:
  .title
  .xlabel
  .ylabel
  .zlabel
  .mae_unit
%}

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
