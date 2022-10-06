function [tracking_adj_mat] = create_tracking_mat(mask_arr)
%% <placeholder>
%

centroid_rad = 250; % originally 100
area_percentage = 0.35; % originaly 0.175

init_mask = mask_arr{1};
[mask_height, mask_width] = size(init_mask);

init_num_objs = max(max(init_mask));

tracking_adj_mat = NaN(init_num_objs, length(mask_arr));
tracking_adj_mat(:,1) = 1:init_num_objs;

% last_centroid = NaN(init_num_objs, 2);
% last_area = NaN(init_num_objs, 1);

init_centroid_struct = regionprops(init_mask, 'Centroid');
init_centroids = cell2mat({init_centroid_struct.Centroid}.');
init_area_struct = regionprops(init_mask,'Area');
init_areas = cell2mat({init_area_struct.Area}.');

last_centroid = init_centroids;
last_area = init_areas;
last_frame = ones(init_num_objs, 1);

for mask_idx=2:length(mask_arr)
    
    curr_mask = mask_arr{mask_idx};
    curr_centroid_struct = regionprops(curr_mask,'Centroid');
    curr_object_centroids = cell2mat({curr_centroid_struct.Centroid}.');
    
    curr_area_struct = regionprops(curr_mask,'Area');
    curr_object_areas = cell2mat({curr_area_struct.Area}.');
    
    if isempty(curr_object_centroids)
        tracking_adj_mat(:,mask_idx) = NaN;
        continue;
    end
    
    previous_object_centroids = last_centroid;
    
    [pointer_inds, dists] = dsearchn(previous_object_centroids, curr_object_centroids);
    
    for obj_idx=1:size(tracking_adj_mat, 1)
        next_object_id = find(pointer_inds==obj_idx);
        
        %
        if isempty(next_object_id)
            tracking_adj_mat(obj_idx, mask_idx) = NaN;
            continue;
        end
        %}
        
        if length(next_object_id) > 1
            dists_to_confirm = dists(next_object_id);
            [min_dist, min_loc] = min(dists_to_confirm);
            next_object_id = next_object_id(min_loc);
        end
        
        prev_area = last_area(obj_idx);
        curr_area = curr_object_areas(next_object_id);
        area_diff = abs(prev_area - curr_area);
        area_shift = area_percentage*prev_area;
        
        if dists(next_object_id) > centroid_rad || area_diff >= area_shift
            tracking_adj_mat(obj_idx, mask_idx) = NaN;
        else
            tracking_adj_mat(obj_idx, mask_idx) = next_object_id;
            last_centroid(obj_idx,:) = curr_object_centroids(next_object_id,:);
            last_area(obj_idx) = curr_area;
            last_frame(obj_idx) = mask_idx;
        end
    end
    
end

%{
for mask_idx=2:length(mask_arr)
    
    assignin('base','mask_idx',mask_idx);
    assignin('base','tracking_adj_mat',tracking_adj_mat);
    
    % prev_mask = mask_arr{mask_idx-1};
    % prev_centroid_struct = regionprops(prev_mask, 'Centroid');
    curr_mask = mask_arr{mask_idx};
    curr_centroid_struct = regionprops(curr_mask,'Centroid');
    
    % assignin('base','prev_centroid_struct',prev_centroid_struct);
    % assignin('base','curr_centroid_struct',curr_centroid_struct);
    
    % previous_object_centroids = cell2mat({prev_centroid_struct.Centroid}.');
    % previous_object_centroids = previous_object_centroids(tracking_adj_mat(:,mask_idx-1),:);
    
    previous_object_centroids = last_centroid;
    
    % centroid for 1st object in previous frame has correct label pointer
    curr_object_centroids = cell2mat({curr_centroid_struct.Centroid}.');
    
    % find distance
    [pointer_inds, dists] = dsearchn(previous_object_centroids, curr_object_centroids);
    
    for obj_idx=1:size(tracking_adj_mat, 1)
        next_object_id = find(pointer_inds==obj_idx);
        
        if length(next_object_id) > 1
            dists_to_confirm = dists(next_object_id);
            [min_dist, min_loc] = min(dists_to_confirm);
            next_object_id = next_object_id(min_loc);
        end
        
        tracking_adj_mat(obj_idx, mask_idx) = next_object_id;
    end
    
end
%}

%
%%%
%%%%%
%%%
%