clear
clc
close all

addpath('../utility/')
fog = 6.6;

% Load Logistic regression result

load('../../data/processed/log_reg.mat','feature_set')
load('../../data/processed/lstd_act_cri.mat', 'All_Ave_Rew','All_iter_Time','All_Actor');
[~,id] = max(All_Ave_Rew);
actor = All_Actor(:,id);


number_feature = length(feature_set);

% Load the feature
feature_character = load('../../data/processed/qstate_action_features_std.mat', 'std_feature', 'mean_feature');
std_feature = feature_character.std_feature;
std_feature(1:4) = 1;
mean_feature = feature_character.mean_feature;
mean_feature(1:4) = -.5;

load('../../data/processed/state_action_prob.mat', 'tran_prob', 'parameters');
m = parameters.m;
vr0 = parameters.vr0;
angular_rg = 2*parameters.vr_max;
Gridinfo = parameters.Gridinfo;
energy = parameters.energy;
n_x = Gridinfo(1,1); n_y = Gridinfo(2,1);
n_theta = Gridinfo(3,1);

load('../../data/processed/state_action_samples.mat', 'state_action_samples')
u_feq = zeros(m,1);
for i=1:m
  u_feq(i) = sum( state_action_samples(:,4) == i);
end
u_feq = u_feq/size(state_action_samples,1);
u_feq = (u_feq+flip(u_feq))/2;
reward = load('../../data/processed/reward.mat');
load('../../data/processed/forest.mat')

clearvars state_action_samples

ACTranProb = zeros(4,n_x,n_y);
    
parfor ix = 1:n_x
  disp(ix)
  for iy = 1:n_y
    for itheta = 1:9:n_theta
      for last_control = 1:m
        [~,control_probability] = ...
          calculate_feature_gradient([ix,iy,itheta],actor,last_control,m,vr0,...
          angular_rg,Gridinfo,energy, tran_prob, forest,fog,std_feature,...
          mean_feature,feature_set,number_feature);
        
        for icontrol = 1:m
          ACTranProb(:,ix,iy) = ACTranProb(:,ix,iy) + ...
            control_probability(icontrol)*u_feq(last_control)* ...
            move_moth_place([ix,iy,itheta], tran_prob(:,:,icontrol), n_theta);
        end
      end
    end
  end
end

save('../../mat/actor_critic_transition_probability','ACTranProb')


