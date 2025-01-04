function [joint_distribution, C] = joint_distribution_3(dataset, A_num_set)
%用以计算非连续的三元联合分布

d=size(dataset,2);
joint_distribution={};

%所有a个属性的组合
C=nchoosek(1:d,3);%会生成一个总组合数*a大小的矩阵

for index=1:size(C,1)
    for item=1:size(dataset,1)
        x=C(index,1);
        y=C(index,2);
        z=C(index,3);
        temp=zeros(A_num_set(x),A_num_set(y),A_num_set(z));
        for i=1:A_num_set(x)
            for j=1:A_num_set(y)
                for k=1:A_num_set(z)
                    if i==dataset(item,x) && j==dataset(item,y) && k==dataset(item,z)
                        temp(i,j,k)=temp(i,j,k)+1;
                    end
                end
            end
        end
        joint_distribution{index}=temp;
        %matlab中三维矩阵的第三个坐标代指页数，即（1，1，3）表示第三页的第一行第一列的参数
    end
    joint_distribution{index}=joint_distribution{index}/size(dataset,1);
end

end