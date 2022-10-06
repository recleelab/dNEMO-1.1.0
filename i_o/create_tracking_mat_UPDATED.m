function [tracking_adj_mat, segmentation_arr] = create_tracking_mat_UPDATED(mask_arr, param_struct)
%% function tracking_adj_mat = create_tracking_mat_UPDATED(mask_arr, param_struct)
%
% Author: Gabriel J Kowalczyk (gjk20@pitt.edu)
% Date: May 2021
% 
% Description: Bit of a complicated one. Updated script which creates a
% tracking matrix for the input sequence of masks (label matrices, in the
% format 1xN cell array) given the designated parameters. For more
% information on the parameters, see 'Input' below.
%
% Input:
%     - mask_arr: cell array {} of label matrices. array should be either
%       [N x 1] or [1 x N], where N = number of frames for some movie 
%       represented as a sequence of masks, here as label matrices.
%     - param_struct: MATLAB structure (struct) containing the following 
%         fields (parameters):
%             'centroid_radius' - 
%             'area_percentage' - 
%             'min_frame_appear_percentage' - 
%             'max_frame_gap' - 
% 
% Output:
%     - tracking_adj_mat:
%     - segmentation_arr:
%             
%
% Additional Notes:
% Script assumes that input masks w/in 'mask_arr' are of same dimensions
% as source image. The function 'masks_from_tif()' rescales masks to fit
% either 1024 x 1024 OR the given input dimensions (see masks_from_tif.m
% for more information)
%

input_param_struct_fields = fieldnames(param_struct);

% centroid_radius -- maximum distance to connect potential segmentations
% between frames (default: 150).
if any(strcmp('centroid_radius', input_param_struct_fields))
    centroid_radius = param_struct.centroid_radius;
else
    centroid_radius = 125;
end

% area_percentage -- maximum allowable shift in area relative to previous
% segmentation up for comparison (range 0 to 1; default 0.225).
if any(strcmp('area_percentage', input_param_struct_fields))
    area_percentage = param_struct.area_percentage;
else
    area_percentage = 0.225;
end

if area_percentage < 0 || area_percentage > 1
    area_percentage = 0.225;
end

% min_frame_appear_percentage -- minimum number of frames an object has to
% appear in consistently for it to be considered a 'real' object. value
% represented as a percentage of the length of the mask_arr [N], the length
% of the movie (range 0 to 1; default 0.12).
if any(strcmp('min_frame_appear_percentage', input_param_struct_fields))
    min_frame_appear_percentage = param_struct.min_frame_appear_percentage;
else
    min_frame_appear_percentage = 0.12;
end

if min_frame_appear_percentage < 0 || min_frame_appear_percentage > 1
    min_frame_appear_percentage = 0.12;
end

% gap_frame_limit -- upper bound for connecting new segmentations within a
% time-series movie sequence. when connecting new segmentations/seeing
% whether they should be distinct, the previous 'cells' last connected
% segmentation's timepoint is compared against the 'gap_frame_limit'. If
% 'gap_frame_limit' frames have passed since that time point, new
% segmentations aren't considered for addition to the object. default 5, 
% minimum 1.
if any(strcmp('gap_frame_limit', input_param_struct_fields))
    gap_frame_limit = param_struct.gap_frame_limit;
    if gap_frame_limit < 1
        gap_frame_limit = 1;
    end
else
    gap_frame_limit = 5;
end

init_mask = mask_arr{1};
[mask_height, mask_width] = size(init_mask);

max_num_frames = length(mask_arr);
all_centroids = cell(max_num_frames,1);
all_areas = cell(max_num_frames,1);

for ff=1:max_num_frames
    tmp_region_stats = regionprops(mask_arr{ff}, 'Centroid', 'Area');
    all_centroids{ff} = cell2mat({tmp_region_stats.Centroid}.');
    all_areas{ff} = cell2mat({tmp_region_stats.Area}.');
end

% temporary
% assignin('base','all_centroids',all_centroids);
frames_with_centroids = cell2mat(cellfun(@isempty, all_centroids, 'uniformoutput',false));
frames_with_centroids = find(~frames_with_centroids);
starting_frame = min(frames_with_centroids);

forward_runs = [];
last_xya = [];

init_centroids = all_centroids{starting_frame};
init_areas = all_areas{starting_frame};
if ~isempty(init_centroids)
    for tmp_ind=1:size(init_centroids, 1)
        last_xya = cat(1, last_xya, [starting_frame, init_centroids(tmp_ind,1), init_centroids(tmp_ind,2), init_areas(tmp_ind)]);
        dummy_entry = [];
        if starting_frame~=1
            dummy_entry = NaN(1, starting_frame-1);
        end
        forward_runs = cat(1, forward_runs, cat(2, dummy_entry, tmp_ind));
        % forward_runs = cat(1, forward_runs, tmp_ind);
    end
end

assignin('base','init_forward_runs',forward_runs);

for ff=starting_frame+1:max_num_frames
    ff
    % initialize next row of forward_runs to NaN
    forward_runs = cat(2, forward_runs, NaN(size(forward_runs, 1),1));
    
    curr_centroids = all_centroids{ff};
    curr_areas = all_areas{ff};
    
    if isempty(curr_centroids)
        continue;
    end
    
    prev_centroids = last_xya(:,2:3);
    prev_areas = last_xya(:,4);
    
    [pointer_inds, dists] = dsearchn(curr_centroids, prev_centroids);
    logically_assigned_to_previous_runs = logical(zeros(size(curr_centroids, 1),1));
    
    for pp=1:max(pointer_inds)
        
        tmp_pointer_locs = find(pointer_inds==pp);
        tmp_pointer_dists = dists(tmp_pointer_locs);
        tmp_pointer_areas = prev_areas(tmp_pointer_locs);
        
        % only want locations which fit (1) distance and (2) area
        tmp_logically_exclude = logical(zeros(length(tmp_pointer_locs),1));
        tmp_logically_exclude(tmp_pointer_dists > centroid_radius) = 1;
        tmp_logically_exclude((abs(tmp_pointer_areas - curr_areas(pp))) > (area_percentage.*tmp_pointer_areas)) = 1;
        
        tmp_pointer_locs(tmp_logically_exclude) = [];
        tmp_pointer_dists(tmp_logically_exclude) = [];
        tmp_pointer_areas(tmp_logically_exclude) = [];
        
        if ~isempty(tmp_pointer_locs)
            
            [best_pointer_dist, best_pointer_dist_ind] = min(tmp_pointer_dists);
            best_pointer_loc = tmp_pointer_locs(best_pointer_dist_ind);
            
            % pp is index in current centroids, best_pointer_loc is
            % location in the previous centroids that best matches
            forward_runs(best_pointer_loc, ff) = pp;
            last_xya(best_pointer_loc, :) = [ff, curr_centroids(pp, 1), curr_centroids(pp, 2), curr_areas(pp)];
            logically_assigned_to_previous_runs(pp) = 1;
        
        end
    
    end
    
    assignin('base','tmp_forward_runs',forward_runs);
    
    % add any centroids/areas that weren't a part of a previous run into
    % the forward_runs structure
    if min(logically_assigned_to_previous_runs) == 0
        
        true_inds = find(~logically_assigned_to_previous_runs);
        centroids_to_add = curr_centroids(~logically_assigned_to_previous_runs,:);
        areas_to_add = curr_areas(~logically_assigned_to_previous_runs);
        
        for rr=1:length(true_inds)
            
            % update forward_runs
            next_run_entry = NaN(1, ff);
            next_run_entry(ff) = true_inds(rr);
            forward_runs = cat(1, forward_runs, next_run_entry);
            
            % update next_xya
            next_xya_entry = [ff, centroids_to_add(rr,1), centroids_to_add(rr,2), areas_to_add(rr)];
            last_xya = cat(1, last_xya, next_xya_entry);
        end
        
    end
    
    % NEW -- remove any entrys from last_xya where last timepoint > gap
    % frame limit
    %
    xya_latest_frame_inds = last_xya(:,1);
    xya_latest_time_diffs = abs(xya_latest_frame_inds - ff);
    logically_old_enough = xya_latest_time_diffs > gap_frame_limit;
    xya_removal_locs = find(logically_old_enough);
    if ~isempty(xya_removal_locs)
        for ll=1:length(xya_removal_locs)
            last_xya(xya_removal_locs(ll),:) = [0 -100000 -100000 -100000];
        end
    end
    %}
    
end

forward_runs2 = forward_runs;
forward_runs2(isnan(forward_runs2)) = 0;

tracking_adj_mat = [];

for rr=1:size(forward_runs2, 1)
    next_row = forward_runs2(rr,:);
    num_nonzero = sum(next_row > 0);
    if num_nonzero >= (max_num_frames*min_frame_appear_percentage)
        tracking_adj_mat = cat(1, tracking_adj_mat, next_row);
    end
end

tracking_adj_mat(tracking_adj_mat==0) = NaN;

% creation of segmentation array (segmentation_arr) which is representative
% of the adjacency matrix (tracking_adj_mat) + data acquired from masks
% (mask_arr). probably going to have to be cell array of (?) structure
% arrays maybe?

% each one should probably be a structure array, because this structure's
% going to have to become more generalizable in the long run
segmentation_arr = cell(size(tracking_adj_mat,1),1);

sample_frame = mask_arr{1};
tmp_mask = zeros(mask_width, mask_height);

for seg_ind=1:size(tracking_adj_mat, 1)
    
    next_entry = struct;
    unique_seg_frame_inds = find(~isnan(tracking_adj_mat(seg_ind,:)));
    seg_start = min(unique_seg_frame_inds);
    seg_end = max(unique_seg_frame_inds);
    
    previous_seg_ind = seg_start;
    
    for frame_ind=1:max_num_frames
        if frame_ind < seg_start || frame_ind > seg_end
            % set nan values in the structure array
            next_entry(frame_ind).segmentation = NaN;
            next_entry(frame_ind).is_unique = NaN;
        else
            lookup_value = tracking_adj_mat(seg_ind,frame_ind);
            if isnan(lookup_value)
                mask_object_indices = find(mask_arr{previous_seg_ind}==tracking_adj_mat(seg_ind, previous_seg_ind));
            else
                mask_object_indices = find(mask_arr{frame_ind}==lookup_value);
                previous_seg_ind = frame_ind;
            end

            % actual coordinates
            tmp_mask(mask_object_indices) = 1;
            B = cell2mat(bwboundaries(tmp_mask));
            mask_inds = [B(:,2), B(:,1)];

            tmp_mask(tmp_mask~=0) = 0;
            
            % set appropriate values in structure array
            next_entry(frame_ind).segmentation = mask_inds;
            if frame_ind == previous_seg_ind
                next_entry(frame_ind).is_unique = 1;
            else
                next_entry(frame_ind).is_unique = 0;
            end
        end
    end
    
    segmentation_arr{seg_ind} = next_entry;
    
end

%
%%%
%%%%%
%%%
%