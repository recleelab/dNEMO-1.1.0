function [] = polygon_set_temporal_bound(hand, evt, APP)
%% <placeholder>
%

polygon_list = getappdata(APP.MAIN, 'polygon_list');
cell_idx = APP.created_cell_selection.Value - 1;
curr_cell = polygon_list{cell_idx};

max_num_frames = curr_cell.maxFrame;

prev_temporal_bounds = curr_cell.user_temporal_bound;

import_prompts = {'Cell start: frame at which cell starts',...
                  'Cell stop: frame at which cell stops/divides/etc.'};
default_values = {num2str(prev_temporal_bounds(1)),...
                  num2str(prev_temporal_bounds(2))};

some_dims = [1, 40];
some_title = 'Update Cell Start/Stop';

user_answer = inputdlg(import_prompts,...
                       some_title,...
                       some_dims,...
                       default_values);

if ~isempty(user_answer)
    new_user_bounds(1) = str2num(user_answer{1});
    new_user_bounds(2) = str2num(user_answer{2});
    
    prev_polygons = curr_cell.polygons;
    
    % need new polygon sequence because bounds (a) won't match up and (b)
    % will potentially not even have a segmentation previously assigned to
    % that index
    
    new_valid_indices = new_user_bounds(1):1:new_user_bounds(2);
    reassigned_polygons = cell(1, max_num_frames);
    
    non_nan_indices = cellfun(@max, cellfun(@any, cellfun(@isnan, prev_polygons, 'uniformoutput', false), 'uniformoutput', false));
    non_nan_indices = find(~non_nan_indices);
    
    for ii=1:length(new_valid_indices)
        
        next_ind = new_valid_indices(ii);
        
        if any(isnan(prev_polygons{next_ind}))
            % find next 'best fit' that exists
            
            [closest_idx, ~] = dsearchn(non_nan_indices.', next_ind);
            reassigned_polygons{next_ind} = prev_polygons{non_nan_indices(closest_idx)};
            
        else
            % just use the fit from previous
            reassigned_polygons{next_ind} = prev_polygons{next_ind}; 
        end
        
    end
    
    updated_cell = [];
    for tmp_cell_ind = 1:length(new_valid_indices)
        tmp_frame_ind = new_valid_indices(tmp_cell_ind);
        if isempty(updated_cell)
            updated_cell = TMP_CELL(reassigned_polygons{tmp_frame_ind},...
                                    max_num_frames,...
                                    tmp_frame_ind,...
                                    new_user_bounds);
        else
            updated_cell = updated_cell.updatePolygons(reassigned_polygons{tmp_frame_ind}, tmp_frame_ind);
        end
    end
    
    polygon_list{cell_idx} = updated_cell;
    setappdata(APP.MAIN,'polygon_list',polygon_list);
    coordinate_spots_to_cells(APP);
else
    return;
end

display_call(hand, evt, APP);

%
%%%
%%%%%
%%%
%