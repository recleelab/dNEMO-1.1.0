function [settings_gui_handle] = settings_gui(APP_PARAM)
%% <placeholder>
%

%
description_01 = strcat('The minimum number of slices a signal has to appear in within a 3D image for the signal to be considered valid.',...
    ' Minimum of 2, maximum of Z.');
description_02 = strcat('The number of pixels out from a signal before pixels can be considered as background when pulled for correction.',...
    ' Minimum of 0.');
description_03 = strcat('The number of pixels out from the signal + offset which are evaluated as local background when correcting signal intensity.',...
    ' Minimum of 1.');
description_04 = strcat('Method for determining which values are distributed when examining signal intensity.',...
    ' Select from using mean corrected intensity or summed corrected intensity.');
description_05 = strcat('Method for determining pixels used when describing signal size.',...
    ' Select from using pixels at the z-coordinate or pixels throughout the entire signal.');
description_06 = strcat('Level of kernel convolved with image to identify objects.',...
    ' Level 2 or higher is recommended, as Level 1 primarily captures white noise.');
description_07 = strcat('Overseg. check. Centroids detected w/in 3 pixels ',...
    ' of each other undergo additional check.');
%
SETTINGS.figure_handle = figure('units','normalized',...
                                'position',[0.225 0.3 0.6 0.45],...
                                'name','Update Settings',...
                                'resize','on',...
                                'numbertitle','off',...
                                'menubar','none');
%
SETTINGS.frame_limit_panel = uipanel('units','normalized',...
                                     'position',[0.01 0.8 0.48 0.175],...
                                     'title','Frame Limit');
%
SETTINGS.frame_limit_description = uicontrol('style','text',...
                                             'parent',SETTINGS.frame_limit_panel,...
                                             'units','normalized',...
                                             'position',[0.42 0.02 0.58 0.95],...
                                             'String',description_01);
%
SETTINGS.frame_limit_box = uicontrol('style','edit',...
                                     'parent',SETTINGS.frame_limit_panel,...
                                     'units','normalized',...
                                     'position',[0.08 0.2 0.24 0.6],...
                                     'enable','on',...
                                     'Tag','FRAME',...
                                     'String',num2str(APP_PARAM.FRAME_LIMIT));
%
SETTINGS.wav_level_panel = uipanel('units','normalized',...
                                   'position',[0.51 0.8 0.48 0.175],...
                                     'title','Wavelet Level');
%
SETTINGS.wav_level_description = uicontrol('style','text',...
                                           'parent',SETTINGS.wav_level_panel,...
                                           'units','normalized',...
                                           'position',[0.42 0.02 0.58 0.95],...
                                           'String',description_06);
%
SETTINGS.wav_level_box = uicontrol('style','edit',...
                                   'parent',SETTINGS.wav_level_panel,...
                                   'units','normalized',...
                                   'position',[0.08 0.2 0.24 0.6],...
                                   'enable','on',...
                                   'Tag','LEVEL',...
                                   'String',num2str(APP_PARAM.WAV_LEVEL));
%
SETTINGS.pixel_offset_panel = uipanel('units','normalized',...
                                      'position',[0.01 0.6 0.48 0.175],...
                                      'title','Pixel Offset');
% 
SETTINGS.pixel_offset_description = uicontrol('style','text',...
                                              'parent',SETTINGS.pixel_offset_panel,...
                                              'units','normalized',...
                                              'position',[0.42 0.02 0.58 0.95],...
                                              'String',description_02);
%
SETTINGS.pixel_offset_box = uicontrol('style','edit',...
                                      'parent',SETTINGS.pixel_offset_panel,...
                                      'units','normalized',...
                                      'position',[0.08 0.2 0.24 0.6],...
                                      'enable','on',...
                                      'Tag','OFF',...
                                      'String',num2str(APP_PARAM.NUM_PIX_OFF));
%
SETTINGS.pixel_background_panel = uipanel('units','normalized',...
                                          'position',[0.51 0.6 0.48 0.175],...
                                          'title','Pixel Background');
% 
SETTINGS.pixel_background_description = uicontrol('style','text',...
                                                  'parent',SETTINGS.pixel_background_panel,...
                                                  'units','normalized',...
                                                  'position',[0.42 0.02 0.58 0.95],...
                                                  'String',description_03);
%
SETTINGS.pixel_background_box = uicontrol('style','edit',...
                                          'parent',SETTINGS.pixel_background_panel,...
                                          'units','normalized',...
                                          'position',[0.08 0.2 0.24 0.6],...
                                          'enable','on',...
                                          'Tag','BG',...
                                          'String',num2str(APP_PARAM.NUM_PIX_BG));
%
SETTINGS.intensity_measure_panel = uipanel('units','normalized',...
                                           'position',[0.01 0.4 0.98 0.175],...
                                           'title','Signal Intensity');
%
SETTINGS.intensity_measure_description = uicontrol('style','text',...
                                                   'parent',SETTINGS.intensity_measure_panel,...
                                                   'units','normalized',...
                                                   'position',[0.42 0.02 0.58 0.95],...
                                                   'String',description_04);
%
SETTINGS.intensity_rb_group = uibuttongroup(SETTINGS.intensity_measure_panel,'units','normalized',...
                                                                             'visible','on',...
                                                                             'position',[0.01 0.02 0.4 0.95],...
                                                                             'bordertype','none');
%
SETTINGS.intensity_rb_01 = uicontrol(SETTINGS.intensity_rb_group,'style','radiobutton',...
                                                                 'units','normalized',...
                                                                 'position',[0.01 0.01 0.31 0.98],...
                                                                 'String','MEAN',...
                                                                 'Tag','AVG');
%
SETTINGS.intensity_rb_02 = uicontrol(SETTINGS.intensity_rb_group,'style','radiobutton',...
                                                                 'units','normalized',...
                                                                 'position',[0.34 0.01 0.31 0.98],...
                                                                 'String','SUM',...
                                                                 'Tag','SUM');
%
SETTINGS.intensity_rb_02 = uicontrol(SETTINGS.intensity_rb_group,'style','radiobutton',...
                                                                 'units','normalized',...
                                                                 'position',[0.67 0.01 0.31 0.98],...
                                                                 'String','MEDIAN',...
                                                                 'Tag','MED');
%
SETTINGS.size_measure_panel = uipanel('units','normalized',...
                                      'position',[0.01 0.2 0.98 0.175],...
                                      'title','Signal Size');
%
SETTINGS.size_measure_description = uicontrol('style','text',...
                                              'parent',SETTINGS.size_measure_panel,...
                                              'units','normalized',...
                                              'position',[0.42 0.02 0.58 0.95],...
                                              'String',description_05);
%
SETTINGS.size_rb_group = uibuttongroup(SETTINGS.size_measure_panel,'units','normalized',...
                                                                   'visible','on',...
                                                                   'position',[0.01 0.02 0.4 0.95],...
                                                                   'bordertype','none');
%
SETTINGS.size_rb_01 = uicontrol(SETTINGS.size_rb_group,'style','radiobutton',...
                                                       'units','normalized',...
                                                       'position',[0.01 0.01 0.48 0.98],...
                                                       'String','Z-coordinate Only',...
                                                       'Tag','ZCOORD');
%
SETTINGS.size_rb_02 = uicontrol(SETTINGS.size_rb_group,'style','radiobutton',...
                                                       'units','normalized',...
                                                       'position',[0.51 0.01 0.48 0.98],...
                                                       'String','Full Signal',...
                                                       'Tag','FULL');
%
% original panel dimensions: [0.01 0.01 0.48 0.175]
%
SETTINGS.overseg_panel = uipanel('units','normalized',...
                                 'position',[0.01 0.01 0.575 0.175],...
                                 'title','Oversegmentation');
%
SETTINGS.overseg_description = uicontrol('style','text',...
                                         'parent',SETTINGS.overseg_panel,...
                                         'units','normalized',...
                                         'position',[0.42 0.42 0.58 0.55],...
                                         'String',description_07);
%
SETTINGS.overseg_rb_group = uibuttongroup(SETTINGS.overseg_panel,...
                                         'units','normalized',...
                                         'visible','on',...
                                         'position',[0.01 0.02 0.4 0.95],...
                                         'bordertype','none',...
                                         'tag','OVERSEG');
%
SETTINGS.overseg_rb_01 = uicontrol(SETTINGS.overseg_rb_group,'style','radiobutton',...
                                   'units','normalized',...
                                   'position',[0.01 0.01 0.48 0.98],...
                                   'string','Yes',...
                                   'Tag','OVERSEG_YES');
%
SETTINGS.overseg_rb_02 = uicontrol(SETTINGS.overseg_rb_group,'style','radiobutton',...
                                   'units','normalized',...
                                   'position',[0.51 0.01 0.48 0.98],...
                                   'string','No',...
                                   'Tag','OVERSEG_NO');
%
SETTINGS.overseg_add_arg = uicontrol('style','edit',...
                                     'parent',SETTINGS.overseg_panel,...
                                     'units','normalized',...
                                     'position',[0.42 0.02 0.125 0.38],...
                                     'string','0.1',...
                                     'tag','OVERSEG_ADD_ARG');
%
SETTINGS.overseg_add_lbl = uicontrol('style','text',...
                                     'parent',SETTINGS.overseg_panel,...
                                     'units','normalized',...
                                     'position',[0.56 0.02 0.42 0.38],...
                                     'string','max-min percent diff',...
                                     'horizontalalignment','left');
%
SETTINGS.restore_button = uicontrol('style','push',...
                                    'units','normalized',...
                                    'position',[0.6 0.04 0.18 0.12],...
                                    'visible','on',...
                                    'enable','on',...
                                    'tag','RESTORE',...
                                    'String','Restore Default');
%
SETTINGS.finish_button = uicontrol('style','push',...
                                   'units','normalized',...
                                   'position',[0.8 0.04 0.18 0.12],...
                                   'visible','on',...
                                   'enable','on',...
                                   'tag','FINISH',...
                                   'String','Confirm Settings');
% 

set([SETTINGS.frame_limit_box,SETTINGS.pixel_offset_box,SETTINGS.pixel_background_box,SETTINGS.overseg_add_arg],'Callback',{@editbox_callback,APP_PARAM});
set(SETTINGS.finish_button,'callback',{@input_to_main, SETTINGS.figure_handle});
set(SETTINGS.figure_handle,'deletefcn',{@input_to_main, SETTINGS.figure_handle});
set(SETTINGS.figure_handle,'closerequestfcn',{@input_to_main, SETTINGS.figure_handle});

% returned value
settings_gui_handle = SETTINGS.figure_handle;

%
%%%
%%%%%
%%%
%

function [] = editbox_callback(hand,evt,APP_PARAM)
%% <placeholder>
%  

switch hand.Tag
    case 'FRAME'
        curr_val = str2num(hand.String);
        if curr_val < 1
            hand.String = num2str(2);
        end
    
    case 'OFF'
        curr_val = str2num(hand.String);
        if curr_val < 0
            hand.String = num2str(0);
        end
    
    case 'BG'
        curr_val = str2num(hand.String);
        if curr_val < 0
            hand.String = num2str(0);
        end
    
    case 'LEVEL'
        curr_val = str2num(hand.String);
        if curr_val < 1
            hand.String = num2str(2);
        end
    case 'OVERSEG_ADD_ARG'
        curr_val = str2num(hand.String);
        if curr_val < 0.1
            hand.String = num2str(0.1);
        end
        if curr_val > 0.9
            hand.String = num2str(0.9);
        end
end
        
%
%%%
%%%%%
%%%
%

function [] = input_to_main(hand, evt, figure_hand)
%% <placeholder>
%

% compile structure w/ relevant data
input_information = input_gui_info(figure_hand);
setappdata(figure_hand,'CURR_PARAM',input_information);

% handle clean up / shut down from 'settings_gui_call.m'
figure_hand.Name = 'shutting down';

%
%%%
%%%%%
%%%
%

function [parameter_struct] = input_gui_info(figure_hand)
%% <placeholder>
%

parameter_struct = struct;

% wavelet level
wav_edit = findobj(allchild(figure_hand),'Tag','LEVEL');
parameter_struct.WAV_LEVEL = str2num(wav_edit.String);

% frame limit
frame_edit = findobj(allchild(figure_hand),'Tag','FRAME');
parameter_struct.FRAME_LIMIT = str2num(frame_edit.String);

% oversegmentation
overseg_group = findobj(allchild(figure_hand),'Tag','OVERSEG');
overseg_rb = overseg_group.SelectedObject;
switch overseg_rb.Tag
    case 'OVERSEG_YES'
        parameter_struct.OVERSEG = 1;
    case 'OVERSEG_NO'
        parameter_struct.OVERSEG = 0;
end

overseg_additional_arg = findobj(allchild(figure_hand), 'Tag','OVERSEG_ADD_ARG');
parameter_struct.OVERSEG_MIN_MAX = num2str(overseg_additional_arg.String);

% number of pixels offset
offset_edit = findobj(allchild(figure_hand),'Tag','OFF');
parameter_struct.NUM_PIX_OFF = str2num(offset_edit.String);

% number of pixels background
bg_edit = findobj(allchild(figure_hand),'Tag','BG');
parameter_struct.NUM_PIX_BG = str2num(bg_edit.String);

% intensity measure
med_rb = findobj(allchild(figure_hand),'Tag','MED');
if med_rb.Value == 1
    parameter_struct.INT_MEASURE = 'MED';
end

sum_rb = findobj(allchild(figure_hand),'Tag','SUM');
if sum_rb.Value == 1
    parameter_struct.INT_MEASURE = 'SUM';
end

avg_rb = findobj(allchild(figure_hand),'Tag','AVG');
if avg_rb.Value == 1
    parameter_struct.INT_MEASURE = 'AVG';
end

% signal size measure
sig_rb_01 = findobj(allchild(figure_hand),'Tag','ZCOORD');
if sig_rb_01.Value == 1
    parameter_struct.SIG_MEASURE = 'ZCOORD';
end

sig_rb_02 = findobj(allchild(figure_hand),'Tag','FULL');
if sig_rb_02.Value == 1
    parameter_struct.SIG_MEASURE = 'FULL';
end

%
%%%
%%%%%
%%%
%