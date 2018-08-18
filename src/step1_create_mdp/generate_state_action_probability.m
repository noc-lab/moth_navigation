%%Procedure 1: generate state-action transition probability matrix
%The result is m matrices with columns in each matrix representing the
%position and rows representing the theta.

clc
clear 
close all
addpath('../utility/')

%% Pre-process forest data

load ../../data/raw/forest.mat % forest
forest = [forest.x forest.y forest.r];
save('../../data/processed/forest.mat','forest')

%% Find the range of map

AllData = [];
for id = [1 2 4 5 6 7 8 9]
  clear n_data
  load(sprintf('../../data/raw/moth-%d-speed-2.mat',id))
  for fog_id = 1:length(n_data.data);
    data = n_data.data{fog_id};
    pos_x = extractfield(data, 'pos_x');
    pos_y = extractfield(data, 'pos_y');
    
    MyData = [pos_x', pos_y'];
    AllData = [AllData; MyData];
  end
end

max_x = max([AllData(:,1);forest(:,1)]);
min_x = min([AllData(:,1);forest(:,1)]);
max_y = max([AllData(:,2);forest(:,2)]);
min_y = min([AllData(:,2);forest(:,2)]);

clearvars AllData n_data

%% Building gridworld

%Global parameters definition
delta_T = 5/60;%sampling period
v = 2; %linear speed, m/s
delta_x = floor(v*delta_T*sqrt(2)*100)/100;%length of grid, m
delta_y = delta_x;

n_x = ceil((max_x-min_x)/delta_x);
n_y = ceil((max_y-min_y)/delta_y);

Gridinfo = [n_x, min_x, max_x, (max_x-min_x)/n_x;
  n_y, min_y, max_y, (max_y-min_y)/n_y];

%% Define some dynamic parameters

m = 19;%number of control actions
m_res = 100;%Every discretized control action corresponds to 100 continuous actions
u_max = 0.60;%maximum angular speed control
vr_max = pi/2;%maximum visual reception angle


delta_theta = 5*pi/180;%Angle is discretized every 5 degrees
theta_res = 0.025*pi/180;%Every angle can be 20 different continous angles

theta_range = [-delta_theta/2 ; 2*pi-delta_theta/2];%To make sure that the first angle is pivoted at zero
theta = linspace(theta_range(1),theta_range(2),round(2*pi/delta_theta)+1);%theta is range, bound of each angle region
n_theta = length(theta)-1;%number of angles

%Control actions discretization
if mod(m-1,2) == 0 %m is odd
  m2 = (m-1)/2;%19 control actions
  u0 = logspace(log10(.001),log10(u_max),m2+1);
  u0 = sort([-u0 u0]);
  u_f = (u0(1:m)+u0(2:m+1))/2;%19 control actions
  
  vr0 = logspace(log10(.001),log10(vr_max),m2+1);
  vr0 = sort([-vr0 vr0]);
  vr_seg = (vr0(1:m)+vr0(2:m+1))/2;%same number of visual receptions
  
else %m is even
  u0 = logspace(log10(.001),log10(u_max),m/2);
  u0 = sort([-u0 0 u0]);
  u_f = (u0(1:m)+u0(2:m+1))/2;
  
  vr0 = logspace(log10(.001),log10(vr_max),m/2);
  vr0 = sort([-vr0  0 vr0]);
  vr_seg = (vr0(1:m)+vr0(2:m+1))/2;
end

syms x;
energy_fn = {
  1/vr_max*abs(x);
  1-abs(x)/vr_max;
  (1/(1+exp(-3/vr_max*abs(x)))-.5)*2;
  exp(-x^2/((2*vr_max/3)^2))
  };
n_energy_fn = length(energy_fn);
energy = zeros(n_energy_fn, m);

d_vr0 = diff(vr0);

for i=1:n_energy_fn
    for j=1:m
        energy(i, j) = int(energy_fn{i}, vr0(j), vr0(j + 1))/d_vr0(j);
    end
end

Gridinfo = [Gridinfo; n_theta, theta_range(1), theta_range(2),delta_theta];

%% Pack all the data

parameters.Gridinfo = Gridinfo;
parameters.theta_res = theta_res;
parameters.u0 = u0;
parameters.m = m;
parameters.vr_max = vr_max;
parameters.vr_seg = vr_seg;
parameters.vr0 = vr0;
parameters.energy = energy;

%% Calculating transform probablity

K_mean = 57;
xy_ratio = delta_y/delta_x;

tran_prob = zeros(n_theta,4*n_theta,m); %columns correspond to position update (E,N,W,S)=(1,2,3,4)

parfor i1 = 1:n_theta%current angle
  fprintf(1,'i1 = %d / %d\n',i1,n_theta);
  tmp_tran_prob = zeros(4*n_theta,m);
  theta_i = linspace(theta(i1),theta(i1+1)-theta_res,round(delta_theta/theta_res));%Get the lower bound covered, but not the upper bound
  theta_i = mod(theta_i-theta_range(1) , 2*pi)+theta_range(1);
  n_theta_i = length(theta_i);
  for i2 = 1:n_theta_i
    theta_i2 = theta_i(i2);
    for j1 = 1:m
      if j1 > 1
        u_lb = (u_f(j1-1)+u_f(j1))/2;
      else
        u_lb = -u_max;
      end
      if j1 < m
        u_ub = (u_f(j1)+u_f(j1+1))/2;
      else
        u_ub = u_max;
      end
      uj = linspace(u_lb,u_ub,m_res);
      n_uj = length(uj);
      for j2 = 1:n_uj%in the current angle, every control is calculated
        u_j2 = K_mean*uj(j2);
        theta_new = mod(theta_i2 + u_j2*delta_T/2 - theta_range(1), 2*pi) + theta_range(1);
        dist = calculate_grid_transition_probability(theta_new,xy_ratio);
        
        theta_new = mod(theta_i2 + u_j2*delta_T - theta_range(1), 2*pi) + theta_range(1);
        
        q_theta_new = quantize(theta_new,theta_range,n_theta);
        
        tmp_tran_prob((0:3)*n_theta+q_theta_new,j1) = ...
          tmp_tran_prob((0:3)*n_theta+q_theta_new,j1)+dist';
        
%         tran_prob(i1,(0:3)*n_theta+q_theta_new,j1) = ...
%           tran_prob(i1,(0:3)*n_theta+q_theta_new,j1)+dist;
      end
    end
  end
  tran_prob(i1,:,:) = tmp_tran_prob;
end

for i = 1:size(tran_prob,1)
  for k = 1:size(tran_prob,3)
    tran_prob(i,:,k) = tran_prob(i,:,k)/sum(tran_prob(i,:,k));
  end
end

save('../../data/processed/state_action_prob.mat','tran_prob','parameters')