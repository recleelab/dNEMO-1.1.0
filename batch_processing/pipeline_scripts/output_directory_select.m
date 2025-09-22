function [] = output_directory_select(hand, evt, APP)
%% function = output_directory_select(hand, evt, APP)
%
% Author: Gabriel J Kowalczyk (gjk20@pitt.edu)
% Date: April 2021
% 
% Description: 'output_directory_select' is a uicontrol callback function
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
% . editbox displaying location - APP.output_dir_display
% . editbox displaying contents - APP.output_textbox

[output_dir] = uigetdir();
if output_dir ~= 0
    
    % display selected directory string
    APP.output_dir_display.String = output_dir;
    APP.output_dir_display.Enable = 'inactive';
	APP.output_textbox.Enable = 'inactive';
    
else
    
    % confirm current value w/in 'input_dir_display'
    current_display_string = APP.output_dir_display.String;
    if isempty(current_display_string)
        APP.output_dir_display.Enable = 'off';
    end
    
end

%
%%%
%%%%%
%%%
%