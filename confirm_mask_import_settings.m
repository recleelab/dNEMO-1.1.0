function [] = confirm_mask_import_settings(hand, evt, APP)
%% <placeholder>
%

prev_cellpose_params = getappdata(APP.MAIN,'cellpose_param_struct');

import_prompts = {'Rescale factor; rescale to [x] pixels',...
                  'Interframe radius (in pixels)',...
                  'Shift in area threshold (value between [0,1])',...
                  '% of movie cell is present in (value between [0,1])',...
                  'Frame gap limit'};
default_values = {num2str(prev_cellpose_params.RESCALE),...
                  num2str(prev_cellpose_params.centroid_radius),...
                  num2str(prev_cellpose_params.area_percentage),...
                  num2str(prev_cellpose_params.min_frame_appear_percentage),...
                  num2str(prev_cellpose_params.gap_frame_limit)};
some_dims = [1, 40];
some_title = 'Mask Import Settings';

user_answer = inputdlg(import_prompts,...
                       some_title,...
                       some_dims,...
                       default_values);
                   
prev_cellpose_params.RESCALE = str2num(user_answer{1});
prev_cellpose_params.centroid_radius = str2num(user_answer{2});
prev_cellpose_params.area_percentage = str2num(user_answer{3});
prev_cellpose_params.min_frame_appear_percentage = str2num(user_answer{4});
prev_cellpose_params.gap_frame_limit = str2num(user_answer{5});

setappdata(APP.MAIN,'cellpose_param_struct',prev_cellpose_params);

%
%%%
%%%%%
%%%
%