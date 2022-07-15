%% quick dNEMO loop script
%
%%% BEGIN USER ARGUMENTS
%

% CURRENTLY ONLY PROCESSING DV FILES, PROBLEM W/ AUTO CALC CHANNEL for
% TMP_IMG class
valid_format_args = {'DV'};

% adjusted with the threshold slider normally, default = 2
user_wav_threshold = 2;

% atrous kernel level. either 1, 2, or 3. default = 2
user_wav_level = 2;

% # of z-slices object appears in to be considered real. default = 2
user_frame_limit = 2;

% oversegmentation check argument. default = 1
user_overseg = 1;

% background pixel region collection offset buffer. default = 1
user_bg_off = 1;

% background pixel region collected. default = 1
user_bg_pix = 1;

% ADDITIONAL KEYFRAME ARGUMENTS -- input as [MIN; MAX], keep as [NaN; NaN] to
% have no keyframe argument set (currently set as default)

% ADDITIONAL ARGUMENT -- MEAN INTENSITY
mean_intensity_kf_arg = [NaN; NaN];

% ADDITIONAL ARGUMENT -- MEDIAN INTENSITY
median_intensity_kf_arg = [NaN; NaN];

% ADDITIONAL ARGUMENT -- SUM INTENSITY
sum_intensity_kf_arg = [NaN; NaN];

% ADDITIONAL ARGUMENT -- SIZE (Pixels)
size_kf_arg = [NaN; NaN];
% size_kf_arg = [9.5; 30.5];

% ADDITIONAL ARGUMENT -- MAX INTENSITY
max_intensity_kf_arg = [NaN; NaN];

% additional argument assignment -- DO NOT CHANGE
KEYFRAME_ADDITIONAL_ARG_STRUCT = struct;
KEYFRAME_ADDITIONAL_ARG_FIELDNAMES = {'MEAN','MEDIAN','SUM','SIZE','MAX'};
KEYFRAME_MIN_MAX_ARR = zeros(2,length(KEYFRAME_ADDITIONAL_ARG_FIELDNAMES));

KEYFRAME_MIN_MAX_ARR(:,1) = mean_intensity_kf_arg;
KEYFRAME_MIN_MAX_ARR(:,2) = median_intensity_kf_arg;
KEYFRAME_MIN_MAX_ARR(:,3) = sum_intensity_kf_arg;
KEYFRAME_MIN_MAX_ARR(:,4) = size_kf_arg;
KEYFRAME_MIN_MAX_ARR(:,5) = max_intensity_kf_arg;

%
%%% END USER ARGUMENTS

% application parameter structure
dnemo_param_struct = struct;
dnemo_param_struct.FRAME_NO = 1;
dnemo_param_struct.USER_THRESH = user_wav_threshold;
dnemo_param_struct.WAV_LEVEL = user_wav_level;
dnemo_param_struct.OVERSEG = user_overseg;
dnemo_param_struct.FRAME_LIMIT = user_frame_limit;
dnemo_param_struct.NUM_PIX_OFF = user_bg_off;
dnemo_param_struct.NUM_PIX_BG = user_bg_pix;

[input_dir] = uigetdir('Select input directory');
if input_dir==0
    disp('Warning. directory not selected. terminating script.');
    return;
end

prev_dir = cd(input_dir);

listing = dir;
logically_dirs = [listing.isdir].';
all_names = {listing.name}.';
file_names = all_names(~logically_dirs);

% pull only TIFs, DVs
valid_image_files = {};

for file_idx=1:length(file_names)
    next_filename = file_names{file_idx};
    next_tokens = strsplit(next_filename,'.');
    query_token = next_tokens{length(next_tokens)};
    if any(ismember(upper(query_token),valid_format_args))
        valid_image_files = cat(1,valid_image_files,next_filename);
    end 
end

cd(prev_dir);

disp('valid image files found. please select output directory.');
[output_dir] = uigetdir('Select output directory');
if output_dir==0
    disp('Warning. directory not selected. terminating script.');
    return;
end

for file_idx=1:length(valid_image_files)
    
    curr_filename = valid_image_files{file_idx};
    
    disp('processing:');
    disp(curr_filename);
    
    IMG = TMP_IMG(curr_filename, input_dir);
    
    curr_frame = im2double(IMG.getCurrFrame());
    [spotInfo, interrupt_flag] = spot_finder_interruptible_mod(curr_frame, dnemo_param_struct, user_wav_threshold);
    
    if user_bg_pix
    
        tmp_waitbar = waitbar(0,'Applying background correction.');
    
        if IMG.Z == 1
            [BG_VALS,~] = two_dim_bg_calc(curr_frame, spotInfo, user_bg_off, user_bg_pix);
            spotInfo.BG_VALS = BG_VALS;
        else
            [BG_VALS,~] = assign_bg_pixels(curr_frame, spotInfo, user_bg_off, user_bg_pix);
            spotInfo.BG_VALS = BG_VALS;
        end
    
        delete(tmp_waitbar);
    
    end

    quick_overlay = TMP_OVERLAY(spotInfo, dnemo_param_struct);
    quick_overlay = quick_overlay.updateSpotFeatures(user_bg_off, user_bg_pix);
    disp('features updated');
    
    % propagate overlay across all frames
    curr_spot_detect = SPOT_DETECT(IMG, quick_overlay);
    
    % TEMPORARY - CHECKING BEFORE OPERATION
    assignin('base','SD_pre_kf_update',curr_spot_detect);
    disp('beginning updated keyframe argument addition');
    
    % ADDENDUM - UPDATING WITH OPTIONAL KEYFRAME ARGUMENTS
    for optional_arg_idx=1:length(KEYFRAME_ADDITIONAL_ARG_FIELDNAMES)
        quick_overlay.spotFeaturePointer = optional_arg_idx;
        nan_test_01 = isnan(KEYFRAME_MIN_MAX_ARR(1,optional_arg_idx));
        nan_test_02 = isnan(KEYFRAME_MIN_MAX_ARR(2,optional_arg_idx));
        if ~nan_test_01 && ~nan_test_02
            quick_overlay.spotFeatureMin(1,optional_arg_idx) = KEYFRAME_MIN_MAX_ARR(1,optional_arg_idx);
            quick_overlay.spotFeatureMax(1, optional_arg_idx) = KEYFRAME_MIN_MAX_ARR(2, optional_arg_idx);
            curr_spot_detect = curr_spot_detect.addFeatureSelection(quick_overlay);
        end
    end
    % END ADDENDUM - UPDATING WITH OPTIONAL KEYFRAME ARGUMENTS
    
    assignin('base','SD_post_kf_update',curr_spot_detect);
    disp('completed updated keyframe argument addition');
    
    % parse results filename
    some_tokens = strsplit(curr_filename,'.');
    if length(some_tokens) > 1
        sub_filename = cell2mat(strcat(some_tokens(1:length(some_tokens)-1)));
        results_filename = strcat(sub_filename,'_full_results.mat');
    else
        results_filename = strcat(some_tokens{1},'_full_results.mat');
    end
    
    % save spot detection to output directory
    KEYFRAMES = struct;
    spot_detect_fields = curr_spot_detect.getSpotDetectFields();
    for field_idx=1:length(spot_detect_fields)
        KEYFRAMES.(spot_detect_fields{field_idx}) = curr_spot_detect.(spot_detect_fields{field_idx});
    end

    cell_signals = {};
    polygon_list = {};
    KEYFRAMES.spotInfo = KEYFRAMES.spotInfoArr;
    
    cd(output_dir);
    save(results_filename,'KEYFRAMES','cell_signals','polygon_list','-v7.3');
    cd(prev_dir);
    
end

%
%%%
%%%%%
%%%
%