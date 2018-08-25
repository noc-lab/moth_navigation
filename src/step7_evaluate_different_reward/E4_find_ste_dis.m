clear
clc
close all

load('../../data/processed/forest_experi_2.mat','environment')
load('../../data/processed/alltransprob_experi_2','LOGTranProb','ACTranProb')
load('../../data/processed/change_d_min.mat','AllRerard','possible_d_min')
%load('change_d_max.mat','AllRerard','possible_d_max_factor')

%possible_d_min = possible_d_max_factor;


logReWard = zeros(size(possible_d_min));
acReWard = zeros(size(possible_d_min));

for id = 1:length(possible_d_min)
  reward = AllRerard{id};
  parameters = environment.parameters;
  Gridinfo = parameters.Gridinfo;
  n_x = Gridinfo(1,1); n_y = Gridinfo(2,1);
  n_theta = Gridinfo(3,1);

  TransProb = LOGTranProb;
  % iteration length
  iter_num = 1000;
  % forget ratio
  forget_rat = 0.01;
  expect_reward = 0;


  for ix = 1:n_x
    for iy = 1:n_y
      for itheta = 1:n_theta
        TransProb(:,ix,iy) = ...
          TransProb(:,ix,iy)./sum(TransProb(:,ix,iy));
      end
    end
  end

  lambda = 1;
  prob_dens = ones(n_x,n_y)/(n_x*n_y);


  for i = 1:iter_num
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
            + TransProb(direction,ix,iy)*prob_dens(ix,iy);
        end
      end
    end
    prob_dens = forget_rat*prob_dens + (1-forget_rat)*new_prob_dens;
    expect_reward = lambda*expect_reward + sum(sum(reward.*prob_dens));
  end

  logReWard(id) = expect_reward;

  TransProb = ACTranProb;
  % iteration length
  iter_num = 1000;
  % forget ratio
  forget_rat = 0.01;
  reg_rate = 0.01;
  expect_reward = 0;


  for ix = 1:n_x
    for iy = 1:n_y
      for itheta = 1:n_theta
        TransProb(:,ix,iy) = ...
          TransProb(:,ix,iy)./sum(TransProb(:,ix,iy));
      end
    end
  end

  lambda = 1;
  prob_dens = ones(n_x,n_y)/(n_x*n_y);


  for i = 1:iter_num
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
            + TransProb(direction,ix,iy)*prob_dens(ix,iy);
        end
      end
    end
    prob_dens = forget_rat*prob_dens + (1-forget_rat)*new_prob_dens;
    expect_reward = lambda*expect_reward + sum(sum(reward.*prob_dens));
  end

  acReWard(id) = expect_reward; 
end

figure
plot(possible_d_min,logReWard./acReWard,'-o',...
  'LineWidth',2);
xlabel('\alpha')
ylabel('R_{moth}/R_{ac}')
grid on
print('-depsc2','-r200','../../figures/ratio_d_moth_vs_ac.eps')


load('../../data/processed/change_d_max.mat','AllRerard','possible_d_max_factor')

possible_d_min = possible_d_max_factor;

logReWard = zeros(size(possible_d_min));
acReWard = zeros(size(possible_d_min));

for id = 1:length(possible_d_min)
  reward = AllRerard{id};
  parameters = environment.parameters;
  Gridinfo = parameters.Gridinfo;
  n_x = Gridinfo(1,1); n_y = Gridinfo(2,1);
  n_theta = Gridinfo(3,1);

  TransProb = LOGTranProb;
  % iteration length
  iter_num = 1000;
  % forget ratio
  forget_rat = 0.01;
  expect_reward = 0;


  for ix = 1:n_x
    for iy = 1:n_y
      for itheta = 1:n_theta
        TransProb(:,ix,iy) = ...
          TransProb(:,ix,iy)./sum(TransProb(:,ix,iy));
      end
    end
  end

  lambda = 1;
  prob_dens = ones(n_x,n_y)/(n_x*n_y);


  for i = 1:iter_num
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
            + TransProb(direction,ix,iy)*prob_dens(ix,iy);
        end
      end
    end
    prob_dens = forget_rat*prob_dens + (1-forget_rat)*new_prob_dens;
    expect_reward = lambda*expect_reward + sum(sum(reward.*prob_dens));
  end

  logReWard(id) = expect_reward;

  TransProb = ACTranProb;
  % iteration length
  iter_num = 1000;
  % forget ratio
  forget_rat = 0.01;
  reg_rate = 0.01;
  expect_reward = 0;


  for ix = 1:n_x
    for iy = 1:n_y
      for itheta = 1:n_theta
        TransProb(:,ix,iy) = ...
          TransProb(:,ix,iy)./sum(TransProb(:,ix,iy));
      end
    end
  end

  lambda = 1;
  prob_dens = ones(n_x,n_y)/(n_x*n_y);


  for i = 1:iter_num
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
            + TransProb(direction,ix,iy)*prob_dens(ix,iy);
        end
      end
    end
    prob_dens = forget_rat*prob_dens + (1-forget_rat)*new_prob_dens;
    expect_reward = lambda*expect_reward + sum(sum(reward.*prob_dens));
  end

  acReWard(id) = expect_reward; 
end

figure
plot(possible_d_min,logReWard./acReWard,'-o',...
  'LineWidth',2);
xlabel('\beta')
ylabel('R_{moth}/R_{ac}')
grid on
print('-depsc2','-r200','../../figures/ratio_beta_moth_vs_ac.eps')