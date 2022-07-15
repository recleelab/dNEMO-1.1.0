function [] = polygon_set_range(hand, evt, APP)
%% removes segmentation keyframes over some frame range
%

polygon_list = getappdata(APP.MAIN,'polygon_list');

frame_no = APP.film_slider.Value;
frame_max = APP.film_slider.Max;
cell_idx = APP.created_cell_selection.Value - 1;

line_01 = 'Enter the lower bound of range of keyframe segmentations to remove. Segmentation for this frame and subsequent frames (inclusive) will be set using nearest previous keyframe.';
line_02 = 'Enter the upper bound of range of keyframe segmentations to remove, or 0 to go to the maximum frame.';

prompt = {line_01,line_02};
dlg_title = 'Remove Segmentation Keyframes';
default_input = {num2str(frame_no),num2str(frame_max)};

answer = inputdlg(prompt, dlg_title,1,default_input);

if ~isempty(answer)

    lower_bound = str2num(answer{1});
    upper_bound = str2num(answer{2});
    
    curr_cell = polygon_list{cell_idx};
    prev_best_pos = curr_cell.polygons{lower_bound-1};
    for pp=lower_bound:upper_bound
        
        curr_pos = curr_cell.polygons{pp};
        if ~isequal(prev_best_pos, curr_pos)
            curr_cell = curr_cell.updatePolygons(prev_best_pos, pp);
        end
    end
    
    polygon_list{cell_idx} = curr_cell;
    setappdata(APP.MAIN,'polygon_list',polygon_list);
    
    coordinate_spots_to_cells(APP);
    
    APP.keyframing_map.Enable = 'on';
    APP.keyframing_map.Value = 1;
    update_keyframe_data(APP);
    
    cla(APP.ax2);
    display_call(APP.keyframing_map, 1, APP);
    
end



%
%%%
%%%%%
%%%
%