function edge_img = my_canny( img, high_thresh, low_thresh )
%MY_CANNY performs edge detection using the Canny Edge Detector
%   It takes a grayscale image, a high threshold and a low threshold (for
%   double thresholding) and returns a binary image containing the edge
%   points.
    gaussian_mask = fspecial('gaussian',3,0.84932);
    gaussian_img = filter2(gaussian_mask, img);
    [grad_mag, grad_angle] = calculate_gradient(gaussian_img);
    grad_dir = discretize_gradient(grad_angle);
    non_maxima = non_maxima_suppress(grad_mag, grad_dir);
    low_threshold = threshold_matrix(non_maxima, low_thresh);
    high_threshold = threshold_matrix(non_maxima, high_thresh);
    joined_img = hysteresis(low_threshold, high_threshold);
    figure,image(joined_img);
    colormap gray(2);
end

function [grad_mag,grad_dir] = calculate_gradient(img)
%CALCULATE_GRADIENT calculates the gradient magnitude and gradient
%direction of an image.

    %Implement this function
    sobel_mask_x = [-1 0 1;-2 0 2;-1 0 1];
    sobel_mask_y = [-1 -2 -1; 0 0 0; 1 2 1];
    sobel_filter_x = filter2(sobel_mask_x, img);
    sobel_filter_y = filter2(sobel_mask_y, img);
    grad_mag = sqrt(sobel_filter_x.^2 + sobel_filter_y.^2);
    grad_dir = atan(sobel_filter_y./sobel_filter_x);
    
end

function grad_dir = discretize_gradient(grad_angle)
%DISCRETIZE_GRADIENT takes in a matrix containg a set of angles between
%-pi/2 and +pi/2 radians and discretizes them to an integer indication the
%nearest direction in an image where the values correspond to:
%   1 - Horizontal
%   2 - Diagonally upwards-and-right
%   3 - Vertical
%   4 - Diagonally upwards-and-left
    grad_angle = 8*grad_angle/pi;
    grad_dir = zeros(size(grad_angle));
    grad_dir((grad_angle>=-1) & (grad_angle<1)) = 1;
    grad_dir((grad_angle>=1) & (grad_angle<3)) = 2;
    grad_dir((grad_angle<-3) | (grad_angle>=3)) = 3;
    grad_dir((grad_angle>=-3) & (grad_angle<-1)) = 4;
end

function maxima_img = non_maxima_suppress(grad_mag,grad_dir)
%Given a matrix of gradient magnitudes and a matrix of gradient directions
%(as discretized by DISCRETIZE_GRADIENT), NON_MAXIMA_SUPPRESS returns a
%matrix where all values which are non-maximal in their local gradient
%directions are set to 0. Those which are maximal remain unchanged.
    grad_mag_e = expand_matrix(grad_mag);
    dir_1_max = max(grad_mag_e(2:end-1,1:end-2),grad_mag_e(2:end-1,3:end));
    dir_2_max = max(grad_mag_e(1:end-2,3:end),grad_mag_e(3:end,1:end-2));
    dir_3_max = max(grad_mag_e(1:end-2,2:end-1),grad_mag_e(3:end,2:end-1));
    dir_4_max = max(grad_mag_e(1:end-2,1:end-2),grad_mag_e(3:end,3:end));
    
    correct_dir_max = zeros(size(grad_mag));
    correct_dir_max(grad_dir == 1) = dir_1_max(grad_dir ==1);
    correct_dir_max(grad_dir == 2) = dir_2_max(grad_dir ==2);
    correct_dir_max(grad_dir == 3) = dir_3_max(grad_dir ==3);
    correct_dir_max(grad_dir == 4) = dir_4_max(grad_dir ==4);
    
    maxima_img = grad_mag;
    maxima_img(grad_mag<=correct_dir_max) = 0;
    
    function new_mat = expand_matrix(old_mat)
    %EXPAND_MATRIX adds a border of zeros to the original matrix passed to
    %it. It should only be used as a helper function for
    %NON_MAXIMA_SUPPRESS
        new_mat = zeros(size(old_mat,1)+2,size(old_mat,2)+2);
        new_mat(2:end-1,2:end-1) = old_mat;
    end
end

function t_img = threshold_matrix(mat,thresh)
%THRESHOLD_IMAGE takes in a matrix and a threshold. It returns a new matrix
%which is 0 where the original matrix was less than the threshold and 1
%elsewhere.
    
    %Implement this function
    mat(mat<thresh) = 0;
    mat(mat >= thresh) = 255;
    t_img = mat;

end

function joined_img = hysteresis(strong_edge,weak_edge)
%HYSTERESIS persorms image hysteresis, joining pixels in strong_edge using
%connecting pixels in weak_edge.
    [r,c] = find(strong_edge);
    joined_img = bwselect(weak_edge,c,r,8);
end