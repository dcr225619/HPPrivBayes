function k = get_k(d, theta, epislon, n)
    right = n * epislon / theta;
    k = 1;
    while k < d
        if (d - k) * 2^(k + 2) >= right
            break;
        else
            k = k + 1;
        end
    end
end