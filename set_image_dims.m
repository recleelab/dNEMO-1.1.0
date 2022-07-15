function [] = set_image_dims(hand, evt, APP)
%% <placeholder>
%

IMG = getappdata(APP.MAIN,'IMG');

curr_img_dims = IMG.getCurrDims();

import_prompts = {'Number of Channels (C)',...
                  'Number of 3D slices (Z)',...
                  'Number of timepoints (T)'};
default_values = {num2str(curr_img_dims(1)),...
                  num2str(curr_img_dims(2)),...
                  num2str(curr_img_dims(3))};
some_dims = [1, 40];
some_title = 'Set Image Dimensions';

user_answer = inputdlg(import_prompts,...
                       some_title,...
                       some_dims,...
                       default_values);

% confirm answers will actually work before resetting, inform user of
% success / failure depending on fit

num_img_frames = prod(curr_img_dims);

user_c = num2str(user_answer{1});
user_z = num2str(user_answer{2});
user_t = num2str(user_answer{3});

if user_c*user_z*user_t ~= num_img_frames
    msgbox('Warning -- dimensions supplied by user do not fit image. Unable to set new image dimensions.');
else
    msgbox('Successfully reset image dimensions.');
    IMG.C = user_c;
    IMG.Z = user_z;
    IMG.T = user_t;
    IMG = IMG.setCurrFrame(APP.film_slider.Value);
    setappdata(APP.MAIN,'IMG',IMG);
    display_call(hand, evt, APP);
end

%
%%%
%%%%%
%%%
%