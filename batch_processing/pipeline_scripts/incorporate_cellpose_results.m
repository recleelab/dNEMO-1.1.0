function [] = incorporate_cellpose_results(APP)
%% <placeholder>
%

init_dir = cd;
image_directory = APP.input_dir_display.String;
results_directory = APP.output_dir_display.String;

image_filenames = APP.input_textbox.String;

rescaled_tif_dir = fullfile(results_directory,'rescaled_tifs');

for img_idx=1:length(image_filenames)
    
    dnemo_results_flag = 0;
    cellpose_results_flag = 0;
    
    next_img_filename = image_filenames{img_idx};
    some_str_tokens = strsplit(next_img_filename,'.');
    root_name = some_str_tokens{1}
    ref_filename = strcat(some_str_tokens{1},'_REF_rescMasks.tif');
    
    if APP.cellpose_use_ref_images.Value && exist(ref_filename, 'file') == 2
        cellpose_results_filename = ref_filename;
    else
        cellpose_results_filename = char(strcat(some_str_tokens{1},'_rescMasks.tif'));
    end
    prev_dir = cd(rescaled_tif_dir);
    if isfile(cellpose_results_filename)
        cellpose_results_flag = 1;
    end
    cd(prev_dir);
    
    dnemo_results_filename = char(strcat(some_str_tokens{1},'_full_results.mat'));
    prev_dir = cd(results_directory);
    if isfile(dnemo_results_filename)
        dnemo_results_flag = 1;
    end
    
    if dnemo_results_flag && cellpose_results_flag
        
        % reload dnemo results
        incorp_string_01 = char(strcat('Reloading',{' '},dnemo_results_filename,'.'));
        update_log_window(APP, incorp_string_01);
        
        cd(results_directory);
        RELOAD = load(dnemo_results_filename,'KEYFRAMES','cell_signals','polygon_list');
        import_spot_detect = SPOT_DETECT(RELOAD.KEYFRAMES);
        
        incorp_string_02 = char(strcat('Creating polygon objects from',{' '},cellpose_results_filename,'.'));
        update_log_window(APP, incorp_string_02);
        
        [import_polygon_list] = convert_mask_to_poly_objects(rescaled_tif_dir, cellpose_results_filename);
        
        % assign to pipeline.MAIN (code reuse, just easier)
        setappdata(APP.MAIN,'spot_detect',import_spot_detect);
        setappdata(APP.MAIN,'cell_signals',RELOAD.cell_signals);
        setappdata(APP.MAIN,'polygon_list',import_polygon_list);
        
        incorp_string_03 = char(strcat('Coordinating spots to polygon objects.'));
        update_log_window(APP, incorp_string_03);
        
        % run coordination
        coordinate_spots_to_cells(APP);
        
        incorp_string_04 = char(strcat('Writing results to',{' '},dnemo_results_filename));
        update_log_window(APP, incorp_string_04);
        
        % pull results
        spot_detect = getappdata(APP.MAIN,'spot_detect');
        cell_signals = getappdata(APP.MAIN,'cell_signals');
        polygon_list = getappdata(APP.MAIN,'polygon_list');
        
        KEYFRAMES = struct;
        spot_detect_fields = spot_detect.getSpotDetectFields();
        for field_idx=1:length(spot_detect_fields)
            KEYFRAMES.(spot_detect_fields{field_idx}) = spot_detect.(spot_detect_fields{field_idx});
        end
    

        KEYFRAMES.spotInfo = KEYFRAMES.spotInfoArr;
        original_image = next_img_filename;
    
        save(dnemo_results_filename,'KEYFRAMES','cell_signals','polygon_list','original_image','-v7.3');
        
        [cells, trajectories] = parse_cells(spot_detect, cell_signals);
        cell_filename = strcat(root_name,'_ALL_CELLS');
        save(cell_filename,'cells','trajectories','-v7.3');
        
        % dnemo_results_to_excel(some_str_tokens{1}, {spot_arr; cells; trajectories});
        
        cd(init_dir);
        
    end
    
    
end

cd(init_dir);

%
%%%
%%%%%
%%%
%