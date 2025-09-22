function [] = parse_pipeline_parameters(APP, txt_filename, txt_filepath)
%% function = parse_pipeline_parameters(APP, txt_filename, txt_filepath)
%
% Author: Gabriel J Kowalczyk (gjk20@pitt.edu)
% Date: April 2021
% 
% Description: 'parse_pipeline_parameters' is a function
% which runs when the user clicks on the 'Browse...' button in the output 
% directory panel of the main pipeline GUI. It returns nothing, but updates 
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
% . txt file loc to update - APP.settings_file_display
% . displaying actual settings - APP.settings_textbox
%

param_file_string_identifier = '#LEELABPIPELINE';

prev_dir = cd(txt_filepath);
txt_file_id = fopen(txt_filename);

description_arr = {};

item_counter = 1;
while ~feof(txt_file_id)
    
    line_contents = fgetl(txt_file_id);
    
    if item_counter==1
        if ~strcmp(line_contents, param_file_string_identifier)
            warning('Error. Selected parameter text file does not contain pipeline header.');
            return;
        end
    else
        description_arr = cat(1,description_arr,{char(line_contents)});
    end
    item_counter = item_counter + 1;
    
end

cd(prev_dir);

% update parameter file location
APP.settings_file_display.String = char(fullfile(txt_filepath, txt_filename));
APP.settings_file_display.Enable = 'inactive';

% assign string directory 
APP.settings_textbox.String = description_arr;
APP.settings_textbox.Enable = 'inactive';
APP.settings_textbox.Max = length(description_arr);

% actually update the pipeline structures
update_pipeline_parameters(APP);

%
%%%
%%%%%
%%%
%