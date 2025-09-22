function [num_cores] = par_get_num_cores()
%% <placeholder>
%

descriptor_string = evalc('feature(''numcores'')');
end_loc = strfind(descriptor_string,'physical');
another_loc = strfind(descriptor_string,':');

num_cores = str2num(descriptor_string(another_loc(1)+1:end_loc-1))

%
%%%
%%%%%
%%%
%