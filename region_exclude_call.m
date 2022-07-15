function [] = region_exclude_call(hand, evt, APP)
%% <placeholder>
%

switch hand.Type
    case 'uimenu'
        
        % check status
        if strcmp(hand.Checked,'off')
            
            setappdata(APP.MAIN,'region_exclusion_happening',1);
            
            APP.ax2.HitTest = 'on';
            APP.ax2.PickableParts = 'visible';
            
            new_region = impoly(APP.ax2);
			setColor(new_region,'red');
			pos = getPosition(new_region);
			new_region.addNewPositionCallback(@(p) polygon_change2(new_region,APP));
            
            % initializing polydraw_toolbox

			prev_index = APP.film_slider.Value;
            max_frames = APP.film_slider.Max;
            polygon_path = TMP_CELL(pos, max_frames, prev_index);
            %{
			polygon_path = cell(1,APP.film_slider.Max);
			for i=1:size(polygon_path,2)
				polygon_path{i} = pos;
				pseudo_adj_matrix(1,i) = 1;
			end
			pseudo_adj_matrix(2,prev_index) = 1;
            %}
            
            polydraw_toolbox = cell(1,3);
			polydraw_toolbox{1,1} = prev_index;
			% polydraw_toolbox{1,2} = pseudo_adj_matrix;
			polydraw_toolbox{1,3} = polygon_path;
			setappdata(APP.MAIN,'polydraw_toolbox',polydraw_toolbox);
            
            hand.Checked = 'on';
            
        else
            
            % terminate process
            polydraw_toolbox = getappdata(APP.MAIN,'polydraw_toolbox');
            new_region = polydraw_toolbox{1,3};
            excluded_regions = getappdata(APP.MAIN,'excluded_regions');
            
            [updated_excluded_regions] = polygon_insert(excluded_regions, new_region, size(excluded_regions,1)+1);
            setappdata(APP.MAIN,'excluded_regions',updated_excluded_regions);
            
            hand.Checked = 'off';
            setappdata(APP.MAIN,'region_exclusion_happening',0);
            
            mod_exclusion_region(APP);
            
            cla(APP.ax2);
            display_call(APP.film_slider,1,APP);
            
        end
        
    case 'uicontrol'
        
        polydraw_toolbox = getappdata(APP.MAIN,'polydraw_toolbox');
		prev_index = polydraw_toolbox{1,1};
		current_polygon = polydraw_toolbox{1,3};
		curr_index = APP.film_slider.Value;
		curr_pos = current_polygon.getPolygon(curr_index);
		
		polygon = impoly(APP.ax2,curr_pos);
		setColor(polygon,'red');
		polygon.addNewPositionCallback(@(p) polygon_change2(polygon,APP));
		polydraw_toolbox{1,1} = curr_index;
		setappdata(APP.MAIN,'polydraw_toolbox',polydraw_toolbox);
end

%
%%%
%%%%%
%%%
%

function polygon_change2(polygon, APP)
%% callback function assigned to the polygon so that if user changes it, 
%  coordinates and movement are accurately measured.
%
%  Step 1 - grab the polygon's position, now changed, and the frame at
%  which it occurred
%
pos = getPosition(polygon);
curr_idx = APP.film_slider.Value;

%  Step 2 - pull current cell data
% polygon_list = getappdata(APP.MAIN,'polygon_list');
% curr_cell = polygon_list{cell_idx};
polydraw_toolbox = getappdata(APP.MAIN,'polydraw_toolbox');
curr_poly = polydraw_toolbox{1,3};

%  Step 3 - assign changes to current index 
curr_poly = curr_poly.updatePolygons(pos, curr_idx);
polydraw_toolbox{1,3} = curr_poly;
setappdata(APP.MAIN,'polydraw_toolbox',polydraw_toolbox);
% polygon_list{cell_idx} = curr_cell;
% setappdata(APP.MAIN,'polygon_list',polygon_list);

%
%%%
%%%%%
%%%
%