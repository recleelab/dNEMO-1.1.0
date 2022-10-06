function [] = apply_save_data_to_new_channel(APP, results_filename)
%% <placeholder>
%

% pull image data from application
IMG = getappdata(APP.MAIN,'IMG');
num_channels = IMG.C;
curr_channel = IMG.CurrChannel;

% user argument to change channels here
% TODO

% new channel to set
some_answer = inputdlg('Please input which channel to apply spot data to:','Applying Spot Data to Secondary Channel');
if ~isempty(some_answer)
    new_channel = str2num(cell2mat(some_answer));
else
    return;
end

% check for valid channel
% TODO

% pull spot data
spot_detect = getappdata(APP.MAIN,'spot_detect');
spotInfoArr = spot_detect.spotInfoArr;
bgOffArr = spot_detect.bgOffArr;
bgPixArr = spot_detect.bgPixArr;

num_frames = IMG.T;
IMG.CurrChannel = new_channel;

% output
updated_spotInfoArr = cell(size(spotInfoArr));

wbar = waitbar(0,'Extract Pix. Values from Alt. Channel 0% Complete');

% foreach frame
for tt=1:num_frames
    
    % pull correct image
    IMG = IMG.setCurrFrame(tt);
    next_frame = IMG.getCurrFrame();
    next_frame = im2double(next_frame);
    
    % pull spotInfo from spotInfo array
    spotInfo = spotInfoArr{tt};
    
    % re-run regionprops to get pixel list using label matrices
    updated_lbls = spotInfo.UL;
    pixlist = cell(IMG.Z,1);
    for zz=1:IMG.Z
        alt_props = regionprops(updated_lbls{zz},'PixelList');
        tmp_pixlist = {alt_props.PixelList}';
        pixlist{zz} = tmp_pixlist(2:end,1);
    end
    
    % reassign SIG_VALS using the correct image
    new_SIG_VALS = cell(size(spotInfo.SIG_VALS,1),2);
    spotMat = spotInfo.spotMat;
    spotCount = size(spotMat,1);
    
    for i=1:spotCount
        frames = find(spotMat(i,:)~=0);

        allintensities = zeros(750,1);
        max_mean_slice_intensity = 0;
        tmp_mid_intensities = [];

        for j=1:length(frames)

            pixlist_currentframe = pixlist{frames(j)};
            intensityvals = next_frame(sub2ind(size(next_frame),...
                pixlist_currentframe{spotMat(i,frames(j))}(:,2),... %y
                pixlist_currentframe{spotMat(i,frames(j))}(:,1),... %x
                frames(j)*ones(length(pixlist_currentframe{spotMat(i,frames(j))}(:,1)),1))); %z		
            firstnz = find(allintensities==0,1);
            while (firstnz + length(intensityvals)-2) > size(allintensities,1)
                larger_allintensities = quiet_resize(allintensities,firstnz);
                allintensities = larger_allintensities;
            end
            allintensities(firstnz:firstnz+length(intensityvals)-1) = intensityvals;

            % determining z_coordinate via raw intensity comparison
            mean_slice_intensity = mean(intensityvals(intensityvals>0));
            if (mean_slice_intensity > max_mean_slice_intensity)
                max_mean_slice_intensity = mean_slice_intensity;
                tmp_mid_intensities = intensityvals;
            end

        end

        allintensities(allintensities==0) = [];
        new_SIG_VALS{i,1} = allintensities; % full signal intensities
        new_SIG_VALS{i,2} = tmp_mid_intensities; % middle slice intensities

    end
    
    spotInfo.SIG_VALS = new_SIG_VALS;
    
    % pull BG_VALS using background offset, pixels
    num_pix_off = bgOffArr(1,tt);
    num_pix_bg = bgPixArr(1,tt);
    [BG_VALS, ~] = assign_bg_pixels(next_frame, spotInfo, num_pix_off, num_pix_bg);
    spotInfo.BG_VALS = BG_VALS;
    
    % handling output
    updated_spotInfoArr{tt} = spotInfo;
    
    % waitbar handling
    percent_done = tt/num_frames;
    displayed_percent_done = num2str(round(percent_done*100));
    percent_done_message = strcat('Extract Pix. Values from Alt. Channel',{' '},displayed_percent_done,'% Complete');
    waitbar(percent_done,wbar,percent_done_message);
    
end

delete(wbar);

PRIOR_CHANNEL_SAVE = load(results_filename);
KEYFRAMES = PRIOR_CHANNEL_SAVE.KEYFRAMES;
KEYFRAMES.spotInfoArr = updated_spotInfoArr;
KEYFRAMES.spotInfo = updated_spotInfoArr;
cell_signals = PRIOR_CHANNEL_SAVE.cell_signals;
polygon_list = PRIOR_CHANNEL_SAVE.polygon_list;

% save filename here
save('channel_02_data','KEYFRAMES','cell_signals','polygon_list','-v7.3');

%
%%%
%%%%%
%%%
%

function [larger_val_storage] = quiet_resize(smaller_val_storage,first_nz)
%% quiet fxn to quickly handle appropriate resize
% 

current_size = size(smaller_val_storage,1);
larger_val_storage = zeros(current_size*2,1);
larger_val_storage(1:first_nz-1,1) = smaller_val_storage(1:first_nz-1,1);

%
%%%
%%%%%
%%%
%