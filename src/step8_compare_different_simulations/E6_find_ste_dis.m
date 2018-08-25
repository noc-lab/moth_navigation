clear
clc
close all

load('../../data/processed/all_forest_reward_experi_3.mat','allforest')
load('../../data/processed/alltransprob','LOGTransProb','ACTransProb')
orginalACTProb = ACTransProb;
load('../../data/processed/actransprob_experi_3.mat','ACTransProb');
logReWard = zeros(size(LOGTransProb));
acReWard = zeros(size(LOGTransProb));

for id = 1:20
  
  parameters = allforest{id}.parameters;
  reward = allforest{id}.Reward;
  Gridinfo = parameters.Gridinfo;
  n_x = Gridinfo(1,1); n_y = Gridinfo(2,1);
  n_theta = Gridinfo(3,1);
  
  TransProb = LOGTransProb{id};
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
  
  logReWard(id) = expect_reward;
  
  this_reward = 0;
  for trial = 1:8
    
    TransProb = ACTransProb{id,trial};
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
    this_reward = max(this_reward,expect_reward);
  end
  
  TransProb = orginalACTProb{id};
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
  
  acReWard(id) = max(this_reward,expect_reward);
end

figure
plot([2:20],logReWard(2:20)./acReWard(2:20),'-o',...
  'LineWidth',2);
xlabel('n')
ylabel('R_{moth}/R_{best}')
grid on
print('-depsc2','-r200','../../figures/ratio_n_moth_vs_best.eps')
