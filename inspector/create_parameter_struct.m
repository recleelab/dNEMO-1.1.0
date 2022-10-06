function [settings_struct] = create_parameter_struct(SOME_FIG,num_arg)
%% simple function to create parameter structure for the inspector
%
%  INPUT:
%  . SOME_FIG - inspector  figure handle
% 
%  OUTPUT:
%  . settings_struct - settings structure to be returned to the main
%                      program (DNEMO)
%

settings_struct = struct;

min_sig_intensity = str2num(SOME_FIG.min_intensity_box.String);
max_sig_intensity = str2num(SOME_FIG.max_intensity_box.String);

settings_struct.paramIntensity = [min_sig_intensity max_sig_intensity];

min_sig_size = str2num(SOME_FIG.min_size_box.String);
max_sig_size = str2num(SOME_FIG.max_size_box.String);

settings_struct.paramSize = [min_sig_size max_sig_size];

%
%%%
%%%%%
%%%
%