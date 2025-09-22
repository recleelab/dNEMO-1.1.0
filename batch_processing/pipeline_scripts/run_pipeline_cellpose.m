function [] = run_pipeline_cellpose(APP, cellpose_param_struct)
%% <placeholder>
%

init_dir = cd;
image_directory = APP.input_dir_display.String;
results_directory = APP.output_dir_display.String;

image_filenames = APP.input_textbox.String;

% MODIFICATION FOR REF IMAGES
if APP.cellpose_use_ref_images.Value
    cd(image_directory);
    for img_idx=1:length(image_filenames)
        next_filename = image_filenames{img_idx};
        next_tokens = strsplit(next_filename,'.');
        updated_filename = strcat(next_tokens{1},'_REF.',next_tokens{2});
        if exist(updated_filename, 'file') == 2
            image_filenames{img_idx} = updated_filename;
        end
    end
end

%{
python3_loc_string = '/Library/Frameworks/Python.framework/Versions/3.7/bin:/Library/Frameworks/Python.framework/Versions/3.6/bin:/Library/Frameworks/Python.framework/Versions/3.6/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin';
setenv('PATH', python3_loc_string);

executable_loc_string = '/Library/Frameworks/Python.framework/Versions/3.7/bin/python3';
pyversion(executable_loc_string);
%}

cd(results_directory);
mkdir('rescaled_tifs');
addpath(fullfile(results_directory,'rescaled_tifs'));
cd('rescaled_tifs');

% run rescale
pix_dimension = cellpose_param_struct.RESCALE;

for file_idx=1:length(image_filenames)
    next_filename = image_filenames{file_idx};
    disp(next_filename);
    cellpose_string_01 = char(strcat('Rescaling:',{' '},next_filename));
    update_log_window(APP, cellpose_string_01);
    
    file_tokens = strsplit(next_filename,'.');
    
    output_filename = char(strcat(file_tokens{1},'_rescale.tif'));
        
    img_object = MAT_IMG(next_filename, image_directory);        
    for ff=1:img_object.T
        img_object = img_object.setCurrFrame(ff);
        tmp_frame = img_object.getCurrFrame();
        sum_project = sum(tmp_frame, 3);
        rescaled_factor = pix_dimension./img_object.Height;
        rescaled_projection = imresize(sum_project, rescaled_factor);
        imwrite(uint16(rescaled_projection), output_filename, 'WriteMode','append');
    end
end

location_command_string = char(strcat('cd',{' '},init_dir));
assignin('base','location_command_string',location_command_string);
[err_flag1, cmd_out1] = system(location_command_string);
assignin('base','err_flag1',err_flag1);
assignin('base','cmd_out1',cmd_out1);

process_this_dir = cd;
cd(init_dir);

cellpose_string_02 = char(strcat('Segmenting rescaled images from',{' '},char(process_this_dir)));
update_log_window(APP, cellpose_string_02);

% run cellpose
python_command_string = char(strcat('python3',{' '},'CellPoseBatchProcessing_mod_GJK.py',{' '},'''',process_this_dir,''''));
assignin('base','python_command_string',python_command_string);
[err_flag2, cmd_out2] = system(python_command_string);
assignin('base','err_flag2',err_flag2);
assignin('base','cmd_out2',cmd_out2);

cd(init_dir);

if err_flag1==0 && err_flag2==0
    
    cellpose_string_03 = 'Completed cellpose segmentation.';
    update_log_window(APP, cellpose_string_03);
    cellpose_string_04 = 'Updating dNEMO results with segmentation results.';
    update_log_window(APP, cellpose_string_04);
    
    incorporate_cellpose_results(APP); 
    
end

%
%%%
%%%%%
%%%
%