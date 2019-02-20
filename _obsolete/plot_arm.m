function plot_arm(arm, id, fig_num)

    if id ~= -1
        ang_hist = arm.ang_hist(:, id);
        time_hist = arm.time_hist(:, id);
        cmd_hist = arm.cmd_hist(:, id);
    else
        ang_hist = arm.ang_hist;
        time_hist = arm.time_hist;
        cmd_hist = arm.cmd_hist;
    end
    
    figure(fig_num)
    
    subplot(2,1,1)
    plot(time_hist, ang_hist);
    
    subplot(2,1,2)
    plot(time_hist, cmd_hist);

end