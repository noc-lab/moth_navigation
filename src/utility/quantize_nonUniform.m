function [q_levels] = quantize_nonUniform(fea_vals, disc_vals)
    N = length(fea_vals);
    q_levels = zeros(1,N);
    for i = 1:N
      if (fea_vals(i)>max(disc_vals))
          q_levels(i) = length(disc_vals) - 1;
      else
          q_levels(i) = find(fea_vals(i) < disc_vals,1)-1;
      end      
      if (q_levels(i)==0)
          q_levels(i) = 1;
      end
    end
end
