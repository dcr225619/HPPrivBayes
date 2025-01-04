function [p_distri, n, Pi_set, N, A_num_set] = build_noise_distr(k, d, epsilon)
    % 使用build_N.generate_N函数生成数据集、一些分布、集合和一些数字，参数分别为d、7和0.24
    [dataset, Ax_Pi_distrs, Pi_distrs, Pi_set, N, A_num_set] = build_N.generate_N(d, 7, 0.24);
    
    Ax_Pi_distribution
    Pi_distribution
  
    % 提取数据集中的行数
    n = size(dataset, 1);
    
    % 计算lambda的值
    Lamba = 2 * d / (n * epsilon);
    
    % 初始化一个空列表，用于存储生成的分布
    p_distri = {};
    
    % 遍历每个分布
    for index = 1:d
        
        % 初始化概率和
        sum_p = 0;
        
        % 将Ax_Pi_distrs转换为numpy数组
        Ax_Pi_distri = Ax_Pi_distrs{index};
        
        % 遍历Ax_Pi_distri的每一个元素
        for i = 1:size(Ax_Pi_distri, 1)
            for j = 1:size(Ax_Pi_distri, 2)
                
                % 添加拉普拉斯噪音到每个元素
                temp = Ax_Pi_distri(i, j) + laprnd(0, Lamba);
                
                % 确保结果是非负的
                if temp < 0
                    Ax_Pi_distri(i, j) = 0;
                else
                    Ax_Pi_distri(i, j) = temp;
                end
                
                % 累加概率和
                sum_p = sum_p + Ax_Pi_distri(i, j);
            end
        end
        
        % 归一化分布
        Ax_Pi_distri = Ax_Pi_distri / sum_p;
        
        % 将Ax_Pi_distri添加到p_distri列表中
        p_distri{end + 1} = Ax_Pi_distri;
    end
    
    % 将p_distri列表转换为numpy数组
    p_distri = cell2mat(p_distri);
    
    % 将Pi_set列表转换为numpy数组
    Pi_set = cell2mat(Pi_set);
    
    % 返回生成的分布、数据集大小、分布集合和一些数字
    return
end