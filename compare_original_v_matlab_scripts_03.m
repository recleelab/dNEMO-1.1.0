%% compare_original_v_matlab_scripts_03.m
%
%  want to compare TCR-SABR detections via HITS vs. MISSES
%

test_figure = figure('units','normalized',...
                     'position',[0.15 0.125 0.74 0.76]);

% set up parallel processing
set_par_processes();

% param headers (for later structure array)
param_strings = {'total_TCR','total_SABR','TCR_per_drop','SABR_per_drop','droplet_num','false_pos','false_neg'};

%% going to go ahead and run this 1000 times per condition, then plot
%  - detections from HITS
%  - detections from MISSES
%  - total detections (not necessarily additive)
%

% number of TCRs, SABRs
number_TCR_space = 50:50:500;
number_SABR_space = 50:50:500;

% number of TCRs, SABRs per droplet
per_drop_TCR_space = 1;
per_drop_SABR_space = 1;

% number of droplets
droplet_number_space = 10000;

% number of false positives, false negatives
false_pos_space = 0;
false_neg_space = 0;

% enumerate all possible combinations
space_combs = allcomb(number_TCR_space,...
                      number_SABR_space,...
                      per_drop_TCR_space,...
                      per_drop_TCR_space,...
                      droplet_number_space,...
                      false_pos_space,...
                      false_neg_space);
                  
% for ease of plotting, remove combinations where first and second columns
% do not match
space_combs(space_combs(:,1)~= space_combs(:,2),:) = [];

% run it
output_arr = cell(size(space_combs, 1),100);
number_tcrs_identified = zeros(size(output_arr));
number_tcrs_identified_HITS = zeros(size(output_arr));
number_tcrs_identified_MISSES = zeros(size(output_arr));
for jj=1:size(space_combs, 1)
    parfor ii=1:size(output_arr, 2)
        output_arr{jj, ii} = run_droplet_model(space_combs(jj,:), param_strings);
        number_tcrs_identified(jj, ii) = output_arr{jj, ii}.number_Correct_TCR;
        number_tcrs_identified_HITS(jj, ii) = output_arr{jj, ii}.number_Correct_TCR_HITS;
        number_tcrs_identified_MISSES(jj, ii) = output_arr{jj, ii}.number_Correct_TCR_MISSES;
    end
end

%% plotting
%

plotting_arr = NaN(size(output_arr, 1),6);
for ii=1:size(output_arr, 1)
    plotting_arr(ii, 1) = mean(number_tcrs_identified(ii,:));
    plotting_arr(ii, 2) = std(number_tcrs_identified(ii,:))*2;
    plotting_arr(ii, 3) = mean(number_tcrs_identified_HITS(ii,:));
    plotting_arr(ii, 4) = std(number_tcrs_identified_HITS(ii,:))*2;
    plotting_arr(ii, 5) = mean(number_tcrs_identified_MISSES(ii,:));
    plotting_arr(ii, 6) = std(number_tcrs_identified_MISSES(ii,:))*2;
end

ax_01 = subplot(1,3,1,'nextplot','add');
errorbar(number_TCR_space.', plotting_arr(:,1), plotting_arr(:,2),'linewidth',1.5);
xlabel('Variant Pool Size');
ylabel('Number of crrectly Identified TCRs');
title('TCRs identified by HITS + MISSES (10000 droplets)');

ax_02 = subplot(1,3,2,'nextplot','add');
errorbar(number_TCR_space.', plotting_arr(:,3), plotting_arr(:,4),'linewidth',1.5);
xlabel('Variant Pool Size');
ylabel('Number of crrectly Identified TCRs');
title('TCRs identified by HITS ONLY (10000 droplets)');

ax_03 = subplot(1,3,3,'nextplot','add');
errorbar(number_TCR_space.', plotting_arr(:,5), plotting_arr(:,6),'linewidth',1.5);
xlabel('Variant Pool Size');
ylabel('Number of crrectly Identified TCRs');
title('TCRs identified by MISSES ONLY (10000 droplets)');


%
%%%
%%%%%
%%%
%