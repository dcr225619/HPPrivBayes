%这个是加了根据值分配第二部分预算的
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
d=14; k=4;

%epsilon
%epsilon1=0.12;
epsilon=0.48;
epsilon2=1/10*epsilon;
epsilon3=9/10*epsilon;

% 提取数据集中的行数
n = size(dataset, 1);

% 计算lambda的值
Lambda2 = 2*d/(n*epsilon2);

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
        lambda=4*(d-k)/(n*epsilon2);
        % 初始化概率和
        sum_p = 0;
        % 找属性i在Ax_Pi_distribution里所在cell的编号
        Cell_num=map(index);
        % 将Ax_Pi_distrs转换为numpy数组
        Ax_Pi_distri = Ax_Pi_distribution{Cell_num}; 
        % 遍历Ax_Pi_distri的每一个元素
        for i = 1:size(Ax_Pi_distri, 1)
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
    else
        % 初始化概率和
        sum_p = 0;
        % 找属性i在Ax_Pi_distribution里所在cell的编号
        Cell_num=map(index);
        Ax_Pi_distri = Ax_Pi_distribution{Cell_num}; 
        % 遍历Ax_Pi_distri的每一个元素
        for i = 1:size(Ax_Pi_distri, 1) % 遍历每种index属性可能的取值
            w=weights{index}(i); % 遍历每种父节点组合
            lambda=4*(d-k)/(n*w*epsilon3);
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

save("p_distribution_3_3","p_distri")