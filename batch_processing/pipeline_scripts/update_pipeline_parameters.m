function [] = update_pipeline_parameters(APP)
%% function update_pipeline_parameters(APP)
%
% Author: Gabriel J Kowalczyk (gjk20@pitt.edu)
% Date: April 2021
% 
% Description: 'update_pipeline_parameters()' accepts the GUI application
% structure and returns nothing, updating the text window 
% 'PIPELINE.settings_textbox' in order to relay to user updates made
% 
% Input:
%     - APP: PIPELINE application structure, contains references to all
%       GUI components and additional data
% 
% Output:
%     - N/A
% 
% Additional Notes:
% . text window containing fields - APP.settings_textbox
% 

% pull app structures
dnemo_param_struct = getappdata(APP.MAIN,'dnemo_param_struct');
dnemo_param_struct.FRAME_NO = 1;
cellpose_param_struct = getappdata(APP.MAIN,'cellpose_param_struct');
utrack_param_struct = getappdata(APP.MAIN,'utrack_param_struct');

% pull parameter strings
string_array = APP.settings_textbox.String;

for str_idx=1:length(string_array)
    
    next_string = string_array{str_idx};
    
    some_tokens = strsplit(next_string,'=');
    param_field_token = some_tokens{1};
    param_value_token = some_tokens{2};
    
    switch param_field_token
        case 'dnemo_wavelet-level'
            dnemo_param_struct.WAV_LEVEL = str2num(param_value_token);
        case 'dnemo_frame-limit'
            dnemo_param_struct.FRAME_LIMIT = str2num(param_value_token);
        case 'dnemo_oversegmentation'
            dnemo_param_struct.OVERSEG = str2num(param_value_token);
        case 'dnemo_oversegmentation-max-min-diff'
            %todo
        case 'dnemo_user-wavelet-threshold'
            dnemo_param_struct.USER_THRESH = str2num(param_value_token);
        case 'dnemo_pixel-offset'
            dnemo_param_struct.NUM_PIX_OFF = str2num(param_value_token);
        case 'dnemo_pixel-background'
            dnemo_param_struct.NUM_PIX_BG = str2num(param_value_token);
        case 'cellpose_rescale-dimensions'
            cellpose_param_struct.RESCALE = str2num(param_value_token);
        case 'cellpose_centroid-max-interframe-radius'
            cellpose_param_struct.INTERFRAME_RAD = str2num(param_value_token);
        case 'cellpose_cell-area-shift-threshold'
            cellpose_param_struct.AREA_THRESH = str2num(param_value_token);
        case 'utrack_min-search-radius'
            utrack_param_struct.MIN_RAD = str2num(param_value_token);
        case 'utrack_max-search-radius'
            utrack_param_struct.MAX_RAD = str2num(param_value_token);
        case 'utrack_length-for-classify'
            utrack_param_struct.CLASS_LEN = str2num(param_value_token);
        case 'utrack_allow-time-gap'
            utrack_param_struct.FRAME_GAP = str2num(param_value_token);
        case 'utrack_gap-penalty'
            utrack_param_struct.GAP_PENALTY = str2num(param_value_token);
        case 'utrack_amp-ratio-limit'
            sub_tokens = strsplit(param_value_token,';');
            utrack_param_struct.AMP_RATIO_LIM = [str2num(sub_tokens{1}) str2num(sub_tokens{2})];
        case 'utrack_brownian-scaling'
            sub_tokens = strsplit(param_value_token,';');
            utrack_param_struct.BROWN_SCALE = [str2num(sub_tokens{1}) str2num(sub_tokens{2})];
        case 'utrack_linear-scaling'
            sub_tokens = strsplit(param_value_token,';');
            utrack_param_struct.LIN_SCALE = [str2num(sub_tokens{1}) str2num(sub_tokens{2})];
        case 'utrack_intensity-measurement'
            utrack_param_struct.AMP_INT_ARG = param_value_token;
        case 'utrack_include-amplitude-std'
            utrack_param_struct.AMP_STD = str2num(param_value_token);
    end
    
end

setappdata(APP.MAIN,'dnemo_param_struct',dnemo_param_struct);
setappdata(APP.MAIN,'cellpose_param_struct',cellpose_param_struct);
setappdata(APP.MAIN,'utrack_param_struct',utrack_param_struct);

%
%%%
%%%%%
%%%
%