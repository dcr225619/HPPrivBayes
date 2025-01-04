function MI = mutual_info(X, Y)
    pxy = hist3([X Y], 'Ctrs', {unique(X), unique(Y)}) / numel(X);
    px = histcounts(X, numel(unique(X))) / numel(X);
    py = histcounts(Y, numel(unique(Y))) / numel(Y);
    MI = sum(sum(pxy .* log2(pxy ./ (px' * py))));
end