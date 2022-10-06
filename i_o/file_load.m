function [] = file_load(hand, evt, APP)
%% fxn for opening image/movie files
%
%  INPUT: 
%  . hand -- menu object user clicked to initiate selection of new image
%            file
%  . evt -- evt object passed with any callback function
%  . APP -- main application.
%
%  supported image formats: TIFF, DV
%  
%  bioformats required for image input, should be packaged with tool but
%  can be downloaded by navigating to the following URL:
%
%  downloads.openmicroscopy.org/bio-formats/5.5.3/
%

% breadcrumbs
init_folder = pwd;

% currently available image formats: TIFF, DV
% edit March 2022: image class *should* handle all image formats supported by
% bioformats
% valid_format_args = {'*.tif;*.TIF;*.dv;*.DV'};
valid_formats = {'1sc','2fl','acff','afi','afm','aiix',...
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
valid_format_args = '';
for ii=1:length(valid_formats)
    valid_format_args = strcat(valid_format_args,'*.',valid_formats{ii},';');
end
% assignin('base','valid_format_args',valid_format_args);

curr_image_path = getappdata(APP.MAIN,'images_dir_path');
[input_filename, input_filepath] = uigetfile(valid_format_args, 'Load Image');
if isequal(input_filename, 0)
    cd(init_folder);
    return;
end
cd(init_folder);

% IMG = TMP_IMG(input_filename, input_filepath);
IMG = MAT_IMG(input_filename, input_filepath);

app_setup(APP, IMG); 

is_same_path = strcmp(curr_image_path, input_filepath);
if ~is_same_path
    disp('reassigning current images directory');
    setappdata(APP.MAIN, 'images_dir_path',input_filepath);
end

%
%%%
%%%%%
%%%
%