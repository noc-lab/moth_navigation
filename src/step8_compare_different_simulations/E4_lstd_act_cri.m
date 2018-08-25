clear
clc
close all;

addpath('../utility/')

%global parameters setting
lambda = 0.9;
fog = 6.6;

%load the transition probability
load('../../data/processed/state_action_prob.mat', 'tran_prob');
load('../../data/processed/all_forest_reward.mat','allforest')
load('../../data/processed/exp3_LogReWard.mat','logReWard')
allResult = cell(size(allforest));
for id = 1:length(allforest)
  disp(id)
  parameters = allforest{id}.parameters;
  m = parameters.m;
  vr0 = parameters.vr0;
  angular_rg = 2*parameters.vr_max;
  Gridinfo = parameters.Gridinfo;
  energy = parameters.energy;
  reward = allforest{id}.Reward;
  forest = allforest{id}.forest;


  %load the selected feature set
  load('../../data/processed/log_reg.mat','weights','bestid','feature_set')
  number_feature = length(feature_set);
  actor0 = weights(:,bestid);

  feature_character = load('../../data/processed/qstate_action_features_std.mat', 'std_feature', 'mean_feature');
  std_feature = feature_character.std_feature;
  std_feature(1:4) = 1;
  mean_feature = feature_character.mean_feature;
  mean_feature(1:4) = -.5;


  number_of_trial = 400;

  All_Ave_Rew = zeros(number_of_trial,1);
  All_Actor = zeros(number_feature,number_of_trial);
  kMax = 5000;

  parfor testnum = 1:number_of_trial
    [alpha,actor] = LSTD_actor_critic_wapper(tran_prob,fog,m,vr0,...
    angular_rg,Gridinfo,energy,reward,forest,actor0,logReWard(id)/1000,std_feature,...
    mean_feature,feature_set,number_feature,kMax);

    All_Ave_Rew(testnum) = alpha;
    All_Actor(:,testnum) = actor;
  end
  
  allResult{id}.All_Ave_Rew = All_Ave_Rew;
  allResult{id}.All_Actor = All_Actor;
end

save('../../data/processed/allacresult','allResult')




