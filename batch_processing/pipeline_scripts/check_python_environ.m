function [bool_flag] = check_python_environ()
%% function bool_flag = check_python_environ()
%
% Author: Gabriel J Kowalczyk (gjk20@pitt.edu)
% Date: April 2021
% 
% Description: 'pull_valid_images()' accepts a list of input filenames 
% and a cell array of file extensions and returns a cell array of 
% filenames which contain one of the file extensions.
% 
% Input:
%   N/A
% 
% Output:
%     - bool_flag: 0 or 1; 1 if MATLAB can properly access Python3, 0
%       if not
% 
% Usage:
%     >> can_matlab_access_python3 = check_python_environ()
%         can_matlab_access_python3 = 1
% 
% Additional notes:
%     This environment check requires a specific text file in the current 
%     directory: 'os_python3_location.txt'. 
%
%     See 'Run_dNEMO_batch_processing.m' for more information on Cellpose
%     setup so that it can be run from MATLAB in your system.
%

txt_filename = 'os_python3_location.txt';
txt_id = fopen(txt_filename);

line_01 = fgetl(txt_id);
line_02 = fgetl(txt_id);
line_03 = fgetl(txt_id);

bool_flag = 0;

% header
if strcmp(line_01, '#OS-PYTHON3-LOCATION')
    
    python3_loc_string = line_02;
    setenv('PATH', python3_loc_string);
    
    executable_loc_string = line_03;
    pyversion(executable_loc_string);
    
    bool_flag = 1;
end


%
%%%
%%%%%
%%%
%