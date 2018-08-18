%%%Procedure 3: extract from the data, to get the quantized state-action
%%%pairs

clear
clc
close all
addpath('../utility/')


load('../../data/processed/state_action_prob.mat', 'parameters');

Girdinfo = parameters.Gridinfo;

x_range = Girdinfo(1,2:3);
y_range = Girdinfo(2,2:3);

delta_x = Girdinfo(1,4);
delta_y = Girdinfo(2,4);

theta_range = Girdinfo(3,2:3);

u0 = parameters.u0;


AllData = [];
for id = [1 2 4 5 6 7 8 9]
    clear n_data
    load(sprintf('../../data/raw/moth-%d-speed-2.mat',id))
    for fog_id = 1:length(n_data.data)
        data = n_data.data{fog_id};
        pos_x = extractfield(data, 'pos_x');
        pos_y = extractfield(data, 'pos_y');
        head_x = extractfield(data, 'head_x');
        head_y = extractfield(data, 'head_y');
        yaw_control = extractfield(data, 'yaw_control');
        yaw_control = -yaw_control;
        
        fog_max = extractfield(data, 'fog_max');
        yaw_torque = extractfield(data, 'yaw_torque');
        MyData = [pos_x', pos_y', atan2(head_y,head_x)', yaw_control', fog_max', yaw_torque'];
        AllData = [AllData; MyData];
    end
end

% Remove NaNs
AllData(any(isnan(AllData),2),:) = [];

%pre-processing the data to get quantized state-action pairs
q_x = quantize(AllData(:,1), x_range, Girdinfo(1,1));
q_y = quantize(AllData(:,2), y_range, Girdinfo(2,1));
num_data = size(AllData,1);


state_action_samples = [q_x q_y exp(1i*AllData(:,3))  AllData(:,[4 1 2 5 6]) zeros(num_data,1)];


laststate = state_action_samples(1,1:2);
lastindex = 1;
samestate = 1;

for id=2:num_data
    if sum(laststate == state_action_samples(id,1:2))==2
        state_action_samples(id,end) = 1;
        state_action_samples(lastindex,[3:6 8]) = state_action_samples(lastindex,[3:6 8]) + state_action_samples(id,[3:6 8]);
        samestate = samestate + 1;
    else
        %summary last state
        state_action_samples(lastindex,[3 5 6 8]) = state_action_samples(lastindex,[3 5 6 8])./samestate;
        
        laststate = state_action_samples(id,1:2);
        lastindex = id;
        samestate = 1;
    end
end

state_action_samples(lastindex,[3:6 8]) = state_action_samples(lastindex,[3:6 8])./samestate;
state_action_samples = state_action_samples(state_action_samples(:,end)==0,1:end-1);
%state_action_samples(:,[3,4]) = round(state_action_samples(:,[3,4]));

state_action_samples(:,3) = atan2(imag(state_action_samples(:,3)), real(state_action_samples(:,3)));
th = state_action_samples(:,3);
th(th<theta_range(1)) = th(th<theta_range(1)) + 2*pi;
q_th = quantize(th, theta_range, Girdinfo(3,1));
q_control = quantize_nonUniform(state_action_samples(:,4), u0)';
state_action_samples = [ state_action_samples(:,1:2) q_th  q_control state_action_samples(:,5:6) th state_action_samples(:,7:8)];

save('../../data/processed/state_action_samples.mat', 'state_action_samples');
fprintf(1, 'Extraction trajectory data from moth finished!');



%Plot the original moth trajectory with forest information
%count the frequency of states from samples
reward = load('../../data/processed/reward.mat');
Z = zeros(size(reward.X));
number_samples = size(state_action_samples,1);
for k=1:number_samples
    Z(state_action_samples(k, 2), state_action_samples(k, 1)) = Z(state_action_samples(k, 2), state_action_samples(k, 1)) + 1;
end
sumZ = sum(Z(:));
Z = Z/sumZ;
load('../../data/processed/forest');
fx = forest(:,1);
fy = forest(:,2);

figure('Position',[1,1,600,600],'GraphicsSmoothing','off','PaperPositionMode', 'auto')
contourf(reward.X,reward.Y,Z,500,'linecolor','none');
% colormap(hot)
colormap(jet);
CData = colormap;
CData(1,:) = ones(1,3);
colormap(CData);
% colorbar
hold on
plot(fx, fy, 'ok','markersize',4);
axis equal;
xlim(x_range);
ylim(y_range);
xlabel('$x$','interpreter','latex','fontsize',13);
ylabel('$y$','interpreter','latex','fontsize',13);
box on;
print('-depsc2','-r150','../../figures/all_traj.eps')
