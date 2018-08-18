function [feature_gradient, action_probability, state_feature_selected, feature_hessian] =  ...
    calculate_feature_gradient_hessian(q_state,actor,last_control,m,vr0,...
    angular_rg,Gridinfo,energy, tran_prob, forest,fog,std_feature,...
    mean_feature,feature_set,number_feature)
%%%calculate the feature gradient to approximate the reward
%   returns both the feature gradient and the action probability
%first calculate the state-action features

state_feature =calculate_feature_state_q(q_state, last_control, ...
  tran_prob,forest,fog,m,vr0,angular_rg,Gridinfo,energy);

state_feature = (state_feature - repmat(mean_feature', 1, m))./repmat(std_feature', 1, m);
state_feature_selected = state_feature(feature_set, :);

exponential = actor'*state_feature_selected;
eQ = exp(exponential)';
sumeQ = sum(eQ);
action_probability = eQ/sumeQ;

Astate = (state_feature_selected.*repmat(action_probability', number_feature, 1));

shift = sum(Astate, 2);
feature_gradient = state_feature_selected - repmat(shift, 1, m);

feature_hessian = zeros(number_feature);

for i = 1:m
  for j = 1:m
    feature_hessian = feature_hessian - ...
      Astate(:,i)*Astate(:,j)';
  end
end

feature_hessian = feature_hessian + Astate*state_feature_selected';
feature_hessian = 1/2*(feature_hessian+feature_hessian');
end

