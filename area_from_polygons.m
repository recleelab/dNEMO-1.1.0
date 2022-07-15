function [area_list] = area_from_polygons(polygon_list)
%% area_from_polygons.m
%
%

area_list = cell(length(polygon_list),1);
tmp_micron_val = [0.10839 0.10839 0.500];

sample_data = polygon_list{1};
switch class(sample_data)
    case 'TMP_CELL'
        for cell_idx=1:length(polygon_list)
    
            tmp_cell = polygon_list{cell_idx};
            some_polygons = tmp_cell.polygons;

            area_over_time = zeros(1,length(some_polygons));
            for poly_idx=1:length(some_polygons)
                frame_vertices = some_polygons{poly_idx};
                vert_x = frame_vertices(:,1).*tmp_micron_val(1,1);
                vert_y = frame_vertices(:,2).*tmp_micron_val(1,2);
                area_over_time(1,poly_idx) = polyarea(vert_x, vert_y);
            end
            area_list{cell_idx} = area_over_time;
        end
    case 'cell'
        for cell_idx=1:length(polygon_list)
            
            tmp_cell = polygon_list{cell_idx};
            
            area_over_time = zeros(1, length(tmp_cell));
            for poly_idx=1:length(tmp_cell)
                frame_vertices = tmp_cell{poly_idx};
                vert_x = frame_vertices(:,1).*tmp_micron_val(1,1);
                vert_y = frame_vertices(:,2).*tmp_micron_val(1,2);
                area_over_time(1,poly_idx) = polyarea(vert_x, vert_y);
            end
            area_list{cell_idx} = area_over_time;
        end
end

%
%%%
%%%%%
%%%
%