clear
clc

dataset_old=xlsread("dataset_binary.xlsx");
dataset_new=xlsread("dataset_new5.xlsx");
A_num_set=[5, 7, 7, 16, 5, 7, 14, 6, 5, 2, 6, 2, 7, 2];

%求三元联合分布

d=size(dataset_new,2);

%所有a个属性的组合
C=nchoosek(1:d,3);%会生成一个总组合数*a大小的矩阵

[joint_distri_set_old,~] = joint_distribution_3(dataset_old, A_num_set);
save("joint_distribution3_dataset_binary.mat","joint_distri_set_old")

[joint_distri_set_new,~] = joint_distribution_3(dataset_new, A_num_set);
n = length(joint_distri_set_new);%3个属性的组合数
aver_var_dist = 0; 
for i = 1:n
    joint_distri_set_old{i} = abs(joint_distri_set_old{i} - joint_distri_set_new{i});
    aver_var_dist = aver_var_dist + max(joint_distri_set_old{i}(:));
end

aver_var_dist = aver_var_dist / n;
disp(aver_var_dist);
