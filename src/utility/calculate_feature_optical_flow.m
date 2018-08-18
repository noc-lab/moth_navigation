function [visual_reception, optical_flow] = ...
  calculate_feature_optical_flow(state, q_state, tran_prob, forest, ...
  fog, m, angular_rg,ang_vr_seg, Gridinfo)
%%%calculate the feature of optical flow
%returns a vector of optical flow of different control actions

optical_flow = zeros(1, m);
[visual_reception,optical_flow_base] = ...
  calculate_feature_visual_reception(state, Gridinfo(3,4),angular_rg,ang_vr_seg,forest,fog);

for i = 1:m
    next = move_moth(state, q_state, tran_prob(:,:,i), Gridinfo);
    number_next = size(next, 1);
    
    for j = 1:number_next
        state_next = next(j, 4:6);
        p = next(j, 7);
        [~, optical_flow_temp] = ...
          calculate_feature_visual_reception(state_next, ...
          Gridinfo(3,4),angular_rg,ang_vr_seg,forest,fog);
        optical_flow(i) = optical_flow(i) + p*norm(optical_flow_temp - optical_flow_base, 2);
    end
end
end
