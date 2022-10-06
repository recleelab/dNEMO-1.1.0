function [mask_arr] = masks_from_tif(mask_folderpath, mask_filename, image_height)
%% <placeholder>
%

% navigate to mask folder
prev_dir = cd(mask_folderpath);

% get # of frames
num_frames = length(imfinfo(mask_filename));

% create mask structure
mask_arr = cell(num_frames, 1);

for frame_no=1:num_frames
    imported_frame = imread(mask_filename, frame_no);
    [num_rows, num_cols] = size(imported_frame);
    if num_rows < 1024 || num_cols < 1024
        tmp_frame = uint16(imresize(imported_frame, image_height/num_cols,'method','nearest'));
    else
        tmp_frame = uint16(imported_frame);
    end
    mask_arr{frame_no} = tmp_frame;
end

cd(prev_dir);

%
%%%
%%%%%
%%%
%