classdef MAT_IMG
    % MAT_IMG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        img_bfreader
        img_filename
        img_filepath
        img_metadata_string
        Width
        Height
        C
        Z
        T
        Type
        RGB
        CurrFrameNo = 0;
        CurrFrame
        CurrChannel
        Extension
        ValidExtensions = {'1sc','2fl','acff','afi','afm','aiix',...
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
        img_imfinfo = [];
        adjustment_number = NaN;
    end
    
    methods
        
        % MAT_IMG constructor class
        function obj = MAT_IMG(img_filename,img_filepath)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            %
            
            input_file_tokens = strsplit(img_filename,'.');
            input_file_extension = lower(input_file_tokens{length(input_file_tokens)});
            
            if any(contains(obj.ValidExtensions, input_file_extension))
                
                % new bioformats reader object
                R = bfGetReader(fullfile(img_filepath, img_filename));
                assignin('base','R',R);
                obj.img_bfreader = R;
                obj.img_filename = img_filename;
                obj.img_filepath = img_filepath;
                obj.img_metadata_string = char(R.getMetadataStore().dumpXML());
                obj.Extension = input_file_extension;
                
                % confirm imfinfo data (TIFF IMPORTANT)
                if strcmp(obj.Extension,'tif')
                    info = imfinfo(fullfile(img_filepath, img_filename));
                    obj.img_imfinfo = info;
                    test_field = info(1).ImageDescription;
                    str1 = 'c0=';
                    some_loc = strfind(test_field,str1);
                    some_loc2 = strfind(test_field,'c1=');
                    if ~isempty(some_loc) && ~isempty(some_loc2)
                        obj.adjustment_number = str2num_GJK(test_field, some_loc+length(str1), some_loc2-1);
                        if obj.adjustment_number == 0
                            obj.adjustment_number = NaN;
                        end
                    end
                    
                else
                    obj.adjustment_number = NaN;
                end
                
                
                % assigning type, XYCZT, isRGB
                obj.Width = R.getSizeX();
                obj.Height = R.getSizeY();
                obj = obj.setCZT(R.getSizeC(), R.getSizeZ(), R.getSizeT());
                
                obj.RGB = obj.isRGB();
                obj.Type = obj.checkType();
                
                % set current channel (RGB shenanigans) 
                if obj.RGB
                    obj.CurrChannel = [1:1:3];
                else
                    obj.CurrChannel = min(1:1:obj.C);
                end
                
                % pull & set current frame
                obj = obj.setCurrFrame(1);
                
            end
                
            
        end
        
        function obj = setCZT(obj, C, Z, T)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.C = C;
            obj.Z = Z;
            obj.T = T;
        end
        
        function obj = setRGB(obj)
            if obj.RGB
                obj.RGB = 0;
                obj.CurrChannel = min(1:1:obj.C);
                tmp_frame_no = obj.CurrFrame;
                obj.CurrFrameNo = 0;
                obj = obj.setCurrFrame(tmp_frame_no);
            else
                obj.RGB = 1;
                obj.CurrChannel = [1:1:3];
                tmp_frame_no = obj.CurrFrameNo;
                obj.CurrFrameNo = 0;
                obj = obj.setCurrFrame(tmp_frame_no);
            end
        end
        
        %
        function C = getC(obj)
            C = obj.C;
        end
        
        %
        function Z = getZ(obj)
            Z = obj.Z;
        end
        
        %
        function T = getT(obj)
            T = obj.T;
        end
        
        %
        function rgb_bool = isRGB(obj)
            rgb_bool = obj.img_bfreader.isRGB();
        end
        
        % 
        function class_string_input = checkType(obj)
            valid_image_type_strings = {'int8',...
                                        'uint8',...
                                        'int16',...
                                        'uint16',...
                                        'int32',...
                                        'uint32',...
                                        'int64',...
                                        'uint64',...
                                        'single',...
                                        'double'};
            type_string_keyword = 'Type=';
            xml_breakup = strsplit(obj.img_metadata_string, ' ');
            [some_locs_k] = strfind(xml_breakup, type_string_keyword);
            type_string_loc = find(~cellfun(@isempty, some_locs_k));
            type_tokens = strsplit(xml_breakup{type_string_loc(1)},'"');
            tmp_type_loc = find(contains(type_tokens, type_string_keyword));
            input_image_type = lower(type_tokens{tmp_type_loc+1});
            if contains(valid_image_type_strings, input_image_type)
                class_string_input = input_image_type;
            else
                class_string_input = NaN;
            end
        end
        
        % 
        function obj = setCurrChannel(obj, cc)
            if cc==obj.CurrChannel || cc < 1 || cc > obj.C
                obj.CurrChannel = obj.CurrChannel;
            else
                obj.CurrChannel = cc;
            end
            obj = obj.setCurrFrame(obj.CurrFrameNo);
        end
        
        %
        function obj = setCurrFrame(obj, frame_no)
            
            if obj.CurrFrameNo ~= frame_no
                
                obj.CurrFrameNo = frame_no;
                
                % miiiiight not have to do distinction for multichannel
                % images -- something's not right for RGB
                
                
                
                %
                if obj.RGB
                    % todo -- multichannel shenanigans
                    % definitely need a rethink, what I have's not quite
                    % right
                    
                else
                    % SOOOOO -- doing it w/ indexing from the bioformats,
                    % should ignore interleaving this way...
                    current_channel = obj.CurrChannel;
                    zz_inds = 1:1:obj.Z;
                    current_timepoint = obj.CurrFrameNo;
                    
                    %{
                    tmp_indexing_arr = zeros(length(zz_inds),1);
                    R2 = obj.img_bfreader;
                    assignin('base','R2',R2);
                    assignin('base','zz_inds',zz_inds);
                    assignin('base','current_channel',current_channel);
                    assignin('base','current_timepoint',current_timepoint);
                    %}
                    
                    for tmp=1:length(zz_inds)
                        try
                            next_ind_WRONG = obj.img_bfreader.getIndex(zz_inds(tmp)-1, current_channel-1, current_timepoint-1);
                        catch
                            next_ind_WRONG = obj.img_bfreader.getIndex(current_timepoint-1, current_channel-1, zz_inds(tmp)-1);
                        end
                        frameArray(:,:,tmp) = bfGetPlane(obj.img_bfreader, next_ind_WRONG+1);
                    end
                    
                    obj.CurrFrame = obj.optionalMod(frameArray);
                    
                    % todo -- either non-RGB multichannel or single channel
                    %{
                    tmp_indexing_arr = 1:obj.C:obj.Z*obj.C;
                    for zz=1:1:length(tmp_indexing_arr)
                        curr_ind = ((frame_no-1)*(obj.Z*obj.C))+tmp_indexing_arr(zz);
                        frameArray(:,:,zz) = bfGetPlane(obj.img_bfreader, curr_ind);
                    end
                    %

                    obj.CurrFrame = obj.optionalMod(frameArray);
                    %}
                end
                %
            else
                
                current_channel = obj.CurrChannel;
                zz_inds = 1:1:obj.Z;
                current_timepoint = obj.CurrFrameNo;
                for tmp=1:length(zz_inds)
                    try
                        next_ind_WRONG = obj.img_bfreader.getIndex(zz_inds(tmp)-1, current_channel-1, current_timepoint-1);
                    catch
                        next_ind_WRONG = obj.img_bfreader.getIndex(current_timepoint-1, current_channel-1, zz_inds(tmp)-1);
                    end
                    frameArray(:,:,tmp) = bfGetPlane(obj.img_bfreader, next_ind_WRONG+1);
                end

                obj.CurrFrame = obj.optionalMod(frameArray);
                
                
            end
            

        end
        
        % 
        function frameArray = optionalMod(obj, frameArray)
            if strcmp(obj.Extension, 'dv')
                for zz=1:size(frameArray, 3)
                    frameArray(:,:,zz) = flip(frameArray(:,:,zz));
                end
            end
            if strcmp(obj.Extension, 'tif') && ~isnan(obj.adjustment_number)
                % more business to do w/ TIF problems...
                % frameArray = frameArray-typecast(obj.adjustment_number, class(frameArray));
                %
                frameArray = frameArray + obj.adjustment_number;
            end
        end
        
        %
        function frameArray = getCurrFrame(obj)
            frameArray = obj.CurrFrame;
        end
        
        % 
        function max_proj = getZProject(obj)
            frameArray = obj.getCurrFrame();
            max_proj = max(frameArray,[],3);
        end
        
        %
        function image_slice = getZSlice(obj, slice)
            frameArray = obj.getCurrFrame();
            image_slice = frameArray(:,:,slice);
        end
        
        %
        function image_dims = getImageDims(obj)
            image_dims = [obj.C obj.Z obj.T];
        end
        
        %
        function MI = displayImage(obj)
            
            MI.MAIN = figure('units','normalized',...
                             'position',[0.05 0.05 0.9 0.85],...
                             'menubar','none',...
                             'toolbar','figure',...
                             'name',obj.img_filename,...
                             'numbertitle','off',...
                             'resize','on');
            %
            MI.ax_01 = axes('units','normalized',...
                            'position',[0.01 0.04 0.58 0.94],...
                            'YDir','reverse',...
                            'XTick',[],...
                            'YTick',[]);
            %
            MI.ax_02 = axes('units','normalized',...
                            'position',[0.01 0.04 0.58 0.94],...
                            'color','none',...
                            'YDir','reverse',...
                            'XAxisLocation','top',...
                            'XLimMode','auto',...
                            'YLimMode','auto',...
                            'hittest','on',...
                            'pickableparts','visible',...
                            'nextplot','add',...
                            'xtick',[],...
                            'ytick',[]);
            %
            MI.frame_slider = uicontrol('style','slide',...
                                        'unit','normalized',...
                                        'position',[0.01 0.005 0.58 0.025],...
                                        'min',1,...
                                        'max',1,...
                                        'val',1,...
                                        'visible','on',...
                                        'enable','off');
            %
            
        end    
                
    end
end

