clear
clc

A_num_set=[5, 7, 7, 16, 5, 7, 14, 6, 5, 2, 6, 2, 7, 2];
Ax_Pi_distribution=load("results\Ax_Pi_distribution.mat");
Ax_Pi_distribution=struct2cell(Ax_Pi_distribution);
Ax_Pi_distribution=Ax_Pi_distribution{1};
Pi_distribution=load("results\Pi_distribution.mat");
Pi_distribution=struct2cell(Pi_distribution);
Pi_distribution=Pi_distribution{1};
N=struct2cell(load("results\network.mat"));
N=N{1};
Pi_set=load("results\P_set.mat");
Pi_set=struct2cell(Pi_set);
Pi_set=Pi_set{1};

dataset=readmatrix("dataset_binary.xlsx");
d=14; k=4; l=7;% 非敏感数据个数

R=[1/6,1/5,1/4,1/3,1/2];
Class=[4,10];

avd3_sensitive={};
avd3_nonsensitive={};
avd2_sensitive={};
avd2_nonsensitive={};
SVM={};

for rate=1:5 %epsilon2:epsilon3 = 1:5, 1:4, 1:3, 1:2, 1:1
    for ep=1:5 %epsilon取值0.2, 0.4, 0.6, 0.8, 1
    %     str2='dataset_new_';
    %     str1='build_noise_distr_';
    %     str3='p_distribution_';
    %     filename1=strcat(str1, num2str(ep));
    %     filename2=strcat(str2, num2str(ep));
    %     filename3=strcat(str3, num2str(ep));
        
        %build noise distribution
        %epsilon
        %epsilon1=0.12;
        epsilon=0.08+0.2*(ep-1);
        
        r=R(rate);
        epsilon2=r*epsilon;
        epsilon3=(1-r)*epsilon;
        
        % 提取数据集中的行数
        n = size(dataset, 1);
        
        %准备Laplace随机数
        mu=0;%均值
        sigma=1;
        
        map=[1,14,5,2,13,6,8,3,12,4,10,9,11,7];
        %map(index)=cell_num,index-1为属性编号
        
        %不同值的占比
        weights=load("weight of values.mat");
        weights=struct2cell(weights);
        weights=weights{1};
        
        % 初始化一个空列表，用于存储生成的分布
        p_distri = {};
    
        % 敏感属性
        for index = 1:d %属性编号+1
            if index==2||index==4||index==5||index==8||index==10||index==13
                lambda=2*(d-k-l)/(n*epsilon2);
                % 初始化概率和
                sum_p = 0;
                % 找属性i在Ax_Pi_distribution里所在cell的编号
                Cell_num=map(index);
                % 将Ax_Pi_distrs转换为numpy数组
                Ax_Pi_distri = Ax_Pi_distribution{Cell_num}; 
                % 遍历Ax_Pi_distri的每一个元素
                for i = 1:size(Ax_Pi_distri, 1)
                    a=rand(1);
                    laplace = mu-lambda*sign(a-0.5)*log(1-2*abs(a-0.5));
                    for j = 1:size(Ax_Pi_distri, 2)  
                        % 添加Laplace噪音
                        temp = Ax_Pi_distri(i, j) + laplace;
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
            else
                % 初始化概率和
                sum_p = 0;
                % 找属性i在Ax_Pi_distribution里所在cell的编号
                Cell_num=map(index);
                Ax_Pi_distri = Ax_Pi_distribution{Cell_num}; 
                % 遍历Ax_Pi_distri的每一个元素
                for i = 1:size(Ax_Pi_distri, 1) % 遍历每种index属性可能的取值
                    w=weights{index}(i); % 遍历每种父节点组合
                    lambda=2*l/(n*w*epsilon3);
                    b=rand();
                    laplace=mu-lambda*sign(b-0.5)*log(1-2*abs(b-0.5));
                    for j = 1:size(Ax_Pi_distri, 2)  
                        % 添加Laplace噪音
                        a=rand(1);
                        laplace = mu-lambda*sign(a-0.5)*log(1-2*abs(a-0.5));
                        temp = Ax_Pi_distri(i, j) + laplace;
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
            end
            % 归一化分布
            Ax_Pi_distri = Ax_Pi_distri / sum_p;
            
            % 将Ax_Pi_distri添加到p_distri列表中
            p_distri{Cell_num} = Ax_Pi_distri;
        end
    
        %synthetic data
        
        % 遍历属性，将属性索引存储到字典中。
        lookup_Atr(1)=1;
        for i = 2:d
            lookup_Atr(N{i}{1}+1) = i; % 把属性对应值处理顺序？
        end
        
        % 创建一个全零矩阵，用于存储新的数据集。
        dataset_new = zeros(n, d);
        
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
                        dataset_new(count, N{i}(1)+1) = random_tip; % 赋予dataset(数据条序号，子节点属性序号)新的数据
                    else
                        temp{i} = random_tip - 1;
                        dataset_new(count, N{i}(1)+1) = random_tip - 1;
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
                        dataset_new(count, N{i}{1}+1) = random_tip;
                    else
                        temp{i} = random_tip - 1;
                        dataset_new(count, N{i}{1}+1) = random_tip - 1;
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
        

        
        %a-way  a=3
        temp1=[];
        temp2=[];

        dataset_old=dataset;
        dataset_old1=dataset_old(:,[2,4,5,7,8,10,13]); % sensitive
        dataset_old2=dataset_old(:,[1,3,6,9,11,12,14]); % non-sensitive
        dataset_new1=dataset_new(:,[2,4,5,7,8,10,13]);
        dataset_new2=dataset_new(:,[1,3,6,9,11,12,14]);

        
        [joint_distri_set_old1,~] = joint_distribution_3(dataset_old1, A_num_set);
        [joint_distri_set_old2,~] = joint_distribution_3(dataset_old2, A_num_set);
        %save("joint_distribution3_dataset_binary.mat","joint_distri_set_old")
        
        [joint_distri_set_new1,~] = joint_distribution_3(dataset_new1, A_num_set);
        [joint_distri_set_new2,~] = joint_distribution_3(dataset_new2, A_num_set);

        n = length(joint_distri_set_new1);%3个属性的组合数
        m = length(joint_distri_set_new2);

        for j=1:20
        aver_var_dist1 = 0; 
        for i = 1:n
            joint_distri_set_old1{i} = abs(joint_distri_set_old1{i} - joint_distri_set_new1{i});
            aver_var_dist1 = aver_var_dist1 + max(joint_distri_set_old1{i}(:));
        end
        aver_var_dist1 = aver_var_dist1 / n;
        temp1(j)=aver_var_dist1;
        
        aver_var_dist2 = 0; 
        for i = 1:m
            joint_distri_set_old2{i} = abs(joint_distri_set_old2{i} - joint_distri_set_new2{i});
            aver_var_dist2 = aver_var_dist2 + max(joint_distri_set_old2{i}(:));
        end
        
        aver_var_dist2 = aver_var_dist2 / m;
        temp2(j)=aver_var_dist2;
        
        end

        aver_var_dist_av1=sum(temp1)/20;
        aver_var_dist_av2=sum(temp2)/20;

        avd3_sensitive{rate}(ep)=aver_var_dist_av1;
        avd3_nonsensitive{rate}(ep)=aver_var_dist_av2;


        %a-way  a=2
        
        temp1=[];
        temp2=[];
 
        [joint_distri_set_old1,~] = joint_distribution_2(dataset_old1, A_num_set);
        [joint_distri_set_old2,~] = joint_distribution_2(dataset_old2, A_num_set);
        %save("joint_distribution3_dataset_binary.mat","joint_distri_set_old")
        
        [joint_distri_set_new1,~] = joint_distribution_2(dataset_new1, A_num_set);
        [joint_distri_set_new2,~] = joint_distribution_2(dataset_new2, A_num_set);

        n = length(joint_distri_set_new1);%3个属性的组合数
        m = length(joint_distri_set_new2);
        
        for j=1:20
        aver_var_dist1 = 0; 
        for i = 1:n
            joint_distri_set_old1{i} = abs(joint_distri_set_old1{i} - joint_distri_set_new1{i});
            aver_var_dist1 = aver_var_dist1 + max(joint_distri_set_old1{i}(:));
        end
        
        aver_var_dist1 = aver_var_dist1 / n;
        temp1(j)=aver_var_dist1;

        aver_var_dist2 = 0; 
        for i = 1:m
            joint_distri_set_old2{i} = abs(joint_distri_set_old2{i} - joint_distri_set_new2{i});
            aver_var_dist2 = aver_var_dist2 + max(joint_distri_set_old2{i}(:));
        end
        
        aver_var_dist2 = aver_var_dist2 / m;
        temp2(j)=aver_var_dist2;

        end
        %aver_var_dist_av=sum(temp)/10;
        aver_var_dist_av1=sum(temp1)/20;
        aver_var_dist_av2=sum(temp2)/20;

        avd2_sensitive{rate}(ep)=aver_var_dist_av1;
        avd2_nonsensitive{rate}(ep)=aver_var_dist_av2;

    end
end

save('avd2_sensitive2.mat','avd2_sensitive')
save('avd2_nonsensitive2.mat','avd2_nonsensitive')
save('avd3_sensitive2.mat','avd3_sensitive')
save('avd3_nonsensitive2.mat','avd3_nonsensitive')