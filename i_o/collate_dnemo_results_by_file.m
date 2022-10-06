%% collate_dnemo_results_by_file.m
%
%  script to pull dnemo 'full_results' mat-files by user and collate them
%  into single (1)
%  - mat-file
%  - xlsx/csv sheet (xlsx for windows, csv for macOS/linux)
%


% pull individual mat-files
[dnemo_filenames, dnemo_filelocs] = uigetfile('*.mat','Select dNEMO ''full_results'' mat-files.','MultiSelect','on');

if iscell(dnemo_filenames)
    prev_dir = cd(dnemo_filelocs);
    
    % multiple mat-files selected
    for file_idx=1:length(dnemo_filenames)
        
        next_file = dnemo_filenames{file_idx};
        RELOAD = load(filename,'KEYFRAMES','cell_signals','polygon_list');
        spot_detect = SPOT_DETECT(RELOAD.KEYFRAMES);
        [spot_arr, print_arr] = parse_keyframes(spot_detect);
        [cells, trajectories] = parse_cells(spot_detect, RELOAD.cell_signals);
        
    end
    
    cd(prev_dir);
    
else
    if dnemo_filenames==0
        % no file selected -- terminate script
        disp('no file selected. terminating script.');
        return
    else
        % single file selected -- use this file
        prev_dir = cd(dnemo_filelocs);
        
        RELOAD = load(dnemo_filenames,'KEYFRAMES','cell_signals','polygon_list');
        spot_detect = SPOT_DETECT(RELOAD.KEYFRAMES);
        [spot_arr, print_arr] = parse_keyframes(spot_detect);
        
        cd(prev_dir);
    end
end


%
%%%
%%%%%
%%%
%