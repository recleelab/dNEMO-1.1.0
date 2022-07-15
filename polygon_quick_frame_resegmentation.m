function [] = polygon_quick_frame_resegmentation(hand, evt, APP)
%% <placeholder>
%

polygon_list = getappdata(APP.MAIN,'polygon_list');

frame_no = APP.film_slider.Value;
frame_max = APP.film_slider.Max;
cell_idx = APP.created_cell_selection.Value - 1;

question_string = 'Resegmenting cell for the current frame will replace existing segmentation. Do you wish to continue?';
reseg_answer = questdlg(question_string, 'Resegmentation for single frame','Continue','Cancel','Cancel');

if strcmp(reseg_answer,'Cancel')
    return;
end

curr_cell = polygon_list{cell_idx};

temp_resegmentation = impoly(APP.ax2);
temp_position = getPosition(temp_resegmentation);

curr_cell = curr_cell.updatePolygons(temp_position, frame_no);
polygon_list{cell_idx} = curr_cell;

setappdata(APP.MAIN,'polygon_list',polygon_list);
    
coordinate_spots_to_cells(APP);

APP.keyframing_map.Enable = 'on';
APP.keyframing_map.Value = 1;
update_keyframe_data(APP);

delete(temp_resegmentation);

reseg_out_msg = msgbox('Resegmentation for current frame successfully updated.');

cla(APP.ax2);
display_call(APP.keyframing_map, 1, APP);





%
%%%
%%%%%
%%%
%