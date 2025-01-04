clear
clc

d=14; k=4;
dataset=readmatrix("dataset_binary.xlsx");
n=size(dataset,1);
p_distri=load("p_distribution_1.mat");
p_distri=struct2cell(p_distri);
p_distri=p_distri{1};
N=struct2cell(load("results\network.mat"));
N=N{1};
Pi_set=load("results\P_set.mat");
Pi_set=struct2cell(Pi_set);
Pi_set=Pi_set{1};
Pi_set{1}={0};

% 遍历属性，将属性索引存储到字典中。
lookup_Atr(1)=1;
for i = 2:d
    lookup_Atr(N{i}{1}+1) = i; % 把属性对应值处理顺序？
end

% 创建一个全零矩阵，用于存储新的数据集。
dataset_new1 = zeros(n, d);

% 遍历数据集中的每一行。
for count = 1:n
    % 创建一个空 cell 数组，用于存储当前行的属性值。
    temp = {};
    % 初始化条件分布的索引。
    num_pi = 0;
    % 遍历每个属性。
    for i = 1:d
        % 判断是否是第一个属性。
        if i == 1
            % 生成一个随机数。
            r = rand();
            % 初始化概率总和和随机点。
            sum_p = 0;
            random_tip = 0;
            % 遍历第一个属性的条件分布。
            while true
                sum_p = sum_p + p_distri{i}(random_tip+1);
                %这里为sum_p大于r是因为用的laplace机制，只有lambda>=S(f)/epsilon才满足epsilon-DP
                if sum_p >= r 
                    break;
                end
                random_tip = random_tip + 1;
            end

            % 如果随机点在条件分布的范围内，添加到列表中，并将值存储到数据集中。
            if random_tip < length(p_distri{i})
                temp{i} = random_tip;
                dataset_new1(count, N{i}(1)+1) = random_tip; % 赋予dataset(数据条序号，子节点属性序号)新的数据
            else
                temp{i} = random_tip - 1;
                dataset_new1(count, N{i}(1)+1) = random_tip - 1;
            end

            % 遍历分布集合，找到对应的索引。
            for index = 1:length(Pi_set{i+1})
                if isequal(Pi_set{i+1}(index), cell2mat(temp)) % temp记录该数据该属性的取值，通过这个对应下一个属性的可能取值
                    num_pi = index;
                    break;
                end
            end

        % 如果不是第一个属性。
        else
            % 生成一个随机数。
            r = rand();
            % 初始化概率总和和随机点。
            sum_p = 0;
            random_tip = 0;
            tip = 1;
            total_p = 0;  % 对条件分布做归一化处理
            [x, y] = size(p_distri{i});
            % 计算总概率。
            while tip <= x
                total_p = total_p + p_distri{i}(tip, num_pi);
                tip = tip + 1;
            end
            % 遍历第 i 个属性的条件分布。
            while random_tip < x
                temp1 = p_distri{i}(random_tip+1, num_pi) / total_p;
                sum_p = sum_p + temp1;
                if sum_p >= r
                    break;
                end
                random_tip = random_tip + 1;
            end
            % 如果随机点在条件分布的范围内，添加到列表中，并将值存储到数据集中。
            if random_tip < x
                temp{i} = random_tip;
                dataset_new1(count, N{i}{1}+1) = random_tip;
            else
                temp{i} = random_tip - 1;
                dataset_new1(count, N{i}{1}+1) = random_tip - 1;
            end
            % 如果 i 小于 k。
            if i < k
                % 遍历分布集合，找到对应的索引。
                for index = 1:length(Pi_set{i + 1})
                    if isequal(Pi_set{i + 1}(index), temp)
                        num_pi = index;
                        break;
                    end
                end
            % 如果 k <= i < d - 1。
            elseif i >= k && i < d
                % 创建一个空 cell 数组，用于存储对应的索引。
                temp2 = cell(k, 1);
                % 遍历前 k 个属性。
                for j = 1:k
                    temp2{j} = temp{lookup_Atr(N{i + 1}{2}(j)+1)};
                end
                % 遍历分布集合，找到对应的索引。
                for index = 1:length(Pi_set{i + 1})
                    if isequal(temp2, Pi_set{i + 1}(index))
                        num_pi = index;
                        break;
                    end
                end

            end

        end

    end

end

% 将数据集写入文件。
% dlmwrite('dataset_new1.txt', dataset_new1, 'delimiter', ',', 'precision', '%d');
% xlswrite('dataset_new1.xlsx',dataset_new1)

%dlmwrite('dataset_new1_2.txt', dataset_new1, 'delimiter', ',', 'precision', '%d');
%xlswrite('dataset_new1.xlsx',dataset_new1)
