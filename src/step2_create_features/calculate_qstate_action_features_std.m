%%%Procedure 4: sub-procedure from calculate_state_action_features_raw, to
%%%calculate the normalized features from the existing raw features
%returns the normalized feature

clear
close all
clc



%load necessary global parameters
load('../../data/processed/state_action_prob.mat', 'parameters');
m = parameters.m;

load('../../data/processed/qstate_action_features_raw.mat', 'state_action_features_raw');

number_samples = size(state_action_features_raw, 1);
number_features = 9;%total number of candidate features

state_action_features_std = zeros(number_samples, number_features*m);
%use different methods to normalize different kinds of features
std_feature = zeros(1, number_features);
mean_feature = zeros(1, number_features);
for k=1:number_features
    column_index = ((1:m) - 1)*number_features + k;
    feature_samples = state_action_features_raw(:, column_index);
    feature_samples = feature_samples(:);
    
    if k > 4
      std_feature(k) = std(nonzeros(feature_samples));
      mean_feature(k) = mean(nonzeros(feature_samples));
      feature_samples_std = (feature_samples-mean_feature(k))/std_feature(k);
      %normalize_feature(feature_samples, std_feature(k), mean_feature(k));
    else
      feature_samples_std = feature_samples - .5;
    end
    state_action_features_std(:, column_index) = reshape(feature_samples_std, number_samples, m);
    
end

%save the features
save('../../data/processed/qstate_action_features_std.mat', 'state_action_features_raw', 'state_action_features_std', 'std_feature', 'mean_feature');
fprintf(1,'Saved\n')

