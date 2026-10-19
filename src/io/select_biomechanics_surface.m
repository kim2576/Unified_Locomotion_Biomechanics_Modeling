function surface = select_biomechanics_surface( ...
    camargo_data_struct, molinaro_data_struct, ...
    targetJoint, targetState, targetBiomech)

%{
Select one preprocessed biomechanics surface.

The returned matrix follows the modeling convention used throughout the
package:
  rows    = normalized gait phase
  columns = terrain slope

Inputs are selected using fields of the form
  (joint)_(biomech)_(state)
For Example - 
  knee_angle_stance
  ankle_moment_stance

The supplied local-fit workflow supports hip, knee, and ankle data.
%}
    targetJoint   = lower(string(targetJoint));
    targetState   = lower(string(targetState));
    targetBiomech = lower(string(targetBiomech));

    switch targetJoint
        case "knee"
            dataStruct = camargo_data_struct;
        case "hip"
            dataStruct = camargo_data_struct;            
        case "ankle"
            dataStruct = molinaro_data_struct;
        otherwise
            error('targetJoint must be "hip", "knee", or "ankle".');
    end

    fieldName = char(targetJoint + "_" + targetBiomech + "_" + targetState);

    if ~isfield(dataStruct, fieldName)
        error('Field not found in preprocessed data: %s', fieldName);
    end

    if ~isfield(dataStruct, 'slope_info')
        error('Selected preprocessed data structure is missing slope_info.');
    end

    rawData = dataStruct.(fieldName);
    nSlopes = numel(dataStruct.slope_info);

    if size(rawData, 1) ~= nSlopes
        error([ ...
            'Expected %s to be stored as slope x phase with %d slope rows, ' ...
            'but its size is %d x %d.'], ...
            fieldName, nSlopes, size(rawData, 1), size(rawData, 2));
    end

    %% Standard modeling orientation: phase x slope.
    surface = rawData';
end
