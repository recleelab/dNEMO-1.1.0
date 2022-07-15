function [] = set_image_two_dim(hand, evt, APP)
%% <placeholder>
%

IMG = getappdata(APP.MAIN,'IMG');

user_answer = questdlg('Setting image dimensions to 2D will override current image dimensions. Proceed?',...
                       'Set Image to 2D',...
                       'Yes', 'No', 'No');
switch user_answer
    case 'Yes'
        curr_dims = IMG.getImageDims();
        num_frames = prod(curr_dims(2:end));
        IMG.Z = 1;
        IMG.T = num_frames;
        IMG = IMG.setCurrFrame(APP.film_slider.Value);
        setappdata(APP.MAIN,'IMG',IMG);
        
        % handling film slider
        % figure startup - movie slider
        if IMG.T == 1
            APP.film_slider.Value = 1;
            APP.film_slider.Enable = 'off';
            APP.film_slider.Visible = 'off';
            APP.film_slider.Max = 1;
        else
            APP.film_slider.Min = 1;
            APP.film_slider.Max = IMG.T;
            APP.film_slider.SliderStep = [1/IMG.T 1/IMG.T];
            APP.film_slider.Enable = 'on';
            APP.film_slider.Visible = 'on';
        end
        display_call(hand, evt, APP);
        
    case 'No'
        return
end

%
%%%
%%%%%
%%%
%