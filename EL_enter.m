clear
clc

d=14;
dataset=load("dataset_binary.mat");
dataset=dataset.dataset;

% Calculate mutual information matrix
MI_matrix = zeros(size(dataset, 2));
for i = 1:size(dataset, 2)
    for j = i:size(dataset, 2)
        if i ~= j
            MI_matrix(i, j) = mutual_info(dataset(:, i), dataset(:, j));
        end
    end
end

MI_matrix(isnan(MI_matrix)) = 0;

% Compute average mutual information for each attribute
AMI_values = zeros(1, size(dataset, 2));
MI_matrix=MI_matrix+MI_matrix';
for i = 1:size(dataset, 2)
    AMI_values(i) = sum(MI_matrix(i, :))/(d-1);
end

% Sort attributes based on average mutual information
[~, A_set] = sort(AMI_values, 'descend');



