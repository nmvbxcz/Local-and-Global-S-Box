function [data] = lgcatsw(img,radius,iter)
    [h,w,c] = size(img);
    local_feature = ls_box(img,radius,iter);
    global_feature = gs_box(img, radius, iter); 
    data = cat(3,local_feature,global_feature);
end
