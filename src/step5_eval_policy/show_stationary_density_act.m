clc
clear
close all

load('../../data/processed/forest.mat')
load('../../data/processed/actor_critic_transition_probability','ACTranProb')
load ../../data/processed/reward.mat

load('../../data/processed/state_action_prob.mat', 'tran_prob', 'parameters');
m = parameters.m;
Gridinfo = parameters.Gridinfo;
n_x = Gridinfo(1,1); n_y = Gridinfo(2,1);
n_theta = Gridinfo(3,1);


iter_num = 1000;
% forget ratio
forget_rat = 0.01;
reg_rate = 0.01;
expect_reward = 0;

for ix = 1:n_x
  for iy = 1:n_y
    ACTranProb(:,ix,iy) = ...
      ACTranProb(:,ix,iy)./sum(ACTranProb(:,ix,iy));
  end
end

lambda = 0;

load('../../data/processed/state_action_samples.mat', 'state_action_samples')
prob_dens = zeros(n_x,n_y);

for i=1:size(state_action_samples,1)
  prob_dens(state_action_samples(i,1),state_action_samples(i,2)) = ...
    prob_dens(state_action_samples(i,1),state_action_samples(i,2)) + 1;
end

prob_dens = prob_dens./size(state_action_samples,1);
prob_dens = reg_rate*ones(n_x,n_y)/(n_x*n_y) + (1-reg_rate)*prob_dens;



for i = 1:iter_num
  disp(i)
  new_prob_dens = zeros(n_x,n_y);
  for ix=1:n_x
    for iy = 1:n_y
      for direction=1:4 %[E N W S] = [1 2 3 4]
        switch direction
          case 1
            next_x = mod(ix, n_x)+1;
            next_y = iy;
          case 2
            next_y = mod(iy, n_y)+1;
            next_x = ix;
          case 3
            next_x = mod(ix-2, n_x)+1;
            next_y = iy;
          case 4
            next_y = mod(iy-2, n_y)+1;
            next_x = ix;
        end
        new_prob_dens(next_x,next_y) = new_prob_dens(next_x,next_y) ...
          + ACTranProb(direction,ix,iy)*prob_dens(ix,iy);
      end
    end
  end
  prob_dens = forget_rat*prob_dens + (1-forget_rat)*new_prob_dens;
  expect_reward = lambda*expect_reward + sum(sum(R'.*prob_dens));
end

expect_reward

figure('Position',[1,1,600,600],'GraphicsSmoothing','off')
hold on
contourf(Y',X',log10(prob_dens),32,'LineStyle','none')
cc = -15:2:-1;
colorbar('Ticks',cc,'TickLabels',...
  {'10^{-15}','10^{-13}','10^{-11}','10^{-9}','10^{-7}','10^{-5}','10^{-3}','10^{-1}'},...
  'FontSize',14);
hold on
plot(forest(:,1), forest(:,2), 'ok','markersize',4)
set(gca,'position',[0.05 0.05 .8 .9],'units','normalized')

print('-depsc2','-r200','../../figures/actor_critic_stationary_dist.eps')

