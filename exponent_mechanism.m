function num_list = exponent_mechanism(mute_info_list, n_dataset, epsilon, d)
    sensitivity = 2 / n_dataset * log2((n_dataset + 1) / 2) + (n_dataset - 1) / n_dataset * log2((n_dataset + 1) / (n_dataset - 1));
    epsilon_single = epsilon / (d - 1);
    sum_exp_mecha = 0;
    exponent_mechanism_list = zeros(1, numel(mute_info_list));
    for i = 1:numel(mute_info_list)
        exponent_mechanism_list(i) = exp(0.5 * mute_info_list(i) * epsilon_single / sensitivity);
        sum_exp_mecha = sum_exp_mecha + exponent_mechanism_list(i);
    end
    exponent_mechanism_list = exponent_mechanism_list / sum_exp_mecha;
    r = rand();
    sum_exp_mecha = 0;
    num_list = 1;
    while true
        sum_exp_mecha = sum_exp_mecha + exponent_mechanism_list(num_list);
        if sum_exp_mecha > r
            break;
        end
        num_list = num_list + 1;
    end
end