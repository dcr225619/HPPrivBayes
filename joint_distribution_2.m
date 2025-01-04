function [joint_distribution, C] = joint_distribution_2(dataset, A_num_set)
%用以计算非连续的二元联合分布

d=size(dataset,2);
joint_distribution={};

%所有2个属性的组合
C=nchoosek(1:d,2);%会生成一个总组合数*2大小的矩阵

for index=1:size(C,1)
    for item=1:size(dataset,1)
        x=C(index,1);
        y=C(index,2);
        temp=zeros(A_num_set(x),A_num_set(y));
        for i=1:A_num_set(x)
            for j=1:A_num_set(y)
                if i==dataset(item,x) && j==dataset(item,y)
                    temp(i,j)=temp(i,j)+1;
                end
            end
        end
        joint_distribution{index}=temp;
    end
    joint_distribution{index}=joint_distribution{index}/size(dataset,1);
end
end