function [] = run_pipeline_dnemo(APP, dnemo_param_struct)
%% <placeholder>
%

par_string_01 = 'Setting up parallel processing if possible.';
update_log_window(APP, par_string_01);
%{
set_par_processes();

curr_pool_obj = gcp('nocreate');
if ~isempty(curr_pool_obj)
    num_workers = curr_pool_obj.NumWorkers;
    par_string_02 = char(strcat('Parallel pool w/',{' '},num2str(num_workers),{' '},'workers created.'));
else
    par_string_02 = 'Parallel pool not initialized.';
end
update_log_window(APP, par_string_02);
update_log_window(APP, '%%%%%%%%%%%%%%%');
update_log_window(APP, '%%%%%%%%%%%%%%%');
%}
init_dir = cd;
image_directory = APP.input_dir_display.String;
results_directory = APP.output_dir_display.String;

image_filenames = APP.input_textbox.String;

for file_idx=1:length(image_filenames)
    
    curr_filename = image_filenames{file_idx};
    dnemo_string_02 = char(strcat('Processing:',{' '},curr_filename));
    update_log_window(APP, dnemo_string_02);
    
    % IMG = TMP_IMG(curr_filename, image_directory);
    IMG = MAT_IMG(curr_filename, image_directory);
    dnemo_string_03 = char(strcat(curr_filename,{' '},'successfully loaded into workspace.'));
    update_log_window(APP, dnemo_string_03);
    
    curr_frame = im2double(IMG.getCurrFrame());
    [spotInfo, ~] = spot_finder_interruptible_mod(curr_frame, dnemo_param_struct, dnemo_param_struct.USER_THRESH);
    
    if dnemo_param_struct.NUM_PIX_BG
        if IMG.Z==1
            [BG_VALS,~] = two_dim_bg_calc(curr_frame, spotInfo, dnemo_param_struct.NUM_PIX_OFF, dnemo_param_struct.NUM_PIX_BG);
            spotInfo.BG_VALS = BG_VALS;
        else
            [BG_VALS,~] = assign_bg_pixels(curr_frame, spotInfo, dnemo_param_struct.NUM_PIX_OFF, dnemo_param_struct.NUM_PIX_BG);
            spotInfo.BG_VALS = BG_VALS;
        end
    end
    
    overlay_obj = TMP_OVERLAY(spotInfo, dnemo_param_struct);
    overlay_obj = overlay_obj.updateSpotFeatures(dnemo_param_struct.NUM_PIX_OFF, dnemo_param_struct.NUM_PIX_BG);
    
    curr_spot_detect = SPOT_DETECT(IMG, overlay_obj);
    
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
    
    %
    cell_signals = {};
    polygon_list = {};
    KEYFRAMES.spotInfo = KEYFRAMES.spotInfoArr;
    original_image = curr_filename;
    
    cd(results_directory);
    save(results_filename,'KEYFRAMES','cell_signals','polygon_list','original_image','-v7.3');
    
    % mat-file w/ spot data ONLY
    [spot_arr, print_arr] = parse_keyframes(curr_spot_detect);
    spot_mat_file = strcat(sub_filename,'_ALL_SPOTS.mat');
    save(spot_mat_file,'spot_arr','-v7.3');
    
    % excel spreadsheet w/ spot data
    dnemo_results_to_excel_BATCH(sub_filename, {spot_arr});
    
    %}
    cd(init_dir);
    
end



%
%%%
%%%%%
%%%
%