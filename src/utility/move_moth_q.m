function next_states = move_moth_q(q_state, P, Gridinfo)

n_x = Gridinfo(1,1);
n_y = Gridinfo(2,1);
n_theta = Gridinfo(3,1);


next_index = find(P(q_state(3), :));
next_p = P(q_state(3), next_index);
number_next = length(next_index);
next_states = zeros(number_next, 4);

for i=1:number_next
    index = next_index(i);
    p = next_p(i);
    direction = floor((index-1)/(n_theta))+1;%[E N W S] = [1 2 3 4]
    q_state_next = q_state;%should define a new tempory variable to store
    q_state_next(3) = index - (direction - 1)*n_theta;
    %Update accodrding to quantized values, then transforming to continous
    %ones, since the probability is with respect to quantized values
    switch direction
        case 1
            q_state_next(1) = mod(q_state(1)+1, n_x);
            if q_state_next(1)==0
                q_state_next(1) = n_x;
            end
        case 2
            q_state_next(2) = mod(q_state(2)+1,n_y);
            if q_state_next(2) == 0
                q_state_next(2) = n_y;
            end
        case 3
            q_state_next(1) = mod(q_state_next(1) - 1, n_x);
            if q_state_next(1) == 0
                q_state_next(1) = n_x;
            end
        case 4
            q_state_next(2) = mod(q_state_next(2) - 1, n_y);
            if q_state_next(2) == 0
                q_state_next(2) = n_y;
            end
        otherwise
            error('Unknown next state...');
    end
    
    next_states(i, :) = [q_state_next(1), q_state_next(2), q_state_next(3), p];
end

end

