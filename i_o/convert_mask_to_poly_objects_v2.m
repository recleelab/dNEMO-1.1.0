function [polygon_list] = convert_mask_to_poly_objects_v2(mask_folderpath, mask_filename, cellpose_input_param, image_height)
%% <placeholder>
%

% pull masks from input arguments <mask_filename>, <mask_folderpath>
[mask_arr] = masks_from_tif(mask_folderpath, mask_filename, image_height);

% create centroid adjacency matrix from mask array
[centroid_adj_mat, segmentation_arr] = create_tracking_mat_UPDATED(mask_arr, cellpose_input_param);

% create new <polygon_list> from adjacency matrix, mask array
[polygon_list] = create_cell_segmentations_from_mask(mask_arr, centroid_adj_mat);

%
%%%
%%%%%
%%%
%