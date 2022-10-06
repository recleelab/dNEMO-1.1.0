%% scratch paper
%
% problem -- cellpose really doesn't like Yue's new data...
%

% source image
test_img_filename = '10xpp7_12xSunTag_15_single_construct_new_5x_31_31_R3D_TRUNC.tif';
test_img_filepath = 'N:\LabUserFiles\Gabe_Kowalczyk\papers\SUNRISER_dNEMO_STAR_Protocols_RD\images_rescaled_test\';
test_img = MAT_IMG(test_img_filename, test_img_filepath);

% cellpose-generated mask (SUM intensity)
mask_filename = 'SUM_10xpp7_12xSunTag_15_single_construct_new_5x_31_31_R3D_TRUNC_RESCMasks.tif';
mask_filepath = 'N:\LabUserFiles\Gabe_Kowalczyk\papers\SUNRISER_dNEMO_STAR_Protocols_RD\images_rescaled_test\';
[mask_arr] = masks_from_tif(mask_filepath, mask_filename);

% actual call, potentially want to update to make it be able to handle
% including mask information in the function call
[CMH_GUI] = cell_mask_handler_GUI([], [], test_img);

%
%%%
%%%%%
%%%
%