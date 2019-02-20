function plot_step(arm, low, high, id_to_test, fig_num)

    ang_hist = arm.ang_hist(:, id_to_test);
    time_hist = arm.time_hist(:, id_to_test);
    cmd_hist = arm.cmd_hist(:, id_to_test);
    
    total_time = length(time_hist);
       
    figure(fig_num)
    hold on
    
    plot(time_hist, ang_hist);
%     plot(time_hist, cmd_hist);
    plot(time_hist, high * ones(1,total_time));
    plot(time_hist, low * ones(1,total_time));
    
    hold off

end