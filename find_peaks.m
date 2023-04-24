function [idx, val] = find_peaks(input_data)
    diff_data = diff(input_data);
    idx       = find((diff_data(1:end-1) > 0 & diff_data(2:end) < 0) | (diff_data(1:end-1) < 0 & diff_data(2:end) > 0)) + 1;
    val       = input_data(idx);
end