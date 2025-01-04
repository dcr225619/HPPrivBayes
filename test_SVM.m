%需要用到statistics and machine learning包
%license('test', 'Statistics_Toolbox') % 查询Statistics_Toolbox是否已激活
%license('checkout', 'Statistics_Toolbox') % 激活Statistics_Toolbox

clear
clc

%SVM
T = xlsread('dataset_binary.xlsx');  % 读取数据
x = T;  % 特征数据
x(:,4)=[];
y = T(:,4);  % 以education为类属性标签

for i=1:length(y)
    if y(i)==0 || y(i)==10 || y(i)==13
        y(i)=0;
    else
        y(i)=1;
    end
end

%数据划分
%for i=1:10
    cv = cvpartition(height(T), 'HoldOut', 0.2);  % 80% 训练集，20% 测试集
    trainIdx = training(cv);
    testIdx = test(cv);
    train_data = x(trainIdx, :);
    train_label = y(trainIdx, :);
    test_data = x(testIdx, :);
    test_label = y(testIdx, :);
    
    %模型训练
    SVMModel = fitcsvm(train_data, train_label, 'KernelFunction', 'rbf', 'BoxConstraint', 2, 'KernelScale', 10);
    
    %测试准确率
    [predicted_labels] = predict(SVMModel, test_data);
    accuracy = sum(predicted_labels == test_label) / length(test_label);
    %accuracy(i) = sum(predicted_labels == test_label) / length(test_label);
%end

fprintf('测试准确率: %f\n',accuracy);

% temp=sum(accuracy)/10;
% fprintf('测试准确率: %f\n',temp);

% load splat
% sound(y,Fs)