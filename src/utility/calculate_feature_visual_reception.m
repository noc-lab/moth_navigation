function [visual_reception, optical_flow] = ...
  calculate_feature_visual_reception(state,angular_res,angular_rg,ang_vr_seg,forest,fog)
%%%calculate the feature of visual reception in current cell
%returns a vector of visual reception with respect to different controls
%visual reception can be seen as a stationary point of optical flow

x = state(1);
y = state(2);
heading = state(3);
n_of = ceil(angular_rg/angular_res);
%ang_vr_seg = parameters.vr0;


%find the effective forests
max_distance = fog;

% fx and fx can be optimal with rx and ry
distance = sqrt((forest(:,1)-x).^2 + (forest(:,2)-y).^2);
idx = (distance < max_distance);
forest = forest(idx,:);
distance = distance(idx);

%Get the current direction
ang_vr_seg = ang_vr_seg+heading;
ang_of_seg1 = heading-angular_rg/2;  % theta - pi/2
ang_of_seg2 = heading+angular_rg/2;  % theta + pi/2


ang_of_seg = linspace(ang_of_seg1,ang_of_seg2,n_of+1);   % segmentations for the optical flow

if any(distance <= forest(:,3))   % hit a tree
    visual_reception = diff(ang_vr_seg)*n_of/angular_rg;
    idx = find(visual_reception<0);
    visual_reception(idx) = (ang_vr_seg(idx+1)+2*pi-ang_vr_seg(idx))*n_of/angular_rg;
    optical_flow = diff(ang_of_seg)*n_of/angular_rg;
    idx = find(optical_flow<0);
    optical_flow(idx) = (ang_of_seg(idx+1)+2*pi-ang_of_seg(idx))*n_of/angular_rg;
    return;
end

ang_heading_angles = atan2(forest(:,2) - y, forest(:,1) - x); 
ang_heading_angles(ang_heading_angles<(heading-pi)) = 2*pi + ...
  ang_heading_angles(ang_heading_angles<(heading-pi));
ang_view_half_angles = asin(forest(:,3) ./ distance);

ang_view_ub = ang_heading_angles + ang_view_half_angles;
ang_view_lb = ang_heading_angles - ang_view_half_angles;

visible_range = forest(:,3) / sin(angular_res/20);

seen_trees = find((ang_view_lb < ang_of_seg2) & (ang_view_ub > ang_of_seg1) &...
   (distance < fog) & (distance < visible_range) );

seen_view_ub = ang_view_ub(seen_trees);
seen_view_lb = ang_view_lb(seen_trees);
[seen_view_union_lb, seen_view_union_ub] = MergeBrackets(seen_view_lb, seen_view_ub);

visual_reception = cal_sep_measure(seen_view_union_lb, seen_view_union_ub, ang_vr_seg);
visual_reception = visual_reception./diff(ang_vr_seg); %./ diff_vr;

optical_flow = cal_sep_measure(seen_view_union_lb, seen_view_union_ub, ang_of_seg);
optical_flow = optical_flow*n_of/angular_rg;% ./ diff_of;

end

function measure = cal_sep_measure(seen_view_union_lb, seen_view_union_ub, sep) 
    measure = zeros(1, length(sep)-1);
    for i = 1:(length(sep) - 1)
        left_thres = sep(i);
        right_thres = sep(i+1);
        seg_view_union_lb_current = max(seen_view_union_lb, left_thres);
        seg_view_union_ub_current = min(seen_view_union_ub, right_thres);
        measure(i) = sum(max(seg_view_union_ub_current - seg_view_union_lb_current, 0));

    end
end

function [lower, upper] = MergeBrackets(left, right)
% function [lower upper] = MergeBrackets(left, right)
%
% Purpose: Interval merging
%
% Given N input closed intervals in braket form:
%   Ii := [left(i),right(i)], i = 1,2...,N (mathematical notation)
% The set union{Ii) can be written as a canonical partition by
%   intervals Jk; i.e., union{Ii) = union(Jk), where Jk are M intervals
%   (with M<=N, so the partition is minimum cardinal), and {Jk} are
%   disjoint to each other (their intersections are empty). This function
%   returns Jk = [lower(k),upper(k)], k=1,2,...M, in the ascending sorted
%   order.
%
% EXAMPLE USAGE:
%   >> [lower upper] = MergeBrackets([0 1 2 3 4],[1.5 1.6 3.5 3 5])
%   	lower =   0    2  4
%       upper = 1.6  3.5  5
%
% Algorithm complexity: O(N*log(N))
%
% Author: Bruno Luong <brunoluong@yahoo.com>
% Original: 25-May-2009

% Detect when right < left (empty Ii), and later remove it (line #29, 30)
%notempty = (right>=left);

%I assume the data is clean 

% sort the rest by left bound
[left, iorder] = sort(left);
right = right(iorder);

% Allocate, as we don't know yet the size, we assume the largest case
lower = zeros(size(left));
upper = zeros(size(right));

% Nothing to do
if isempty(lower)
    return
end

% Initialize
l = left(1);
u = right(1);
k = 0;
% Loop on brakets
for i=1:length(left)
    if left(i) > u % new Jk detected
        % Stack the old one
        k = k+1;
        lower(k) = l;
        upper(k) = u;
        % Reset l and u
        l = left(i);
        u = right(i);
    else
        u = max(u, right(i));
    end
end % FOR loop
% Stack the last one
k = k+1;
lower(k) = l;
upper(k) = u;

% Remove the tails
lower(k+1:end) = [];
upper(k+1:end) = [];

end % MergeBrackets
