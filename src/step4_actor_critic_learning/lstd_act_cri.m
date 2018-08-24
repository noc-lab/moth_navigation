%LSTD
clear
clc
close all;

addpath('../utility/')

%global parameters setting
lambda = 0.9;
fog = 6.6;

%load the transition probability
load('../../data/processed/state_action_prob.mat', 'tran_prob', 'parameters');
m = parameters.m;
vr0 = parameters.vr0;
angular_rg = 2*parameters.vr_max;
Gridinfo = parameters.Gridinfo;
energy = parameters.energy;

%load the selected feature set
load('../../data/processed/log_reg.mat','weights','bestid','feature_set')
number_feature = length(feature_set);
actor0 = weights(:,bestid);

%load encironment rewards
reward = load('../../data/processed/reward.mat');
load ../../data/processed/forest.mat

feature_character = load('../../data/processed/qstate_action_features_std.mat', 'std_feature', 'mean_feature');
std_feature = feature_character.std_feature;
std_feature(1:4) = 1;
mean_feature = feature_character.mean_feature;
mean_feature(1:4) = -.5;


number_of_trial = 20;

All_Ave_Rew = zeros(number_of_trial,1);
All_iter_Time = zeros(number_of_trial,1);
All_Actor = zeros(number_feature,number_of_trial);

parfor testnum = 1:number_of_trial
  actor = actor0;
  
  areward = zeros(1,1);
  sactor = zeros(number_feature,1);
  scritic = zeros(number_feature,1);
  
  r = zeros(number_feature,1);
  z = zeros(number_feature,1);
  b = zeros(number_feature,1);
  A = eye(number_feature);
  alpha = 0;
  tol = 1e-5;
  kMax = 1*1e5;
  %kMax = 10;
  
  C = 10;
  gammaK = 0;
  betaK = 0;
  c = 100;
  count = 0;
  explr = 0.5;
  T = 100;%temperature
  s = 1;
  
  %initial state x0 and a0 using actor
  q_state = [randi(Gridinfo(1,1)),randi(Gridinfo(2,1)),randi(Gridinfo(3,1))];
  last_control = 1;
  [feature_gradient,control_probability] = ...
    calculate_feature_gradient(q_state,actor,last_control,m,vr0,...
    angular_rg,Gridinfo,energy, tran_prob, forest,fog,std_feature,...
    mean_feature,feature_set,number_feature);
  
  control = find(cumsum(control_probability)>rand,1);
  feature = feature_gradient(:,control);
  
  for k=1:kMax
    q_state_new = move_moth_q_return_one(q_state, tran_prob(:,:,control), Gridinfo);
    
    last_control = control;
    gK = reward.R(q_state_new(2), q_state_new(1));
    
    [feature_gradient_new, control_probability_new] = ...
      calculate_feature_gradient(q_state_new,actor,last_control,m,vr0,...
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
    criticDiff = r_new - r;
    
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
    diffReward = alpha_new - alpha;
    alpha = alpha_new;
    r = r_new;
    
  end
  disp(alpha)
  All_Ave_Rew(testnum) = alpha;
  All_iter_Time(testnum) = k;
  All_Actor(:,testnum) = actor;
end

save('../../data/processed/lstd_act_cri.mat','All_Ave_Rew','All_iter_Time','All_Actor')





