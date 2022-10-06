function [KEYFRAMES_STRUCT] = legacy_results_conversion(RELOAD, IMG)
%% <placeholder>
%

KEYFRAMES_STRUCT = struct;
legacy_keyframe_struct = RELOAD.KEYFRAMES{1};

min_frame = legacy_keyframe_struct.KF_START;
max_frame = legacy_keyframe_struct.KF_END;
frame_lim = legacy_keyframe_struct.FrameLim;
wav_thresh = legacy_keyframe_struct.Threshold;
spotInfo = legacy_keyframe_struct.spotInfo;

some_lengths = cellfun(@length, legacy_keyframe_struct.incl_excl);

% for now assumes bg_off = 1, bg_pix = 1, atrous level = 2, overseg = 1
% can confirm w/ source image, but will need quick and dirty to confirm
% import first

% IMG argument optional**
if nargin > 1
    %todo
else
    %todo
end

KEYFRAMES_STRUCT.minFrameAbsolute = min_frame;
KEYFRAMES_STRUCT.maxFrameAbsolute = max_frame;
KEYFRAMES_STRUCT.spotInfoArr = spotInfo;

% a trous wavelet level (1, 2, 3, etc.)
KEYFRAMES_STRUCT.wavLevelArr = zeros(2, max_frame);
KEYFRAMES_STRUCT.wavLevelArr(1,:) = 2;
KEYFRAMES_STRUCT.wavLevelArr(2,1) = 1;

% Wavelet threshold ( >= 1)
KEYFRAMES_STRUCT.wavThreshArr = zeros(2, max_frame);
KEYFRAMES_STRUCT.wavThreshArr(1,:) = wav_thresh;
KEYFRAMES_STRUCT.wavThreshArr(2,1) = 1;

% OVERSEGMENTATION ARG
KEYFRAMES_STRUCT.overSegArr = zeros(2, max_frame);
KEYFRAMES_STRUCT.overSegArr(1,:) = 1;
KEYFRAMES_STRUCT.overSegArr(2,1) = 1;

% Z MIN / FRAME LIMIT
KEYFRAMES_STRUCT.zMinArr = zeros(2, max_frame);
KEYFRAMES_STRUCT.zMinArr(1,:) = frame_lim;
KEYFRAMES_STRUCT.zMinArr(2,1) = 1;

% BG OFFSET
KEYFRAMES_STRUCT.bgOffArr = zeros(2, max_frame);
KEYFRAMES_STRUCT.bgOffArr(1,:) = 1;
KEYFRAMES_STRUCT.bgOffArr(2,1) = 1;

% BG PIX
KEYFRAMES_STRUCT.bgPixArr = zeros(2, max_frame);
KEYFRAMES_STRUCT.bgPixArr(1,:) = 1;
KEYFRAMES_STRUCT.bgPixArr(2,1) = 1;

% feature fields -- keyframing
KEYFRAMES_STRUCT.featureFields = {'MEAN','MEDIAN','SUM','SIZE','MAX'};
KEYFRAMES_STRUCT.featureMinMaxes = NaN(3, max_frame, 5); 

% keyframe exclusions -- features
% keyframe exclusions -- manual
tmp_excl_mat = cell(1, max_frame);
for ff=1:max_frame
    next_len = some_lengths(ff);
    tmp_excl_mat{ff} = logical(zeros(next_len, 1));
end
KEYFRAMES_STRUCT.featureExclusion = tmp_excl_mat;
KEYFRAMES_STRUCT.manualExclusion = tmp_excl_mat;
    
% additional spotInfo, in case of referencing errors
KEYFRAMES_STRUCT.spotInfo = spotInfo;

%
%%%
%%%%%
%%%
%