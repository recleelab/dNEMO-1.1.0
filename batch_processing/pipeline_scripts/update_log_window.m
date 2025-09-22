function [] = update_log_window(APP, next_string)
%% <placeholder>
%

curr_string = APP.log_window.String;
if isempty(curr_string)
    APP.log_window.String = {next_string};
else
    APP.log_window.String = cat(1,curr_string, {next_string});
    APP.log_window.Max = APP.log_window.Max + 1;
end

%
%%%
%%%%%
%%%
%