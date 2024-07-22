function [result]=ls_box(im, radius)
    
    r = radius; %the radius of the side window
    k = ones(2*r+1,1)/(2*r+1); %separable kernel 
    k_L=k; k_L(r+2:end)=0; k_L = k_L/sum(k_L); %half kernel
    k_R=flipud(k_L); 
    m = size(im,1)+2*r; n = size(im,2)+2*r; total = m*n;
    [row, col]=ndgrid(1:m,1:n); 
    offset = row + m*(col-1) - total;
    im = single(im); 
    result = im; 
    stop_i = zeros(size(im,3),1);
    for ch=1:size(im,3)
        d = zeros(m,n,8,'single'); 
        N = 10;
        recent_changes = zeros(1, N);
        dynamic_threshold = 1;
        i = 0;
        old_ind = zeros(m,n);
        previous_diff = 2;
        count = 0;
        while true
            i = i+1;
            U = padarray(result(:,:,ch),[r,r],'replicate'); 
        
            %all projection distances
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
            diff = ind ~= old_ind;
            temp_diff = sum(diff(:))/(m*n);
            change = abs(previous_diff -  temp_diff);
            previous_diff = temp_diff;
            recent_changes(mod(i-1, N) + 1) = change;
	        if mod(i,N) == 0
                if std(recent_changes) > dynamic_threshold
                    count = count + 1;
                    if count == 3
                        fprintf('Band %d Early stopping at iteration %d\n', ch, i);
                        stop_i(ch) = i;
                        break;
                    end
                else
                    dynamic_threshold = std(recent_changes);
                end
            end
            
            old_ind = ind;
            index = offset+total*ind;
            dm = d(index); %signed minimal distance
            %update
            U = U + dm; 
            result(:,:,ch) = U(r+1:end-r,r+1:end-r);
        end
    end
    % figure;
    % plot(iter_process);
    save('original_sw_box.mat','result');
end
