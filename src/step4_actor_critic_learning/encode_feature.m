function [ phi ] = encode_feature(feature_gradient,feature_hessian,id)
%ENCODE_FEATURE Summary of this function goes here
%   Detailed explanation goes here

n = length(feature_gradient);
phi = zeros(n+n*(n+1)/2,1);

phi(1:n) = feature_gradient;
phi(n+1:end) = feature_hessian(id);
end

