function [data] = lgcatsw(img,radius,iter)
    [h,w,c] = size(img);
    local_feature = ls_box(img,radius,iter);
    global_feature = gs_box(img, radius, iter); 
    if c<300
    	data = cat(3,local_feature,global_feature);
    else
        data = 0.8*local_feature+0.2*global_feature;
    end
end