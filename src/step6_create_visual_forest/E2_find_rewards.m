% This procedure find rewards for the different artificial forests

clear
clc
close all

set(0,'DefaultAxesDrawMode','normal')

tree_r = 0.0811;
RMAX = 261.238654714193;

% only load the previous results and polt

load('../../data/processed/all_forest.mat')

 for id = 1:20

  parameters = allforest{id}.parameters;
  Gridinfo = parameters.Gridinfo;

  delta_x = Gridinfo(1,4);
  delta_y = Gridinfo(2,4);

  %parameters definition
  d_min = 1;
  R_max = 1;
  d_max = 1/sin(Gridinfo(3,4)/2);

  %Calculate rewards with respect to positions
  forest = allforest{id}.forest;
  fx = forest(:,1);
  fy = forest(:,2);
  fr = forest(:,3);


  x = sym('x','real');
  r = sym('r','real');

  main_pts = [0 -1 ; d_min*r 0 ; (d_max+d_min)/2*r 43.5 ; (.95*(d_max-d_min)+d_min)*r .5 ; d_max*r 0]';
  slopes = [0 -1 0 ; (d_max+d_min)/2*r 1 0 ; d_max*r 0 0]';

  nP = size(main_pts,2)+size(slopes,2);
  PP = sym('PP',[1 nP]);
  poly = PP*(x.^((0:nP-1)'));
  eqs = sym(zeros(nP,1));
  % eval(sprintf('PP = sym(zeros(1,%d))',nP));
  k = 1;
  for i = 1:size(main_pts,2)
    eqs(k) = subs(poly,main_pts(1,i)) == main_pts(2,i);
    k = k+1;
  end
  poly_diff = diff(poly);
  for i = 1:size(slopes,2)
    eqs(k) = subs(poly_diff,slopes(1,i)) == slopes(3,i);
    k = k+1;
  end
  vars = '';
  for i = 1:nP
    vars = [vars sprintf('PP(%d),',i)]; %#ok<AGROW>
  end
  vars(end) = [];
  eval(sprintf('sol = solve(eqs,%s);',vars));
  PP_val = sym(zeros(nP,1));
  for i = 1:nP
    eval(sprintf('PP_val(%d) = sol.PP%d;',i,i));
  end

  poly = PP_val'*(x.^((0:nP-1)'));
  poly_coeff = eval(subs(PP_val,tree_r)');

  Reward = zeros(Gridinfo(1,1),Gridinfo(2,1));

  max_reward_range = d_max*tree_r;

  for ix = 1:Gridinfo(1,1)
    for iy = 1:Gridinfo(2,1)
      xcor = Gridinfo(1,2) + (ix-1/2)*Gridinfo(1,4);
      ycor = Gridinfo(2,2) + (iy-1/2)*Gridinfo(2,4);

      % Find Tree
      NearTree = pdist2(forest(:,1:2),[xcor,ycor]);
      NearTree = NearTree(NearTree<max_reward_range);

      for itree = 1:length(NearTree)
        Reward(ix,iy) = Reward(ix,iy) + poly_coeff*NearTree(itree).^((0:nP-1)');
      end
    end
  end

  

  Reward = Reward/max(abs(Reward(:)))*R_max;
  Reward(1,1) = -.1;
  allforest{id}.Reward = Reward;
end
%gridplot(Reward)
save('../../data/processed/all_forest_reward.mat','allforest')


