function [] = confirm_input_arguments(hand, evt, APP)
%% function = confirm_input_arguments(hand, evt, APP)
%
% Author: Gabriel J Kowalczyk (gjk20@pitt.edu)
% Date: April 2021
% 
% Description: 'confirm_input_arguments' is a uicontrol callback function
% which runs when the user clicks on the 'CONFIRM VALID INPUT ARGUMENTS' 
% button in the main pipeline GUI. It returns nothing, but updates 
% the pipeline GUI in various ways, here passed into the function as 'APP'.
% 
% Input:
%     - hand: uicontrol handle for PIPELINE.output_dir_select
%     - evt: user interaction click
%     - APP: PIPELINE application structure, contains references to all
%       GUI components and additional data
% 
% Output: 
%     N/A
%
% Additional notes:
% . input image files - APP.input_textbox
% . output directory exists - APP.output_dir_display

% pull pipeline operations structure
pipeline_operations = getappdata(APP.MAIN,'pipeline_operations');

IMAGES_REQUIRED = 0;
if pipeline_operations.RUN_DNEMO || pipeline_operations.RUN_CELLPOSE
    IMAGES_REQUIRED = 1;
end

% check input textbox has valid images
image_filenames = APP.input_textbox.String;
if isempty(image_filenames) && IMAGES_REQUIRED
    warning('Warning. No images in selected folder / input folder not selected.');
    return;
end

% check output directory is selected
output_dir_loc = APP.output_dir_display.String;
if isempty(output_dir_loc)
    warning('Warning. No results folder selected.');
    return;
end

% check if Python3 environment properly set up

if pipeline_operations.RUN_CELLPOSE
    bool_flag = check_python_environ();
    if ~bool_flag 
        warning('Warning. Python location file not found.');
        return;
    end
end

APP.start_button.Enable = 'on';

%
%%%
%%%%%
%%%
%