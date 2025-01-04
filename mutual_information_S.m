clear;
clc;

k=4;
d=14;
Ax=7;
V = Ax;
AP_list={};
A_num_set = [5, 7, 7, 16, 5, 7, 14, 6, 5, 2, 6, 2, 7, 2];

dataset = readmatrix("dataset_binary.xlsx");

% 生成所有可能的父节点属性组合
if length(V) <= k
    for j = 1:d
        AP_list{end + 1} = [j, V];
    end
else
    combos = combnk(V, k);
    for j = 1:d
        for l = 1:size(combos, 1)
            AP_list{end + 1} = [j, combos(l, :)];
        end
    end
end

%Pi-distribution
Pi_distribution=zeros(d,max(A_num_set));
for i=linspace(1,d,d)
    Ax_num=A_num_set(i);
    for j=1:size(dataset,1)
        for k=0:Ax_num-1
            if dataset(j,i)==k
                Pi_distribution(i,k+1)=Pi_distribution(i,k+1)+1;
                break;
            end
        end
    end
end

Pi_distribution=Pi_distribution/size(dataset,1);
%sum(Pi_distribution,2)
Ax_distribution=Pi_distribution(Ax,1:d);

%Joint distribution
Joint_distribution={};
for P=[1,2,3,4,5,6,8,9,10,11,12,13,14]
    Joint_distribution{P}=zeros(A_num_set(Ax),A_num_set(P));
    for item=1:size(dataset,1)
        Joint_distribution{P}(dataset(item,Ax)+1,dataset(item,P)+1)=Joint_distribution{P}(dataset(item,Ax)+1,dataset(item,P)+1)+1;
    end
    Joint_distribution{P}=Joint_distribution{P}/size(dataset,1);
end

%Mutual information
Mutual_information=zeros(1,d);
for P=[1,2,3,4,5,6,8,9,10,11,12,13,14]
    for i=1:A_num_set(P)
        temp=0;
        for j=1:A_num_set(Ax)
            if Joint_distribution{P}(j,i)~=0 && Pi_distribution(P,i)~=0 && Ax_distribution(j)~=0
            temp=temp+Joint_distribution{P}(j,i)*log2(Joint_distribution{P}(j,i)/(Pi_distribution(P,i)*Ax_distribution(j)));
            end
        end
        Mutual_information(P)=Mutual_information(P)+temp;
    end
end
Mutual_information(Ax)=1;
