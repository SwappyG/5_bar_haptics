function lines = create_animated_lines(fig_num, pts)

    figure(fig_num)
    
    % for both arms
    for arm_num = 1:2
        
        % for each joint in arm
        for joint = 1:3
            
            % Select the subplot
            subplot(5,1,joint)

            % Create animatedline object handle for (arm,joint) pos
            lines(arm_num,joint, 1) = animatedline(gca, 'MaximumNumPoints',pts);
            
            % Make arm 1 have solid lines, arm 2 have dashed lines
            if arm_num == 1
                lines(arm_num,joint, 1).LineStyle = '-';
                lines(arm_num,joint, 1).LineWidth = 1.5;
            else
                lines(arm_num,joint, 1).LineStyle = '--';
                lines(arm_num,joint, 1).LineWidth = 2;
            end
            
            % Make joint 1 red, joint 2 blue and joint 3 green
            if joint == 1
                lines(arm_num,joint, 1).Color = [1 0 0];
            elseif joint == 2
                lines(arm_num,joint, 1).Color = [0 0 1];
            elseif joint == 3
                lines(arm_num,joint, 1).Color = [0 .75 0];
            end
            
            % Select the subplot
            subplot(5,1,4)

            % Create animatedline object handle for (arm,joint) cmd
            lines(arm_num,joint, 2) = animatedline(gca, 'MaximumNumPoints',pts);
            
            % Make arm 1 have solid lines, arm 2 have dashed lines
            if arm_num == 1
                lines(arm_num,joint, 2).LineStyle = '-';
                lines(arm_num,joint, 2).LineWidth = 1.5;
            else
                lines(arm_num,joint, 2).LineStyle = '--';
                lines(arm_num,joint, 2).LineWidth = 2;
            end
            
            % Make joint 1 red, joint 2 blue and joint 3 green
            if joint == 1
                lines(arm_num,joint, 2).Color = [1 0 0];
            elseif joint == 2
                lines(arm_num,joint, 2).Color = [0 0 1];
            elseif joint == 3
                lines(arm_num,joint, 2).Color = [0 .75 0];
            end
        end
        
    end
    
end