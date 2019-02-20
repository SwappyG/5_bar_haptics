function boost = wire_drag_comp(angle, K_spring, deadzone_min, deadzone_max)

    if angle < deadzone_min
        boost = K_spring * (angle - deadzone_min);
    elseif angle > deadzone_max
        boost = K_spring * (angle - deadzone_max);
    else
        boost = 0;
    end

end