function [] = save_as_avi(hand, evt, APP)
%% <placeholder>
%

IMG = getappdata(APP.MAIN,'IMG');
image_filename = IMG.img_filename;
S = strsplit(image_filename,'.');
root_name = S{1};

[save_directory] = uigetdir(cd,'Select location to save AVI');
if ~ischar(save_directory)
    return;
end

prev_dir = cd(save_directory);
[avi_created] = create_avi(APP, root_name);
cd(prev_dir);

%
%%%
%%%%%
%%%
%