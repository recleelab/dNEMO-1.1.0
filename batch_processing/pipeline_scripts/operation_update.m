function [] = operation_update(hand, evt, APP)
%% function = operation_update(hand, evt, APP)
%
% Author: Gabriel J Kowalczyk (gjk20@pitt.edu)
% Date: April 2021
% 
% Description: 'operation_update' is a uicontrol callback function
% which runs when the user clicks on either the 'Run dNEMO',
% 'Run Cellpose', or 'Run u-track' in the 'Operation Settings' panel 
% of the main pipeline GUI. It returns nothing, but updates the 
% pipeline GUI in various ways, here passed into the function as 'APP'.
% 
% Input:
%     - hand: uicontrol handle for any of the following:
%             PIPELINE.dnemo_checkbox
%             PIPELINE.cellpose_checkbox
%             PIPELINE.utrack_checkbox
%     - evt: user interaction click
%     - APP: PIPELINE application structure, contains references to all
%       GUI components and additional data
% 
% Output: 
%     N/A
%

handle_string = hand.String;

pipeline_operations = getappdata(APP.MAIN,'pipeline_operations');

switch handle_string
    case 'Run dNEMO'
        pipeline_operations.RUN_DNEMO = hand.Value;
    case 'Run Cellpose'
        pipeline_operations.RUN_CELLPOSE = hand.Value;
    case 'Run u-track'
        pipeline_operations.RUN_UTRACK = hand.Value;
end

setappdata(APP.MAIN,'pipeline_operations',pipeline_operations);

%
%%%
%%%%%
%%%
%