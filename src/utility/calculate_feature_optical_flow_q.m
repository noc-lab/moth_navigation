function [visual_reception, optical_flow] = ...
  calculate_feature_optical_flow_q(q_state, tran_prob, forest, ...
  fog, m, angular_rg,ang_vr_seg, Gridinfo)
%%%calculate the feature of optical flow
%returns a vector of optical flow of different control actions

optical_flow = zeros(1, m);
[visual_reception,optical_flow_base] = ...
  calculate_feature_visual_reception_q(q_state,Gridinfo,angular_rg,ang_vr_seg,forest,fog);

for i = 1:m
    next = move_moth_q(q_state, tran_prob(:,:,i), Gridinfo);
    number_next = size(next, 1);
    
    for j = 1:number_next
        qstate_next = next(j, 1:3);
        p = next(j, 4);
        [~, optical_flow_temp] = ...
          calculate_feature_visual_reception_q(qstate_next,Gridinfo,angular_rg,ang_vr_seg,forest,fog);
        optical_flow(i) = optical_flow(i) + p*norm(optical_flow_temp - optical_flow_base, 2);
    end
end
end
