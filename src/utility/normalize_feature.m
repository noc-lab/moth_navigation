function std_feature = normalize_feature(raw_feature, deviation, mea)
std_feature = (raw_feature - mea)/deviation;
end