function next_p = move_moth_place(q_state, P, n_theta)
%%%move the moth according to the state-action transition probabilities
%returns a matrix, consisting of rows, each row as [q_x, q_y, q_theta, x, y, theta, probability]

next_pp = P(q_state(3), :);
next_p = zeros(4,1);
next_p(1) = sum(next_pp(1:n_theta));
next_p(2) = sum(next_pp(n_theta+1:2*n_theta));
next_p(3) = sum(next_pp(2*n_theta+1:3*n_theta));
next_p(4) = sum(next_pp(3*n_theta+1:4*n_theta));
end

