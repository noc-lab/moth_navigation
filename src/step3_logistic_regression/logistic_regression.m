% This is the test code for logistic regression part.

close all
clc
clear

% load sample
load('../../data/processed/state_action_samples.mat',...
	'state_action_samples');
samples_control = state_action_samples(2:end, 4);

load('../../data/processed/qstate_action_features_std.mat',...
	'state_action_features_std');
samples_feature = state_action_features_std;

clearvars state_action_samples state_action_features_std;

load('../../data/processed/state_action_prob.mat', 'parameters');
m = parameters.m;
number_features = size(samples_feature, 2)/m;
number_samples = size(samples_feature, 1);

feature_set = [1 2 4 5 6 9];
number_test_features = length(feature_set);

samples_feature_selected = [];
for i=1:m
    temp = samples_feature(:,feature_set + (i-1)*number_features);
    %%%%%Added by Hao, Oct. 20, 2015, a constant feature
    %constant = ones(number_samples, 1);
    samples_feature_selected = [samples_feature_selected temp];
end


options = optimoptions(@fminunc,'Algorithm','quasi-newton',...
  'HessUpdate','bfgs',...
  'MaxFunEvals',1e14,...
  'TolX',1e-20,...
  'TolFun',1e-20,...
  'MaxIter',1e14,...
  'Display','off',...
  'GradObj','on',...
  'Hessian','off',...
  'DerivativeCheck','off');

r0 = zeros(number_test_features,1);
n = 40;
lambda = logspace(-4, 1, n);

weights = zeros(number_test_features, n);
log_likelihood = zeros(1, n);
validation = zeros(1, n);

ratio = 0.7;
num_train = ceil(ratio*number_samples);
RandID = randperm(number_samples);

Train_samples_feature_selected = samples_feature_selected(RandID(1:num_train),:);
Train_samples_control = samples_control(RandID(1:num_train));
Test_samples_feature_selected = samples_feature_selected(RandID(num_train+1:end),:);
Test_samples_control = samples_control(RandID(num_train+1:end));


parfor i = 1:n
  disp(i)
  [coeffs,fval] = fminunc(...
    @(r)logisticRegLikelihood(r, Train_samples_feature_selected, Train_samples_control, m, lambda(i))...
    ,r0,options);
  weights(:, i) = coeffs;
  log_likelihood(i) = fval;
  validation(i) = logisticRegLikelihood(coeffs, Test_samples_feature_selected, Test_samples_control, m, 0);
end

[~,bestid] = min(validation);

save('../../data/processed/log_reg.mat','weights','bestid','feature_set')

figure('Position',[100,100,750,500],'PaperPositionMode','auto')
hold on %'Bias'
fea_names = {'VR', 'VR(0)', 'VR(0.10)', 'VR(0.5)', 'OF', 'History', 'E1', 'E2', 'Energy'};%, 'VR(0.3)', 'VR(0.6)', 'VR(0.9)', 'E2', 'E3', 'E4'};%, 'constant offset'};
markers = {'+','o','*','.','x','s','d','^','v','>','<','p', 'h'};
cmap = hsv(number_test_features);  %# Creates a 6-by-3 set of colors from the HSV colormap
cmap = cmap(end:-1:1,:);
for a = 1:number_test_features
    semilogx(lambda, weights(a, :), ['-', markers{mod(a,numel(markers))+1}],'LineWidth',1.5)
end
axis([min(lambda),max(lambda),1.1*min(weights(:)),1.1*max(weights(:))])
xlabel('$\lambda$','Interpreter','latex','fontsize',16)
legend(fea_names(feature_set),'Location','northoutside','Orientation','horizontal','Interpreter','latex','fontsize',12)
set(gca,'XScale','log')
plot([lambda(bestid),lambda(bestid)],[1.1*min(weights(:)),1.1*max(weights(:))],':','LineWidth',2)
grid on
box on

figure('Position',[400,100,500,500],'PaperPositionMode','auto')
semilogx(lambda,exp(-log_likelihood),'linewidth',1.5);
xlabel('$\lambda$','Interpreter','latex','fontsize',14);
ylabel('$\mathrm{NLL}^*(\mathbf{\zeta})$','Interpreter','latex','fontsize',14);
grid on;

A = weights(:,bestid);
A./sum(abs(A))