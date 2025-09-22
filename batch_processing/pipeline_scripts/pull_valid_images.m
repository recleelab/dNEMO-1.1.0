function [valid_image_filenames] = pull_valid_images(input_filenames, fmt_arg)
%% function valid_image_filenames = pull_valid_images(input_filenames, fmt_arg)
%
% Author: Gabriel J Kowalczyk (gjk20@pitt.edu)
% Date: April 2021
% 
% Description: 'pull_valid_images()' accepts a list of input filenames 
% and a cell array of file extensions and returns a cell array of 
% filenames which contain one of the file extensions.
% 
% Input:
%     - input_filenames: cell array {} of input filename strings. array
%       should be either [N x 1] or [1 x N], where N = number of filename 
%       strings
%     - fmt_arg: cell array containing string of accepted file extensions
%                separated by semicolon (like optional argument for the
%                MATLAB function 'uigetfile')
% 
% Output:
%     - valid_image_filenames: cell array {} of filename strings from 
%       [input_filenames] which contain extensions found in [fmt_arg]
% 
% Usage:
%     >> some_filenames = {'file_01.jpg', 'file_02.tif', 'file_03.png'};
%     >> some_fmt = {'*.tif;*.TIF;*.tiff;*.TIFF'};
%     >> [process_these_files] = pull_valid_images(some_filenames, some_fmt)
%     process_these_files = 
%         1x1 cell array 
%             {'file_02.tif'}
%

valid_image_filenames = {};

%{
% parse fmt_arg for multiple accepted formats
all_fmts = strsplit(fmt_arg{1},';');
for fmt_idx=1:length(all_fmts)
    all_fmts{fmt_idx} = strrep(all_fmts{fmt_idx},'*.','');
end
%}

init_num_files = length(input_filenames);

for file_idx = 1:length(input_filenames)
    
    % pull next filename
    curr_filename = input_filenames{file_idx};
    
    % look for valid image format
    S = strsplit(curr_filename,'.');
    file_extension = S{length(S)};
    % assignin('base','file_extension',file_extension);
    % assignin('base','fmt_arg',fmt_arg);
    extension_found = find(contains(fmt_arg,file_extension));
    if extension_found
        valid_image_filenames = cat(1, valid_image_filenames, input_filenames(file_idx));
    end
    % look for REF item, ignore when found
    %{
    REF_found = contains(S{1},'REF');
    if extension_found
        if ~REF_found
            valid_image_filenames = cat(1,valid_image_filenames,input_filenames(file_idx));
        end
    end
    %}
    
end

%
%%%
%%%%%
%%%
%