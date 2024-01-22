function [result] = gs_box(im,radius,iter)

    [m,n,c]=size(im);
% 
%   img = bsxfun(@minus, img, mean(img, 1));
    iteration = iter;
    r = radius; %the radius of the side window
    k = ones(2*r+1,1)/(2*r+1); %separable kernel 
    k_L=k; k_L(r+2:end)=0; k_L = k_L/sum(k_L); %half kernel
    k_R=flipud(k_L); 
    m = size(im,1)+2*r; n = size(im,2)+2*r; total = m*n;
    [row, col]=ndgrid(1:m,1:n); 
    offset = row + m*(col-1) - total;
    im = single(im); 
    result = im; 
    d = zeros(m,n,8,'single'); 
    delta_list = zeros(1,10);
     
    old_result = result;
    % pca_img = img_pca(result, 1);
    % U = padarray(pca_img,[r,r],'replicate'); 

    pca_img = img_pca(result, 1);
    U = padarray(pca_img,[r,r],'replicate'); 

    d(:,:,1) = conv2(k_L, k_L, U,'same') - U;
    d(:,:,2) = conv2(k_L, k_R, U,'same') - U;
    d(:,:,3) = conv2(k_R, k_L, U,'same') - U;
    d(:,:,4) = conv2(k_R, k_R, U,'same') - U;
    d(:,:,5) = conv2(k_L, k, U,'same') - U;
    d(:,:,6) = conv2(k_R, k, U,'same') - U;
    d(:,:,7) = conv2(k, k_L, U,'same') - U;
    d(:,:,8) = conv2(k, k_R, U,'same') - U;

    %find the minimal signed distance
    tmp = abs(d); 
    [~,ind] = min(tmp,[],3);
    for i = 1:iteration       
        for ch=1:size(im,3)
            %all projection distances
            U = padarray(result(:,:,ch),[r,r],'replicate'); 
            d(:,:,1) = conv2(k_L, k_L, U,'same') - U;
            d(:,:,2) = conv2(k_L, k_R, U,'same') - U;
            d(:,:,3) = conv2(k_R, k_L, U,'same') - U;
            d(:,:,4) = conv2(k_R, k_R, U,'same') - U;
            d(:,:,5) = conv2(k_L, k, U,'same') - U;
            d(:,:,6) = conv2(k_R, k, U,'same') - U;
            d(:,:,7) = conv2(k, k_L, U,'same') - U;
            d(:,:,8) = conv2(k, k_R, U,'same') - U;

            index = offset+total*ind;
            dm = d(index); %signed minimal distance
            %update
            U = U + dm; 
            result(:,:,ch) = U(r+1:end-r,r+1:end-r);
        end
    end 
end