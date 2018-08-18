% This procedure find transition prob. for the different artificial forests
% under actor-critic and logstic regression

clear
close all
clc
addpath('../utility/')
fog = 6.6;

load('../../data/processed/all_forest_reward.mat','allforest')
load('../../data/processed/state_action_prob.mat','tran_prob')

m=allforest{1}.parameters.m;
n_theta = allforest{1}.parameters.Gridinfo(3,1);
vr0 = allforest{1}.parameters.vr0;
angular_rg = 2*allforest{1}.parameters.vr_max;
energy = allforest{1}.parameters.energy;

load('../../data/processed/log_reg.mat','feature_set')
number_feature = length(feature_set);

feature_character = load('../../data/processed/qstate_action_features_std.mat', 'std_feature', 'mean_feature');
std_feature = feature_character.std_feature;
std_feature(1:4) = 1;
mean_feature = feature_character.mean_feature;
mean_feature(1:4) = -.5;

load('../../data/processed/lstd_act_cri.mat', 'All_Ave_Rew','All_iter_Time','All_Actor');
[~,id] = max(All_Ave_Rew);
AC_weight = All_Actor(:,id);
load('../../data/processed/log_reg.mat','weights','bestid','feature_set')
LOG_weight = weights(:,bestid);

load('../../data/processed/state_action_samples.mat', 'state_action_samples')
u_feq = zeros(m,1);
for i=1:m
  u_feq(i) = sum( state_action_samples(:,4) == i);
end
u_feq = u_feq/size(state_action_samples,1);
u_feq = (u_feq+flip(u_feq))/2;

clearvars state_action_samples actor
LOGTransProb = cell(size(allforest));
ACTransProb = cell(size(allforest));


parfor id = 1:20
  disp(id)
  parameters = allforest{id}.parameters;
  forest = allforest{id}.forest;
  Gridinfo = parameters.Gridinfo;
  n_x = Gridinfo(1,1); n_y = Gridinfo(2,1);

  LOGTranProb = zeros(4,n_x,n_y);

  for ix = 1:n_x
    for iy = 1:n_y
      for itheta = 1:9:n_theta
        for last_control = 1:m
          [~,control_probability] = ...
              calculate_feature_gradient_mex([ix,iy,itheta],LOG_weight,last_control,m,vr0,...
              angular_rg,Gridinfo,energy, tran_prob, forest,fog,std_feature,...
              mean_feature,feature_set,number_feature);

          for icontrol = 1:m
            LOGTranProb(:,ix,iy) = LOGTranProb(:,ix,iy) + ...
                control_probability(icontrol)*u_feq(last_control)* ...
                move_moth_place([ix,iy,itheta], tran_prob(:,:,icontrol), n_theta);
          end
        end
      end
    end
  end

  LOGTransProb{id} = LOGTranProb;
  
  ACTranProb = zeros(4,n_x,n_y);

  for ix = 1:n_x
    for iy = 1:n_y
      for itheta = 1:9:n_theta
        for last_control = 1:m
          [~,control_probability] = ...
              calculate_feature_gradient_mex([ix,iy,itheta],AC_weight,last_control,m,vr0,...
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

  ACTransProb{id} = ACTranProb;
end

save('../../data/processed/alltransprob','LOGTransProb','ACTransProb')