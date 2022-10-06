function [polygon_list] = create_cell_segmentations_from_mask(mask_arr, centroid_adj_mat)
%% <placeholder>
%

tmp_mask = zeros(size(mask_arr{1}));
segmentation_arr = cell(size(centroid_adj_mat,1),1);
polygon_list = {};

for seg_ind=1:size(centroid_adj_mat, 1)
    
    next_entry = struct;
    unique_seg_frame_inds = find(~isnan(centroid_adj_mat(seg_ind,:)));
    seg_start = min(unique_seg_frame_inds);
    seg_end = max(unique_seg_frame_inds);
    
    previous_seg_ind = seg_start;
    
    for frame_ind=1:length(mask_arr)
        if frame_ind < seg_start || frame_ind > seg_end
            % set nan values in the structure array
            next_entry(frame_ind).segmentation = NaN;
            next_entry(frame_ind).is_unique = NaN;
        else
            lookup_value = centroid_adj_mat(seg_ind,frame_ind);
            if isnan(lookup_value)
                mask_object_indices = find(mask_arr{previous_seg_ind}==centroid_adj_mat(seg_ind, previous_seg_ind));
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

for poly_idx=1:size(centroid_adj_mat, 1)
    
    next_row = centroid_adj_mat(poly_idx,:);
    sample_cell_segmentations = {segmentation_arr{poly_idx}.segmentation}.';
    
    segmentations_present = find(~isnan(next_row));
    valid_frame_indices = min(segmentations_present):1:max(segmentations_present);
    
    new_cell = [];
    for tmp_cell_ind=1:length(valid_frame_indices)
        tmp_frame_ind = valid_frame_indices(tmp_cell_ind);
        if isempty(new_cell)
            new_cell = TMP_CELL(sample_cell_segmentations{tmp_frame_ind}, length(mask_arr), tmp_frame_ind, [valid_frame_indices(1) valid_frame_indices(end)]);
        else
            new_cell = new_cell.updatePolygons(sample_cell_segmentations{tmp_frame_ind}, tmp_frame_ind);
        end
    end
    
    polygon_list = cat(1, polygon_list, {new_cell});
    
end

%
%%%
%%%%%
%%%
%