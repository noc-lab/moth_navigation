function [q_levels] = quantize(fea_vals, fea_rg, q_level_nums)
%quantization: return the vector of quantized number, lower bound included, upper
%bound not included
    N = size(fea_vals, 1);
    % length of each quantize level
    q_level_len = (fea_rg(2) - fea_rg(1)) ./ q_level_nums;
    qll_mat = ones(N, 1) * q_level_len;
    low_mat = ones(N, 1) * fea_rg(1);
    q_levels = (fea_vals - low_mat) ./ qll_mat;
    q_levels = floor(q_levels) + 1;
    
    % ensure the q_levels are in range.
    q_levels = max(q_levels,1);
    q_levels = min(q_levels,q_level_nums);
%     q_levels = max(q_levels, 1);
%     qln_mat = ones(N, 1) * q_level_nums;
%     q_levels = min(q_levels, qln_mat);
end
