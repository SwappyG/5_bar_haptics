function C = lag_comp(alpha, tau)

    s = tf('s')
    if alpha < 1
        error('alpha must be > 1 for lag comp')
    end
    C = alpha * (tau*s + 1)/(alpha*tau*s + 1);
    
end