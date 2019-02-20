function clipped_input = clip(raw_input, low, high)

    % Create a container for clipped raw input
    clipped_input = raw_input;

    % Iterate through and clip each value
    for index = 1:length(raw_input)
        clipped_input(index) = max( low , min( high, raw_input(index) ) );
    end

end