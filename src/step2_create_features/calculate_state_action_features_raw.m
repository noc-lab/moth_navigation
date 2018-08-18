%%%Procedure 4: calculate the features of specified state-action pairs
%This is the most important function to be defined, the performance of
%logistic regression and actor-critic algorithm depends on the definition
%and normalization of features
%This function embedded the single-state state-action feature calculation
%in it.
clear
clc
close all

addpath('../utility/')


load('../../data/processed/state_action_samples.mat', 'state_action_samples');

%load necessary global parameters
load('../../data/processed/state_action_prob.mat', 'tran_prob', 'parameters');
m = parameters.m;
vr0 = parameters.vr0;
angular_rg = 2*parameters.vr_max;
Gridinfo = parameters.Gridinfo;
energy = parameters.energy;


load ../../data/processed/forest.mat;%load structure data forest

number_samples = size(state_action_samples, 1);
number_features = 9;%total number of candidate features
%10 features are as follows:
%fea1, visual reception,
%fea2, visual reception with 0.3 threshold,
%fea3, visual reception with 0.6 threshold,
%fea4, visual reception with 0.9 threshold,
%fea5, optical flow,
%fea6, history control action,
%fea7, energy preservation 1,
%fea8, energy preseravtion 2,
%fea9, energy preservation 3.

state_action_features_raw = zeros(number_samples - 1, number_features*m);

% state_action_features_std_minus_mean = zeros(number_samples, number_features*m);
%parpool(8)

parfor i=2:number_samples
  state = state_action_samples(i, 5:7);
  fog = state_action_samples(i, 8);
  q_state = state_action_samples(i, 1:3);
  last_control = state_action_samples(i-1, 4);%omitting the first point
  
  
  %embedded all the feature calculation in one function, for further use
  %in action-critic learning
  state_feature =calculate_feature_state(state, q_state, last_control, ...
  tran_prob,forest,fog,m,vr0,angular_rg,Gridinfo,energy);

%   state_feature = calculate_feature_state(q_state, last_control,...
%     tran_prob,forest,fog,m,vr0,angular_res,angular_rg,Gridinfo,Thetainfo,energy);

  state_feature = state_feature(:);
  state_action_features_raw(i - 1, :) = state_feature';
  
end
save('../../data/processed/state_action_features_raw.mat', 'state_action_features_raw');
fprintf(1, 'Raw features of samples calculated and saved!');

