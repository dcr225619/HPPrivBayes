function get_pi_set(k, pi_init, pi_set, pi_temp)
    if k == numel(pi_init)
        temp = pi_temp;
        pi_set{end+1} = temp;
    else
        for i = 1:numel(pi_init{k})
            pi_temp{k} = pi_init{k}(i);
            get_pi_set(k + 1, pi_init, pi_set, pi_temp);
        end
    end
end