function [result] = gs_box(im,radius,PC)
    [m,n,c]=size(im);
    r = radius; %the radius of the side window
    k = ones(2*r+1,1)/(2*r+1); %separable kernel 
    k_L=k; k_L(r+2:end)=0;  k_L = k_L/sum(k_L);%half kernel
    k_R=flipud(k_L); 
    m = size(im,1)+2*r; n = size(im,2)+2*r; total = m*n;
    [row, col]=ndgrid(1:m,1:n); 
    offset = row + m*(col-1) - total;
    im = single(im); 
    result = im; 
    d = zeros(m,n,8,'single');  

    [pca_img,~] = img_pca(result,PC) ;
    pca_img = (pca_img-min(pca_img(:)))/(max(pca_img(:))-min(pca_img(:)));

    U = padarray(pca_img,[r,r],'replicate'); 
     %all projection distances   
    kernel_1 = k_L*k_L';
    kernel_1 = kernel_1/sum(kernel_1(:));
    d(:,:,1) = mean(abs(convn(U, kernel_1,'same')-U),3);

    kernel_2 = k_L*k_R'; 
    kernel_2 = kernel_2/sum(kernel_2(:));
    d(:,:,2) = mean(abs(convn(U, kernel_2,'same')-U),3);


    kernel_3 = k_R*k_L'; 
    kernel_3 = kernel_3/sum(kernel_3(:));
    d(:,:,3) = mean(abs(convn(U, kernel_3,'same')-U),3);

    kernel_4 = k_R*k_R'; 
    kernel_4 = kernel_4/sum(kernel_4(:));
    d(:,:,4) = mean(abs(convn(U, kernel_4,'same')-U),3);

    kernel_5 = k_L*k'; 
    kernel_5 = kernel_5/sum(kernel_5(:));
    d(:,:,5) = mean(abs(convn(U, kernel_5,'same')-U),3);

    kernel_6 = k_R*k'; 
    kernel_6 = kernel_6/sum(kernel_6(:));
    d(:,:,6) = mean(abs(convn(U, kernel_6,'same')-U),3);

    kernel_7 = k*k_L'; 
    kernel_7 = kernel_7/sum(kernel_7(:));
    d(:,:,7) = mean(abs(convn(U, kernel_7,'same')-U),3);

    kernel_8 = k*k_R'; 
    kernel_8 = kernel_8/sum(kernel_8(:));
    d(:,:,8) = mean(abs(convn(U, kernel_8,'same')-U),3);

    %find the minimal signed distance
    tmp = abs(d); 
    [~,ind] = min(tmp,[],3);
    temp_ind_old = zeros(m,n);
    previous_diff = 2;
    
    for ch=1:size(im,3)
        recent_changes = zeros(1, 10);
        N = 10;
        dynamic_threshold = 1;
        count = 0;
        for i = 1:1000
        
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
            
            tmp = abs(d); 
            [~,temp_ind] = min(tmp,[],3);
            diff = temp_ind ~= ind;
            temp_diff = sum(diff(:))/(m*n);
            change = abs(previous_diff - temp_diff);
            previous_diff = temp_diff;
            recent_changes(mod(i-1, N) + 1) = change;
            temp_ind_old = temp_ind;
	        if mod(i,N) == 0
                if std(recent_changes) > dynamic_threshold
                    count = count + 1;
                    if count == 3
                        fprintf('Band %d Early stopping at iteration %d\n', ch, i);
                        break;
                    end
                else
                    dynamic_threshold = std(recent_changes);
                end
            end

            index = offset+total*ind;
            dm = d(index); %signed minimal distance
            %update
            U = U + dm; 
            result(:,:,ch) = U(r+1:end-r,r+1:end-r);
        end
    end
end
