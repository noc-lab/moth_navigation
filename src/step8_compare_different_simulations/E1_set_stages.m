% This procedure sets stages for the different artificial forests

clc
clear
close all
fog = 6.6;
tree_r = 0.0811;

load('../../data/processed/state_action_prob.mat','parameters')

% Find new grids

delta_x = parameters.Gridinfo(1,4);
delta_y = parameters.Gridinfo(2,4);

% small grid size

test_size = 20;

allforest = cell(test_size,1);

for forestsize = 1:test_size;

  n_x = 3*forestsize;
  n_y = 4*forestsize;

  min_x = 0;
  min_y = 0;

  max_x = n_x*delta_x;
  max_y = n_y*delta_y;

  tree_min_x = min_x - fog;
  tree_min_y = min_y - fog;
  tree_max_x = max_x + fog;
  tree_max_y = max_y + fog;

  aug_num_x = ceil(fog/max_x);
  aug_num_y = ceil(fog/max_y);

  tree_center_x = 1/2*delta_x;
  tree_center_y = 1/2*delta_y;

  %plant all trees

  forest = [];

  for ix = -aug_num_x:1:aug_num_x
      for iy = -aug_num_y:1:aug_num_y
          tree_x = ix*max_x+tree_center_x;
          tree_y = iy*max_y+tree_center_y;
          forest = [forest; tree_x, tree_y, tree_r];
      end
  end

  ThisGridInfo = parameters.Gridinfo;
  ThisGridInfo(1:2,:) = [n_x, min_x, max_x, delta_x; n_y, min_y, max_y, delta_y];

  thisenvironment.parameters = parameters;
  thisenvironment.parameters.Gridinfo = ThisGridInfo;
  thisenvironment.forest = forest;
  allforest{forestsize} = thisenvironment;
end

save('../../data/processed/forest_experi_3.mat','allforest')
