function [] = run_pipeline(hand, evt, APP)
%% <placeholder>
%

% pull pipeline operations structure
pipeline_operations = getappdata(APP.MAIN,'pipeline_operations');

% DNEMO
run_dnemo = pipeline_operations.RUN_DNEMO;
if run_dnemo
    
    pipe_string_01 = 'Running dNEMO over images from Input Dir.';
    update_log_window(APP, pipe_string_01);
    update_log_window(APP, '%%%%%%%%%%%%%%%');
    update_log_window(APP, '%%%%%%%%%%%%%%%');
    
    % image_directory = APP.input_dir_display.String;
    % image_filenames = APP.input_textbox.String;
    dnemo_param_struct = getappdata(APP.MAIN,'dnemo_param_struct');
    run_pipeline_dnemo(APP, dnemo_param_struct);
    
end

pipe_string_02 = 'dNEMO operation concluded.';
update_log_window(APP, pipe_string_02);
update_log_window(APP, '%%%%%%%%%%%%%%%');
update_log_window(APP, '%%%%%%%%%%%%%%%');

% CELLPOSE
run_cellpose = pipeline_operations.RUN_CELLPOSE;
if run_cellpose
    
    pipe_string_03 = 'running Cellpose over images from Input Dir.';
    update_log_window(APP, pipe_string_03);
    update_log_window(APP, '%%%%%%%%%%%%%%%');
    update_log_window(APP, '%%%%%%%%%%%%%%%');
    
    cellpose_param_struct = getappdata(APP.MAIN,'cellpose_param_struct');
    run_pipeline_cellpose(APP, cellpose_param_struct);
    
end

% U-TRACK
%{
run_utrack = pipeline_operations.RUN_UTRACK;
if run_utrack
    
    pipe_string_04 = 'Running u-track over results';
    update_log_window(APP, pipe_string_04);
    update_log_window(APP, '%%%%%%%%%%%%%%%');
    update_log_window(APP, '%%%%%%%%%%%%%%%');
    
    utrack_param_struct = getappdata(APP.MAIN,'utrack_param_struct');
    run_pipeline_utrack(APP, utrack_param_struct);
    
end
%}
%
%%%
%%%%%
%%%
%