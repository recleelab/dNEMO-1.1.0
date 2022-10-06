function [] = write_polygon_data_to_mask(polygon_list, img_dims, out_filename)
%% <placeholder>
%

empty_mask = uint16(zeros(img_dims(1), img_dims(2)));
mask_arr = repmat({empty_mask}, img_dims(3), 1);

for cell_idx=1:length(polygon_list)
    
    next_cell = polygon_list{cell_idx};
    
    for frame_idx=1:img_dims(3)
        
        prev_frame_mask = mask_arr{frame_idx};
        poly_at_this_frame = next_cell.getPolygon(frame_idx);
        binary_poly_mask = poly2mask(poly_at_this_frame(:,1), poly_at_this_frame(:,2), img_dims(1), img_dims(2));
        
        prev_frame_mask(binary_poly_mask) = uint16(cell_idx);
        mask_arr{frame_idx} = prev_frame_mask;
        
    end
    
end

for mask_idx=1:img_dims(3)
    imwrite(mask_arr{mask_idx},out_filename,'WriteMode','append');
end

%
%%%
%%%%%
%%%
%