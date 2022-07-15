function [] = mod_exclusion_region(APP)
%% <placeholder>
%

excluded_regions = getappdata(APP.MAIN,'excluded_regions');
spot_detect = getappdata(APP.MAIN,'spot_detect');

latest_region = excluded_regions{length(excluded_regions)};

for frame_no=1:APP.film_slider.Max
    
    % next_poly = latest_region{frame_no};
    next_poly = latest_region.getPolygon(frame_no);
    next_spotInfo = spot_detect.spotInfoArr{frame_no};
    next_obj_coords = next_spotInfo.objCoords;
    
    prev_manual_exclusion = spot_detect.manualExclusion{frame_no};
    
    logically_in_poly = inpolygon(next_obj_coords(:,1),next_obj_coords(:,2),...
                                  next_poly(:,1),next_poly(:,2));
    prev_manual_exclusion(logically_in_poly) = 1;
    spot_detect.manualExclusion{frame_no} = prev_manual_exclusion;
    
end

setappdata(APP.MAIN,'spot_detect',spot_detect);

%
%%%
%%%%%
%%%
%