function [] = run_cellpose_from_dnemo(hand, evt, APP)
%% <placeholder>
%

% TEMP, going to pull from application
cellpose_param_struct = struct;
cellpose_param_struct.RESCALE = 200;
cellpose_param_struct.INTERFRAME_RAD = 250;
cellpose_param_struct.AREA_THRESH = 0.35;

% test to see that MATLAB can even call python3 from the command line
[py_bool_flag] = check_python_environ();

if ~py_bool_flag
    % issue setting environment -- file missing or problem connecting to
    % command line 
    error('Problem setting python environment in Matlab. Please check [os_python3_location.txt] in dNEMO folder to confirm correct locations of necessary files.');
end

init_dir = cd;
img = getappdata(APP.MAIN,'IMG');
img_filename = img.img_filename;
img_filepath = img.img_filepath;

% make temporary directory for processing through cellpose
mkdir('tmp_cellpose_processing');
addpath(fullfile(cd, 'tmp_cellpose_processing'));
process_this_dir = fullfile(cd, 'tmp_cellpose_processing');
cd(process_this_dir);

% make rescaled tif to order
output_filename = 'tmp_cellpose_input_rescale.tif';
for ff=1:img.T
    img = img.setCurrFrame(ff);
    tmp_frame = img.getCurrFrame();
    sum_project = sum(tmp_frame, 3);
    rescaled_factor = cellpose_param_struct.RESCALE./img.Height;
    rescaled_projection = imresize(sum_project, rescaled_factor);
    imwrite(uint16(rescaled_projection), output_filename, 'WriteMode','append');
end
if img.T==1
    img = img.setCurrFrame(ff);
    tmp_frame = img.getCurrFrame();
    sum_project = sum(tmp_frame, 3);
    rescaled_factor = cellpose_param_struct.RESCALE./img.Height;
    rescaled_projection = imresize(sum_project, rescaled_factor);
    imwrite(uint16(rescaled_projection), output_filename, 'WriteMode','append');
end

% return to original directory
cd(init_dir);

% first python string to command window
location_command_string = char(strcat('cd',{' '},init_dir));
assignin('base','location_command_string',location_command_string);
[err_flag1, cmd_out1] = system(location_command_string);
assignin('base','err_flag1',err_flag1);
assignin('base','cmd_out1',cmd_out1);

% second python string to command window
python_command_string = char(strcat('python3',{' '},'CellPoseBatchProcessing_mod_GJK.py',{' '},'''',process_this_dir,''''));
assignin('base','python_command_string',python_command_string);
[err_flag2, cmd_out2] = system(python_command_string);
assignin('base','err_flag2',err_flag2);
assignin('base','cmd_out2',cmd_out2);

if ~err_flag1 && ~err_flag2
    disp('success');
else
    disp('somethings not right');
end

% have a way to handle the single frame problem, but want to make sure this
% works up to this point -- basically swaps for single frame
prev_dir = cd(process_this_dir);
if img.T==1
    frame_01 = imread('tmp_cellpose_input_rescMasks.tif', 1);
    imwrite(uint16(frame_01),'tmp_cellpose_input_rescMasks.tif');
end
cd(prev_dir);

[import_polygon_list] = convert_mask_to_poly_objects_v2(process_this_dir, 'tmp_cellpose_input_rescMasks.tif', cellpose_param_struct, img.Height);
setappdata(APP.MAIN,'polygon_list',import_polygon_list);

% update cell signals
coordinate_spots_to_cells(APP);

% update keyframing map
APP.keyframing_map.Enable = 'on';
update_keyframe_data(APP);

% update cell selection
update_cell_selection_dropdown(APP);

% display call
cla(APP.ax2);
APP.cell_boundary_toggle.Value = 1;
display_call(hand, 1, APP);

% cleanup -- unfortunately, need to delete the created folder


%
%%%
%%%%%
%%%
%