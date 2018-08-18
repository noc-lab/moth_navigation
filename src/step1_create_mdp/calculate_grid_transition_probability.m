function dist = calculate_grid_transition_probability(theta,r)
% To find the transition probablity in the grid.
%(E,N,W,S)=(1,2,3,4)
dist= zeros(1,4);
theta = mod(theta,2*pi);
quadrant = floor(theta/(pi/2))+1;                   

switch quadrant
  case {1}
    if theta >=  atan(r)
      dist(1)= r*tan(pi/2 - theta)/2;
      dist(2)= 1- dist(1);
    else
      dist(2)= tan(theta)/(2*r);
      dist(1)= 1- dist(2);
    end
    
  case {2}
    if theta <=  atan(-r)+pi
      dist(3)= r*tan(theta-pi/2)/2;
      dist(2)= 1 - dist(3);
    else
      dist(2)= tan(pi-theta)/(2*r);
      dist(3)= 1 - dist(2);
    end
    
  case {3}
    if theta <=  atan(r) + pi
      dist(4)= tan(theta-pi)/(2*r);
      dist(3)= 1- dist(4);
    else
      dist(3)= r*tan(3*pi/2-theta)/2;
      dist(4)= 1- dist(3);
    end
    
  case {4}
    if theta <=  atan(-r)+2*pi
      dist(1)= r*tan(theta-3*pi/2)/2;
      dist(4)= 1- dist(1);
    else
      dist(4)= tan(2*pi-theta)/(2*r);
      dist(1)= 1- dist(4);
    end
    
end
