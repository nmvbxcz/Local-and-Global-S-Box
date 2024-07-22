function [data] = lgcatsw(img, radius, pc)
    [h,w,c] = size(img);
    local_feature = ls_box(img,radius);
    global_feature = gs_box(img, radius, pc); 
    data = cat(3,local_feature,global_feature);
end
