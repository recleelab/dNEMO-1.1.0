function [] = input_directory_select(hand, evt, APP)
%% function = input_directory_select(hand, evt, APP)
%
% Author: Gabriel J Kowalczyk (gjk20@pitt.edu)
% Date: April 2021
% 
% Description: 'input_directory_select' is a uicontrol callback function
% which runs when the user clicks on the 'Browse...' button in the input 
% directory panel of the main pipeline GUI. It returns nothing, but updates 
% the pipeline GUI in various ways, here passed into the function as 'APP'.
% 
% Input:
%     - hand: uicontrol handle for PIPELINE.input_dir_select
%     - evt: user interaction click
%     - APP: PIPELINE application structure, contains references to all
%       GUI components and additional data
% 
% Output: 
%     N/A
%
% Additional notes:
% . editbox displaying location - APP.input_dir_display
% . editbox displaying contents - APP.input_textbox

[input_dir] = uigetdir();
if input_dir ~= 0
    
    % display selected directory string
    APP.input_dir_display.String = input_dir;
    APP.input_dir_display.Enable = 'inactive';
    
    % pull valid image filenames
    prev_folder = cd(input_dir);
    
    listing = dir;
	logically_dirs = [listing.isdir].';
	all_names = {listing.name}.';
	file_names = all_names(~logically_dirs);
    assignin('base','file_names',file_names);
    
    % fmt_arg = getappdata(APP.MAIN,'valid_image_format_arg');
    fmt_arg = {'1sc','2fl','acff','afi','afm','aiix',...
            'aim','aisf','al3d','ali','am','amiramesh','ano','apl',...
            'arf','atsf','avi','bin','bip','bmp','btf','c01','cfg',...
            'ch5','cif','companion.ome','cr2','crw','csv','cxd','czi',...
            'dat','dcm','df3','dib','dic','dicom','dm2','dm3','dm4',...
            'dti','dv','dv.log','env','eps','epsi','ets','exp','fake',...
            'fdf','fff','ffr','fits','flex','fli','frm','fts','gel',...
            'gif','grey','hdf','hdr','hed','his','htd','htm','html',...
            'hx','i2i','ics','ids','im3','ima','img','ims','inf','inr',...
            'ipl','ipm','ipw','j2k','j2ki','j2kr','jp2','jpe','jpeg',...
            'jpf','jpg','jpk','jpx','l2d','labels','lei','lif','liff',...
            'lim','lms','log','lsm','lut','map','mdb','mea','mnc',...
            'mng','mod','mov','mrc','mrcs','mrw','msr','mtb','mvd2',...
            'naf','nd','nd2','ndpi','ndpis','nef','nhdr','nii',...
            'nii.gz','nrrd','obf','oib','oif','ome','ome.btf',...
            'ome.tf2','ome.tf8','ome.tif','ome.tiff','ome.xml','par',...
            'pattern','pbm','pcoraw','pct','pcx','pgm','pic','pict',...
            'png','pnl','ppm','pr3','ps','psd','pst','pty','r3d',...
            'r3d.log','r3d_d3d','raw','rec','res','scn','sdt','seq',...
            'set','sif','sld','sm2','sm3','spc','spe','spi','spl',...
            'st','stk','stp','svs','sxm','tf2','tf8','tfr','tga',...
            'thm','tif','tiff','tim','tnb','top','txt','v','vms',...
            'vsi','vws','wat','wav','wlz','xdce','xlog','xml','xqd',...
            'xqf','xv','xys','zfp','zfr','zip','zpo','zvi'};
	[valid_filenames] = pull_valid_images(file_names, fmt_arg);
    assignin('base','valid_filenames',valid_filenames);
    % [results_filenames] = pull_results_filenames(file_names, 'full_results');
    cd(prev_folder);
    
    % updated directory textbox w/ valid image filenames
    APP.input_textbox.String = valid_filenames;
	APP.input_textbox.Enable = 'inactive';
	APP.input_textbox.Max = length(valid_filenames);
    
else
    
    % confirm current value w/in 'input_dir_display'
    current_display_string = APP.input_dir_display.String;
    if isempty(current_display_string)
        APP.input_dir_display.Enable = 'off';
    end
    
end

%
%%%
%%%%%
%%%
%