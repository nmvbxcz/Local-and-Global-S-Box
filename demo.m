function [] = demo(DataSetName, classifier, number, pc)
    addpath(genpath('./libsvm-3.24'));
    addpath(genpath('./common'));
    poolobj = gcp('nocreate');
    switch classifier
        case 'raw'
            [img,gt] = get_data(DataSetName);
            data = img./max(img(:));
            % data = img_pca(data, 20); 
            massage = 'raw';  

        case 'lgs_box' 
            [img,gt] = get_data(DataSetName);
            img = img./max(img(:));
            switch DataSetName
                case 'Indianpines'
                    radius = 3;
                case 'Salinas' 
                    radius = 5;
                case 'PaviaU' 
                    radius = 3;
                case 'XuZhou' 
                    radius = 2;
                case 'Houston2013' 
                    radius = 2;
                case 'Houston2018' 
                    radius = 3;
            end
            data = lgcatsw(img,radius,pc); 
	    massage = 'raw';  
        otherwise
            error('Unknown classifier requested.');
    end

    oa = zeros(1,10);
    aa = zeros(1,10);
    kappa = zeros(1,10);
    ua = zeros(10,max(gt(:)));
    my_map = zeros(10,size(data,1),size(data,2));
    dex = [1,11,26,33,52,58,85,104,111,121];
    for i = 1:size(number,2)

        parfor index=1:10
                [oa(index),aa(index),kappa(index),ua(index,:),my_map(index,:,:)] = hsi_classify(data,gt,number(i),dex(index));
        end
	
        oa_mean = roundn(mean(oa),-4)
        oa_std = roundn(std(oa),-4);
        aa_mean = roundn(mean(aa),-4);
        aa_std = roundn(std(aa),-4);
        kappa_mean = roundn(mean(kappa),-4);
        kappa_std = roundn(std(kappa),-4);
    end
end
