classdef TMP_CELL
%% TMP_CELL class
% Author: Gabriel J Kowalczyk (gjk20@pitt.edu)
% Last Updated: June 2021
% 
% Description: Updated script which creates a
% tracking matrix for the input sequence of masks (label matrices, in the
% format 1xN cell array) given the designated parameters. For more
% information on the parameters, see 'Input' below.
%
% Constructor Args:
% - starting_poly: initial segmentation to populate keyframing array
% - max_frames: maximum number of frames for the keyframing array to
% coordinate/construct itself
% - frame_no: frame number of polygon being submitted, which will be
% starting point for propagation along keyframing matrix 
% * user_frame_range: range for cell start and stop set manually by the
% user, as opposed to running the entirety of the movie
% 
% Additional Notes:
% Originally, w/ 'keyframing', the segmentations for cells were set over
% the span of [1] to [max_frames] when constructing the TMP_CELL object.
% Updated version (May 2021) has made adjustments so that the bounds of the
% TMP_CELL segmentations w/ regards to frame # can be set by the user.
% 
% 
%
    
    properties
        polygons
        pseudoAdjMatrix
        minFrame = 1;
        maxFrame
        
        % UPDATED -- ADDED AFTER CELLPOSE INTEGRATION
        user_temporal_bound
    end
    
    methods
        % constructor
        function obj = TMP_CELL(starting_poly, max_frames, frame_no, user_bounds)
            
            if nargin < 4
                user_bounds = [1 max_frames];
            end
            
            polygon_path = cell(1, max_frames);
            for i=1:size(polygon_path, 2)
                if i < user_bounds(1) || i > user_bounds(2)
                    polygon_path{i} = NaN;
                else
                    polygon_path{i} = starting_poly;
                end
            end
            
            obj.polygons = polygon_path;
            obj.maxFrame = max_frames;
            obj.user_temporal_bound = user_bounds;
            
            pseudo_adj_mat = zeros(2,max_frames);
            if frame_no==1
                pseudo_adj_mat(1,1:end) = 1;
            else
                pseudo_adj_mat(1,1:frame_no-1) = 1;
                pseudo_adj_mat(1,frame_no:end) = 2;
            end
            pseudo_adj_mat(2,frame_no) = 1;
            
            % additional insert for new properties
            indices_to_omit = 1:obj.maxFrame;
            indices_to_omit(obj.user_temporal_bound(1):obj.user_temporal_bound(2)) = [];
            
            pseudo_adj_mat(1,indices_to_omit) = NaN;
            pseudo_adj_mat(2,indices_to_omit) = -1;
            
            obj.pseudoAdjMatrix = pseudo_adj_mat;
        end
        
        % getPolygon
        function polygon = getPolygon(obj,frame_no)
            polygon = obj.polygons{frame_no};
        end
        
        % updatePolygons
        function obj = updatePolygons(obj, pos, frame_no)
            
            actual_polygon_paths = obj.polygons;
            pseudo_adj_matrix = obj.pseudoAdjMatrix;
            
            highest_level = max(pseudo_adj_matrix(1,:));
            next_level = highest_level + 1;
            actual_polygon_paths{frame_no} = pos;
            pseudo_adj_matrix(1,frame_no) = next_level;
            pseudo_adj_matrix(2,frame_no) = 1;
            
            if size(pseudo_adj_matrix,2) > 1
                next_kf_found = 0;
                count = frame_no + 1;
                
                while next_kf_found == 0
                    
                    if count < length(pseudo_adj_matrix)
                        tmp_val = pseudo_adj_matrix(2,count);
                    else
                        tmp_val = 0;
                    end
                    
                    % added -- based on user-imposed limits
                    if tmp_val == -1
                        % hit user-defined bounds
                        next_kf_found = 1;
                        % disp('this text should not display');
                    end
                    
                    if tmp_val==0 && count < length(pseudo_adj_matrix)
                        pseudo_adj_matrix(1,count) = next_level;
                        actual_polygon_paths{count} = pos;
                        count = count+1;
                    else
                        if tmp_val==0
                            endpoint = length(pseudo_adj_matrix);
                            actual_polygon_paths{1,endpoint} = pos;
                            next_kf_found = 1;
                        else
                            next_kf_found = 1;
                        end
                    end
                end
            end
            
            obj.polygons = actual_polygon_paths;
            obj.pseudoAdjMatrix = pseudo_adj_matrix;
            
        end
        
        % removePolygonKF
        function obj = removePolygonKF(obj, keyframing_string)
            
            str_tokens = strsplit(keyframing_string,'_');
            frame_string = str_tokens{1};
            some_str_loc = strfind(frame_string,'>');
            sub_str = frame_string(some_str_loc+6:end);
            frame_no = str2num(char(sub_str));
            assignin('base','frame_no',frame_no);
            actual_polygon_paths = obj.polygons;
            pseudo_adj_matrix = obj.pseudoAdjMatrix;
            
            poly_marker = pseudo_adj_matrix(1,frame_no);
            assignin('base','poly_marker',poly_marker);
            kf_frames = find(pseudo_adj_matrix(1,:)==poly_marker);
            % assignin('base','kf_frames',kf_frames);
            pseudo_adj_matrix(2,frame_no) = 0;
            next_kf = find(pseudo_adj_matrix(2,frame_no+1:end));
            prev_kf = find(pseudo_adj_matrix(2,1:frame_no));
            
            % assignin('base','next_kf',next_kf);
            % assignin('base','prev_kf',prev_kf);
            
            if isempty(prev_kf)
                % go to next_kf
                % disp('no prev kf');
                new_poly = actual_polygon_paths{next_kf(1)+frame_no};
                actual_polygon_paths(1:next_kf(1)+frame_no) = {new_poly};
                % pseudo_adj_matrix(1,1:frame_no) = pseudo_adj_matrix(1,next_kf(1));
                pseudo_adj_matrix(1,1:next_kf(1)+frame_no) = 1;
            else
                % disp('found prev kf');
                new_poly = actual_polygon_paths{prev_kf(end)};
                actual_polygon_paths(kf_frames) = {new_poly};
                pseudo_adj_matrix(1,kf_frames) = pseudo_adj_matrix(1,prev_kf(end));
            end
            
            % assignin('base','some_mat1',pseudo_adj_matrix);
            % assignin('base','some_cell1',actual_polygon_paths);
            
            obj.pseudoAdjMatrix = pseudo_adj_matrix;
            obj.polygons = actual_polygon_paths;
            
        end
        
        % checkNumKF
        function num_kf = checkNumKF(obj)
            num_kf = length(find(obj.pseudoAdjMatrix(2,:)));
        end
        
    end
end

