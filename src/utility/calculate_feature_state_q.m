function state_feature =calculate_feature_state_q(q_state, last_control, ...
  tran_prob,forest,fog,m,vr0,angular_rg,Gridinfo,energy)
    %%%calculate state feature vectors in realtime for further use in
    %%%actor-critic learning
    %returns a vector of number_feature*number_control
    [fea1, fea5] = calculate_feature_optical_flow_q(q_state, tran_prob, forest, ...
  fog, m, angular_rg,vr0, Gridinfo);
    
    fea2 = (fea1 > 0);
    fea3 = (fea1 > .10);
    fea4 = (fea1 > .50);
    % History feature
    fea6 = abs((1:m) - last_control);
    %Energy features can be calculated only once not every time
    fea7 = energy(1, :);
    fea8 = energy(3, :);
    fea9 = energy(4, :);    
    state_feature = [fea1;fea2;fea3;fea4;fea5;fea6;fea7;fea8;fea9];
    
end
