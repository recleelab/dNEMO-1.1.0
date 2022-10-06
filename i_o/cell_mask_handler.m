function [] = cell_mask_handler(hand, evt, APP)
%% <placeholder>
%

valid_args = '*.tif;*.tiff;*.TIF;*.TIFF;*.csv;*.CSV;*.xls;*.xlsx';
[mask_filename, mask_folderpath, ~] = uigetfile(valid_args,'Select cell mask input image');
if mask_filename
    
    % need image data
    IMG = getappdata(APP.MAIN,'IMG');
    num_frames = IMG.T;
    tmp_height = IMG.Height;
    
    curr_frame_no = IMG.CurrFrameNo;
    
    % need mask import parameters
    cellpose_param_struct = getappdata(APP.MAIN,'cellpose_param_struct');
    
    switch hand.Label
        case 'Import Cell Mask CSV/XLS'
            [import_polygon_list] = import_mask_spreadsheet(mask_filename, mask_folderpath, num_frames);
        case 'Import Cell Mask TIFF'
            % [import_polygon_list] = import_mask_tif(mask_filename, mask_folderpath, num_frames);
            % [import_polygon_list] = convert_mask_to_poly_objects(mask_folderpath, mask_filename);
            [import_polygon_list] = convert_mask_to_poly_objects_v2(mask_folderpath, mask_filename, cellpose_param_struct, tmp_height);
    end
    
    % confirmation popup
    if ~isempty(import_polygon_list)
        
        tmp_popup_figure = figure('units','normalized',...
                                  'menubar','none',...
                                  'position',[0.27 0.27 0.42 0.6]);
        tmp_popup_ax = axes(tmp_popup_figure);
        [mask_arr] = masks_from_tif(mask_folderpath, mask_filename, tmp_height);
        tmp_mask = mask_arr{curr_frame_no};
        imshow(imadjust(tmp_mask),'parent',tmp_popup_ax);
        
        mask_answer = questdlg('Finish import of input cell mask?', ...
                                'Cell Mask Import', 'Yes', 'No', 'No');
        cla(tmp_popup_ax);
        clf(tmp_popup_figure);
        if strcmp(mask_answer, 'No')
            return;
        end
    end
    
    
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
    
end

%
%%%
%%%%%
%%%
%