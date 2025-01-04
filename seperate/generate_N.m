function [dataset, Ax_Pi_distrs, Pi_distrs, Pi_set, N, A_num_set] = generate_N(d, theta, epsilon)
    %dataset = readD2array();
    %d=14; theta=7; epsilon=0.12;
    dataset=load('dataset_binary.mat');
    dataset=dataset.dataset;
    n_dataset = size(dataset, 1);
    k = get_k(d, theta, epsilon, n_dataset);
    disp(k);
    A_set = 1:d;
    %开始改进入排序
    A1 = 1;
    A_set(A_set == A1) = [];
    V = A1;
    N = {A1};
    filename = 'adult_property.data';
    fileID = fopen(filename, 'r');
    dataset_Atr = {};
    line = fgetl(fileID);
    while ischar(line)
        line = strtrim(line);
        line_list = strsplit(line, ',');
        dataset_Atr{end+1} = line_list;
        line = fgetl(fileID);
    end
    fclose(fileID);
    dataset_Atr{end+1} = {'<=50K', '>50K'};
    A_num_set = zeros(1, d);
    lookup_Acontinues = [5, 0, 7, 0, 5, 0, 0, 0, 0, 0, 6, 2, 7, 0];
    for i = 1:length(dataset_Atr)
        if ismember(i, [1, 3, 11, 12, 13, 5])
            A_num_set(i) = lookup_Acontinues(i);
        else
            A_num_set(i) = numel(dataset_Atr{i});
        end
    end
    %A_num_set=[5,7,7,16,5,7,14,6,5,2,6,2,7];

    joint_A1 = zeros(1, A_num_set(A1));
    for i = 1:n_dataset
        joint_A1(dataset(i, A1) + 1) = joint_A1(dataset(i, A1) + 1) + 1; 
        % 加1避免出现0为索引
    end
    joint_A1 = joint_A1 / n_dataset;
    Ax_Pi_distrs = {joint_A1};
    
    
    for i = 1:length(A_set)
        AP_list = {};
        mute_info_list = [];
        joint_distr_list = {};
        pi_distr_list = {};
        pi_set_list = {};
        
        for Ai = A_set(i)
            if numel(V) <= k
                AP_list{end+1} = [Ai, V];
            else
                comb = nchoosek(V, k); % 组合数量
                for j = 1:size(comb, 1)
                    AP_list{end+1} = [Ai, comb(j, :)];
                end
            end
        end
        
        for AP_idx = 1:length(AP_list)
            AP = AP_list{AP_idx};
            pi_set = {};
            pi = AP(2:end);
            pi_init = cell(1, length(pi));
            pi_temp = zeros(1, length(pi));
            for j = 1:length(pi)
                pi_init{j} = 0:A_num_set(pi(j)) - 1;
            end
            get_pi_set(1, pi_init, pi_set, pi_temp);
            pi_set_list{end+1} = pi_set;
            Ax = 0:A_num_set(AP(1)) - 1;
            [mute_info, joint_distributes, pi_distributes] = mutual_information(Ax, dataset, pi_set, AP);
            mute_info_list(end+1) = mute_info;
            joint_distr_list{end+1} = joint_distributes;
            pi_distr_list{end+1} = pi_distributes;
        end
        
        index_mute_info_list = exponent_mechanism(mute_info_list, n_dataset, epsilon, d);
        I_max_pair = AP_list{index_mute_info_list};
        Ax_Pi_distrs{end+1} = joint_distr_list{index_mute_info_list};
        Pi_distrs{end+1} = pi_distr_list{index_mute_info_list};
        Pi_set{end+1} = pi_set_list{index_mute_info_list};
        N{end+1} = I_max_pair;
        V(end+1) = I_max_pair(1);
        A_set(A_set == I_max_pair(1)) = [];
    end
end
