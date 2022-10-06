function [gui_handle] = cell_mask_handler_GUI(hand, evt, IMG)
%% <placeholder>
%
%
    % parameters for importing cell objects from masks / running cellpose
    cellpose_param_struct = struct;
    cellpose_param_struct.RESCALE = 200;
    cellpose_param_struct.centroid_radius = 50;
    cellpose_param_struct.area_percentage = 0.225;
    cellpose_param_struct.min_frame_appear_percentage = 0.12;
    cellpose_param_struct.gap_frame_limit = 9;
    
    % src_img = getappdata(APP.MAIN,'IMG');
    im_width = IMG.Width;
    im_height = IMG.Height;

    gui_handle = figure('units','normalized',...
                        'position',[0.15 0.18 0.74 0.62],...
                        'menubar','none',...
                        'name','Run Cellpose / Import Mask',...
                        'numbertitle','off',...
                        'resize','on');
    %
    src_img_axis = axes('parent',gui_handle,...
                        'units','normalized',...
                        'position',[0.01 0.04 0.58 0.94],...
                        'YDir','reverse',...
                        'XTick',[],...
                        'YTick',[],...
                        'Tag','AXISIMAGE');
    %
    mask_axis = axes('parent',gui_handle,...
                     'units','normalized',...
                     'position',[0.01 0.04 0.58 0.94],...
                     'YDir','reverse',...
                     'XTick',[],...
                     'YTick',[],...
                     'color','none',...
                     'XLimMode','manual',...
                     'YLimMode','manual',...
                     'hittest','on',...
                     'pickableparts','visible',...
                     'nextplot','add',...
                     'Tag','AXISOBJECT');
    %
    mov_slider = uicontrol('parent',gui_handle,...
                           'style','slide',...
                           'unit','normalized',...
                           'position',[0.01 0.005 0.58 0.025],...
                           'min',1,...
                           'max',1,...
                           'val',1,...
                           'visible','on',...
                           'enable','off',...
                           'Tag','MOVSLIDER');
    %
    cellpose_panel = uipanel('parent',gui_handle,...
                           'units','normalized',...
                           'position',[0.61 0.9 0.38 0.09],...
                           'Title','Import/Create Cell Mask');
    %
    cellpose_start_button = uicontrol('parent',cellpose_panel,...
                                      'style','push',...
                                      'units','normalized',...
                                      'position',[0.04 0.05 0.28 0.9],...
                                      'String','Run Cellpose',...
                                      'value',0,...
                                      'visible','on',...
                                      'enable','on');
    %
    import_mask_button = uicontrol('parent',cellpose_panel,...
                                   'style','push',...
                                   'units','normalized',...
                                   'position',[0.64 0.05 0.28 0.9],...
                                   'String','Import Mask',...
                                   'value',0,...
                                   'visible','on',...
                                   'enable','on');
    %
    cellpose_settings_confirm_button = uicontrol('parent',cellpose_panel,...
                                                 'style','push',...
                                                 'units','normalized',...
                                                 'position',[0.34 0.05 0.28 0.9],...
                                                 'String','Cellpose Settings',...
                                                 'value',0,...
                                                 'visible','on',...
                                                 'enable','on');
    %
    create_cell_object_panel = uipanel('parent',gui_handle,...
                                       'units','normalized',...
                                       'position',[0.61 0.65 0.38 0.24],...
                                       'Title','Create Cell Objects From Mask');
    %
    create_cell_object_settings_button = uicontrol('parent',create_cell_object_panel,...
                                                   'style','push',...
                                                   'units','normalized',...
                                                   'position',[0.04 0.7 0.295 0.24],...
                                                   'String','Cell Object Settings',...
                                                   'value',0,...
                                                   'enable','off');
    %
    create_cell_object_button = uicontrol('parent',create_cell_object_panel,...
                                          'style','push',...
                                          'units','normalized',...
                                          'position',[0.34 0.7 0.295 0.24],...
                                          'String','Create Objects From Mask',...
                                          'value',0,...
                                          'enable','off');
    %
    inheritance_algo_button = uicontrol('parent',create_cell_object_panel,...
                                        'style','push',...
                                        'units','normalized',...
                                        'position',[0.64 0.7 0.295 0.24],...
                                        'String','Run Inheritance Operation',...
                                        'value',0,...
                                        'enable','off');
    %
    object_display_panel = uipanel('parent',gui_handle,...
                                   'units','normalized',...
                                   'position',[0.61 0.4 0.38 0.24],...
                                   'Title','Control Object Display');
    %
    toggle_image = uicontrol('parent',object_display_panel,...
                             'style','radiobutton',...
                             'units','normalized',...
                             'position',[0.04 0.88 0.24 0.095],...
                             'String','Toggle Image',...
                             'Tag','TOGGLEIMAGE',...
                             'Value',1,...
                             'visible','on',...
                             'enable','off');
    %
    toggle_mask = uicontrol('parent',object_display_panel,...
                            'style','radiobutton',...
                            'units','normalized',...
                            'position',[0.32 0.88 0.24 0.095],...
                            'String','Toggle Mask',...
                            'Tag','TOGGLEMASK',...
                            'Value',0,...
                            'visible','on',...
                            'enable','off');
    %
    %% global variables
    %
    setappdata(gui_handle,'IMG',IMG);
    valid_mask_args = '*.tif;*.tiff;*.TIF;*.TIFF;*.csv;*.CSV;*.xls;*.xlsx';
    setappdata(gui_handle,'valid_mask_args',valid_mask_args);
    MASK = NaN;
    setappdata(gui_handle,'MASK',MASK);
    % setappdata(gui_handle,'IMAGE_AXIS',src_img_axis);
    setappdata(gui_handle,'cellpose_param_struct',cellpose_param_struct);
    
    %% axis, slider setup
    %
    % figure startup - axis sync
    axis_display_sync([], src_img_axis, mask_axis);
    
    % figure startup - movie slider
    T = IMG.getT();
    if T == 1
        mov_slider.Value = 1;
        mov_slider.Enable = 'off';
        mov_slider.Visible = 'off';
        mov_slider.Max = 1;
    else
        mov_slider.Min = 1;
        mov_slider.Max = T;
        mov_slider.SliderStep = [1/T 1/T];
        mov_slider.Enable = 'on';
        mov_slider.Visible = 'on';
    end
    
    %% callback assignment
    %
    mov_slider.Callback = {@CMH_refresh_gui, gui_handle};
    import_mask_button.Callback = {@CMH_import_mask, gui_handle};
    create_cell_object_settings_button.Callback = {@CMH_confirm_tracking_mat_settings, gui_handle};
    cellpose_settings_confirm_button.Callback = {@CMH_confirm_cellpose_rescale, gui_handle};
    set([toggle_image, toggle_mask],'Callback',{@CMH_img_mask_toggle_callback, gui_handle});
    create_cell_object_button.Callback = {@CMH_mask_to_poly_objects, gui_handle};
    
    %% startup
    %
    CMH_refresh_gui(mov_slider, [], gui_handle);
end
%
%%%
%%%%%
%%%
%
function [] = CMH_import_mask(hand, evt, CMH_GUI)
%% <placeholder>
%

    % prompt user for selecting mask input file
    [mask_filename, mask_filepath] = uigetfile(getappdata(CMH_GUI,'valid_mask_args'),'Select Mask Import File');
    if mask_filename==0
        return;
    end

    % determine mask input (for now, either TIF or CSV/XLSX)
    mask_filename_tokens = strsplit(mask_filename,'.');
    if any(strcmpi(mask_filename_tokens{end},{'tif','tiff'}))
        % TIF / TIFF
        MASK = masks_from_tif(mask_filepath, mask_filename);
        setappdata(CMH_GUI,'MASK',MASK);
    else
        % CSV / XLS / XLSX (confirm before operation
        % going to need to construct mask image from csv, xlsx file
        % TODO
    end
    
    % update image and mask toggles
    image_toggle_handle = findobj(allchild(CMH_GUI),'tag','TOGGLEIMAGE');
    image_toggle_handle.Enable = 'on';
    mask_toggle_handle = findobj(allchild(CMH_GUI),'tag','TOGGLEMASK');
    mask_toggle_handle.Enable = 'on';
    
    % enable polygon creation tools
    cell_object_panel = findobj(allchild(CMH_GUI),'title','Create Cell Objects From Mask');
    poly_creation_handles = allchild(cell_object_panel);
    for hh=1:length(poly_creation_handles)
        poly_creation_handles(hh).Enable = 'on';
        poly_creation_handles(hh).Visible = 'on';
    end
    
    % refresh to update GUI
    CMH_refresh_gui(hand, evt, CMH_GUI);
    
end
%
%%%
%%%%%
%%%
%
function [] = CMH_refresh_gui(hand, evt, CMH_GUI)
%% <placeholder>
%   
    mov_slider = findobj(allchild(CMH_GUI),'tag','MOVSLIDER');
    % assignin('base','mov_slider',mov_slider);
    frame_no = round(mov_slider.Value);
    assignin('base','frame_no',frame_no);
    
    image_axis = findobj(allchild(CMH_GUI),'tag','AXISIMAGE');
    assignin('base','image_axis',image_axis);
    
    image_toggle_handle = findobj(allchild(CMH_GUI),'tag','TOGGLEIMAGE');
    switch image_toggle_handle.Value
        case 1
            % image display
            IMG = getappdata(CMH_GUI,'IMG');
            IMG = IMG.setCurrFrame(frame_no);
            curr_frame = IMG.getCurrFrame();

            % TEMPORARY
            imshow(imadjust(IMG.getZProject()),'parent',image_axis);
            image_axis.Tag = 'AXISIMAGE';
            % END TEMPORARY

            %{
            displayed_frame = CMH_update_src_img_display(curr_frame, CMH_GUI);
            imshow(imadjust(displayed_frame));
            %}
        case 0
            % check if MASK has been imported / created
            MASK = getappdata(CMH_GUI,'MASK');
            if ~iscell(MASK)
                return;
            end
            
            % handle mask display
            imshow(imbinarize(MASK{frame_no}),'parent',image_axis);
            image_axis.Tag = 'AXISIMAGE';
    end

end
%
%%%
%%%%%
%%%
%
function [] = CMH_img_mask_toggle_callback(hand, evt, CMH_GUI)
%% <placeholder>
%
    
    mask_toggle = findobj(allchild(CMH_GUI),'tag','TOGGLEMASK');
    img_toggle = findobj(allchild(CMH_GUI),'tag','TOGGLEIMAGE');
    
    handle_tag = hand.Tag;
    assignin('base','handle_tag',handle_tag);
    
    switch handle_tag
        case 'TOGGLEMASK'
            if img_toggle.Value == 0 && mask_toggle.Value == 1
                % do nothing
            else
                img_toggle.Value = 0;
                mask_toggle.Value = 1;
            end
        case 'TOGGLEIMAGE'
            if img_toggle.Value == 1 && mask_toggle.Value == 0
                % do nothing
            else
                img_toggle.Value = 1;
                mask_toggle.Value = 0;
            end
    end
    
    CMH_refresh_gui(hand, evt, CMH_GUI);

end
%
%%%
%%%%%
%%%
%
function [] = CMH_confirm_tracking_mat_settings(hand, evt, CMH_GUI)
%% <placeholder>
%

    prev_cellpose_params = getappdata(CMH_GUI,'cellpose_param_struct');
    import_prompts = {'Interframe radius (in pixels)',...
                      'Shift in area threshold (value between [0,1])',...
                      '% of movie cell is present in (value between [0,1])',...
                      'Frame gap limit'};
    default_values = {num2str(prev_cellpose_params.centroid_radius),...
                      num2str(prev_cellpose_params.area_percentage),...
                      num2str(prev_cellpose_params.min_frame_appear_percentage),...
                      num2str(prev_cellpose_params.gap_frame_limit)};
    %{
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
    %}
    some_dims = [1, 40];
    some_title = 'Object Tracking Settings';

    user_answer = inputdlg(import_prompts,...
                           some_title,...
                           some_dims,...
                           default_values);

    % prev_cellpose_params.RESCALE = str2num(user_answer{1});
    prev_cellpose_params.centroid_radius = str2num(user_answer{1});
    prev_cellpose_params.area_percentage = str2num(user_answer{2});
    prev_cellpose_params.min_frame_appear_percentage = str2num(user_answer{3});
    prev_cellpose_params.gap_frame_limit = str2num(user_answer{4});

    setappdata(CMH_GUI,'cellpose_param_struct',prev_cellpose_params);
    
end
%
%%%
%%%%%
%%%
%
function [] = CMH_confirm_cellpose_rescale(hand, evt, CMH_GUI)
%% <placeholder>
%
    prev_cellpose_params = getappdata(CMH_GUI,'cellpose_param_struct');
    
    %
    import_prompts = {'Rescale factor; rescale to [x] pixels'};
    default_values = {num2str(prev_cellpose_params.RESCALE)};
    %}
    some_dims = [1, 40];
    some_title = 'Object Tracking Settings';

    user_answer = inputdlg(import_prompts,...
                           some_title,...
                           some_dims,...
                           default_values);

    prev_cellpose_params.RESCALE = str2num(user_answer{1});

    setappdata(CMH_GUI,'cellpose_param_struct',prev_cellpose_params);
    
end
%
%%%
%%%%%
%%%
%
function [] = CMH_mask_to_poly_objects(hand, evt, CMH_GUI)
%% <placeholder>
%
    mask_arr = getappdata(CMH_GUI,'MASK');
    cellpose_param_struct = getappdata(CMH_GUI,'cellpose_param_struct');
    [centroid_adj_mat, segmentation_arr] = create_tracking_mat_UPDATED(mask_arr, cellpose_param_struct);
    [polygon_list] = create_cell_segmentations_from_mask(mask_arr, centroid_adj_mat);
    
    % temporary, just to see what this bad boy looks like
    assignin('base','centroid_adj_mat',centroid_adj_mat);
    assignin('base','segmentation_arr',segmentation_arr);
    assignin('base','polygon_list',polygon_list);
    
end
%
%%%
%%%%%
%%%
%