function [] = delete_bkgd_param_keyframe(hand, evt, APP)
%% <placeholder>
%

spot_detect = getappdata(APP.MAIN,'spot_detect');
IMG = getappdata(APP.MAIN,'IMG');
sel_string = APP.keyframing_map.String{APP.keyframing_map.Value};
spot_detect = spot_detect.removeBGParam(sel_string, IMG);
setappdata(APP.MAIN,'spot_detect',spot_detect);
% additional updates based on any background-collection information shifts

update_keyframe_data(APP);
display_call(APP.keyframing_map,1,APP);

%
%%%
%%%%%
%%%
%