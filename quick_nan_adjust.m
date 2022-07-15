function [background_pix] = quick_nan_adjust(background_pix, nan_01, nan_02)
%% 
% . nan values arise in background pixel values from spots being completely
% enclosed by other spots, no background is available for assignment
% because it's oversegmented. now adjustment needs to be made in dNEMO to
% account for this case, but for now, because it's completely surrounded,
% it's background logically would be very low, because it's entirely 
% surrounded by other spots' pixels. so for now take the lowest
% 5 background values for the current image until adjustment can be made in
% dNEMO

nan_locs = cat(1,nan_01, nan_02);
all_bgd_vals = sort(cell2mat(background_pix));
for nn=1:length(nan_locs)
    background_pix{nan_locs(nn),:} = all_bgd_vals(1:5);
end

%
%%%
%%%%%
%%%
%