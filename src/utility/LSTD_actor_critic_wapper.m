function [alpha,actor] = LSTD_actor_critic_wapper(tran_prob,fog,m,vr0,...
  angular_rg,Gridinfo,energy,reward,forest,actor0,a0,std_feature,...
  mean_feature,feature_set,number_feature,kMax)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
  lambda = 0.9;
  actor = actor0;
  
  r = zeros(number_feature,1);
  z = zeros(number_feature,1);
  b = zeros(number_feature,1);
  A = eye(number_feature);
  alpha = a0;
  %kMax = 10;
  
  C = 10;
  c = 100;
  
  %initial state x0 and a0 using actor
  q_state = [randi(Gridinfo(1,1)),randi(Gridinfo(2,1)),randi(Gridinfo(3,1))];
  last_control = 1;
  [feature_gradient,control_probability] = ...
    calculate_feature_gradient_mex(q_state,actor,last_control,m,vr0,...
    angular_rg,Gridinfo,energy, tran_prob, forest,fog,std_feature,...
    mean_feature,feature_set,number_feature);
  
  control = find(cumsum(control_probability)>rand,1);
  feature = feature_gradient(:,control);

  for k=1:kMax
    
    q_state_new = move_moth_q_return_one(q_state, tran_prob(:,:,control), Gridinfo);
    
    last_control = control;
    gK = reward(q_state_new(1),q_state_new(2));
    
    [feature_gradient_new, control_probability_new] = ...
      calculate_feature_gradient_mex(q_state_new,actor,last_control,m,vr0,...
      angular_rg,Gridinfo,energy, tran_prob, forest,fog,std_feature,...
      mean_feature,feature_set,number_feature);
    
    %Add some exploration in the initial loops
    control_new = find(cumsum(control_probability_new)>rand,1);
    feature_new = feature_gradient_new(:,control_new);
    
    gammaK = 1/(k+1);
    if (k == 0)||(k==1)
      betaK = 1;
    else
      betaK = c./(k.*log(k));
    end
    
    alpha_new = alpha + gammaK*(gK - alpha);
    z_new = lambda*z + feature;
    b_new = b + gammaK*((gK - alpha)*z - b);
    A_new = A + gammaK*(z*(feature_new' - feature') - A);
    if (k==0)
      A_new = eye(number_feature);
    end
    r_new = -A\b;
    
    if sum(norm(r,2)<C)
      GammaK = 1;
    else
      GammaK = C./norm(r,2);
    end
    actorDiff = betaK*(GammaK*r*feature_new')*feature_new;
    actor = actor - actorDiff;
    
    q_state = q_state_new;
    control = control_new;
    feature = feature_new;
    z = z_new;
    b = b_new;
    A = A_new;
    alpha = alpha_new;
    r = r_new;
  end
end

