%%%Procedure 2: generate rewards using forest information
clear
clc
close all

set(0,'DefaultAxesDrawMode','normal')


load('../../data/processed/state_action_prob.mat','parameters')
Girdinfo = parameters.Gridinfo;

x_range = Girdinfo(1,2:3);
y_range = Girdinfo(2,2:3);

delta_x = Girdinfo(1,4);
delta_y = Girdinfo(2,4);

%parameters definition
d_min = 1;
R_max = 1;
d_max = 1/sin(Girdinfo(3,4)/2);

%Calculate rewards with respect to positions
load('../../data/processed/forest');
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


% return
x = x_range(1)+delta_x/2:delta_x:x_range(2);
y = y_range(1)+delta_y/2:delta_y:y_range(2);
[X,Y] = meshgrid(x,y);

R = zeros(size(X));

for i = 1:length(fr)
    if mod(i,100) == 0
        fprintf(1,'i = %d / %d\n',i,length(fr));
    end
    dist = (fx(i)-X).^2 + (fy(i)-Y).^2;
    idx = find(dist <= (d_max*fr(i))^2);
    poly_coeff = subs(PP_val,fr(i))';
    for j = 1:length(idx)
        R(idx(j)) = R(idx(j)) + poly_coeff*sqrt(dist(idx(j))).^((0:nP-1)');
    end
end
RMAX = max(abs(R(:)));
R = R/max(abs(R(:)))*R_max;

% make sure that cells with trees have negative rewards
k = 1;
for i = 1:length(fr)
    if mod(i,100) == 0
        fprintf(1,'i = %d / %d\n',i,length(fr));
    end
    dist = (fx(i)-X).^2 + (fy(i)-Y).^2;
    idx = find(dist <= (fr(i))^2);
    poly_coeff = subs(PP_val,fr(i))';
    for j = 1:length(idx)
        R(idx(j)) = .1*poly_coeff*sqrt(dist(idx(j))).^((0:nP-1)');
        k = k+1;
    end
end
rewards = R;
fprintf(1,'Number of cells with trees: %d\n',k-1);
save('../../data/processed/reward.mat','R','X','Y','d_min','d_max');
fprintf(1,'Saved the reward matrix...\n');


%Plot the reward distribution figure and print to file
figure('PaperPositionMode', 'auto');
poly = subs(poly,r,1);
ezplot(poly,[0 d_max])
xlabel('Distance (multiples of the radius)','interpreter','latex','fontsize',13)
ylabel('Reward','interpreter','latex','fontsize',13);
title('')
grid on
box on
ylim([-5 50])
print('-depsc2','-r300','../../figures/reward_fn.eps')

figure('Position',[1,1,600,600],'GraphicsSmoothing','off','PaperPositionMode', 'auto')
contourf(X,Y,R,100,'LineColor','none')
colorbar('Ticks',-.1:.1:1,'FontSize',14);
axis equal
%xlabel('$x$','interpreter','latex','fontsize',14)
%ylabel('$y$','interpreter','latex','fontsize',14)
box on;
set(gca, 'CLim', [-.1,1]);
set(gca,'position',[0.05 0.02 .8 .96],'units','normalized')
print('-depsc2','-r150','../../figures/reward_contours.eps')

