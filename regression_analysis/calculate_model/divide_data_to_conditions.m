function [data] = divide_data_to_conditions(settings, data)



for cond_itr = 1:length(settings.single_cond_names)
    filter_data_header = ['.*_' settings.single_cond_names{cond_itr} '.*'];
    filter_var_inds = find(~cellfun(@isempty,regexp(data.data_headers, filter_data_header)));
    data.single_cond_data{cond_itr} = data.orig_data(:,filter_var_inds);
    data.single_cond_headers{cond_itr} = data.data_headers(filter_var_inds);
end


filter_data_header = ['.*_' settings.combined_cond_name '.*'];
filter_var_inds = find(~cellfun(@isempty,regexp(data.data_headers, filter_data_header)));
data.combined_cond_data = data.orig_data(:,filter_var_inds);
data.combined_cond_headers = data.data_headers(filter_var_inds);


