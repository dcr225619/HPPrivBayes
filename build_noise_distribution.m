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
epsilon=0.3;
epsilon2=2/3*epsilon;
epsilon3=1/3*epsilon;

% 提取数据集中的行数
n = size(dataset, 1);

% 计算lambda的值
Lambda2 = 2*d/(n*epsilon2);

%准备Laplace随机数
mu=0;%均值
sigma=1;


%标准差，方差的开平方

% 初始化一个空列表，用于存储生成的分布
p_distri = {};

% 敏感属性
for index = 1:d %属性编号
    if index==2||index==4||index==5||index==8||index==10||index==13
        lambda=4*(d-k)/(n*epsilon2);
    else
        lambda=4*(d-k)/(n*epsilon3);
    end
    % 初始化概率和
    sum_p = 0;
   
    % 将Ax_Pi_distrs转换为numpy数组
    Ax_Pi_distri = Ax_Pi_distribution{index}; 
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
    
    % 归一化分布
    Ax_Pi_distri = Ax_Pi_distri / sum_p;
    
    % 将Ax_Pi_distri添加到p_distri列表中
    p_distri{index} = Ax_Pi_distri;
end

save("p_distribution","p_distri")
