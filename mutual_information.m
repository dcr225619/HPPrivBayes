function [I_Ax_pi_total, joint_distributes, pi_distributes] = mutual_information(Ax, dataset, pi_set, AP)
    joint_set = {};
    lookup_Ax = containers.Map('KeyType', 'double', 'ValueType', 'double');
    lookup_pi = containers.Map('KeyType', 'char', 'ValueType', 'double');
    lookup_joint_x_pi = containers.Map('KeyType', 'char', 'ValueType', 'double');
    joint_distributes = zeros(length(Ax), length(pi_set));
    pi_distributes = zeros(1, length(pi_set));
    Ax_distributes = zeros(1, length(Ax));
    n_total = size(dataset, 1);
    for index_Ax = 1:length(Ax) % 遍历每个子节点
        lookup_Ax(Ax(index_Ax)) = index_Ax;
        for index_pi_set = 1:length(pi_set) % 遍历每个父节点集合
            if index_Ax == 1
                temp1 = '';
                for j = 1:length(pi_set{index_pi_set})
                    temp1 = [temp1, num2str(pi_set{index_pi_set}(j))];
                end
                lookup_pi(temp1) = index_pi_set;
            end
            temp_joint = [Ax(index_Ax), pi_set{index_pi_set}];
            temp2 = '';
            for item_temp_joint = temp_joint
                temp2 = [temp2, num2str(item_temp_joint)];
            end
            lookup_joint_x_pi(temp2) = index_pi_set;
            joint_set{end+1} = temp_joint;
        end
    end
    for i = 1:n_total
        Ax_distributes(lookup_Ax(dataset(i, AP(1)))) = Ax_distributes(lookup_Ax(dataset(i, AP(1)))) + 1;
        key_pi = '';
        key_Ax_pi = num2str(dataset(i, AP(1)));
        for j = AP(2:end)
            key_pi = [key_pi, num2str(dataset(i, j))];
            key_Ax_pi = [key_Ax_pi, num2str(dataset(i, j))];
        end
        pi_distributes(lookup_pi(key_pi)) = pi_distributes(lookup_pi(key_pi)) + 1;
        joint_distributes(lookup_Ax(dataset(i, AP(1))), lookup_joint_x_pi(key_Ax_pi)) = ...
            joint_distributes(lookup_Ax(dataset(i, AP(1))), lookup_joint_x_pi(key_Ax_pi)) + 1;
    end
    joint_distributes = joint_distributes / n_total;
    pi_distributes = pi_distributes / n_total;
    Ax_distributes = Ax_distributes / n_total;
    I_Ax_pi_mat = log2(joint_distributes .* (1 ./ (Ax_distributes' * pi_distributes)));
    I_Ax_pi_mat(isnan(I_Ax_pi_mat)) = 0;
    I_Ax_pi_mat(isinf(I_Ax_pi_mat)) = 0;
    I_Ax_pi_mat(isneginf(I_Ax_pi_mat)) = 0;
    I_Ax_pi_mat = I_Ax_pi_mat .* joint_distributes;
    I_Ax_pi_total = sum(I_Ax_pi_mat(:));
end