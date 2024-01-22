function [] = filtering(DataSetName, classifier, number)
    addpath(genpath('./libsvm-3.24'));
    addpath(genpath('./common'));

    poolobj = gcp('nocreate');
    tic;


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
            data = lgcatsw(img,radius,iter); 
	    massage = 'raw';  
        otherwise
            error('Unknown classifier requested.');
    end

  	if(~exist('massage','var'))
  	    massage = '';  % 如果未出现该变量，则对其进行赋值
  	end

	

    result_name = 'all_result.txt';
    fid = fopen(result_name,'a+');
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
        
        toc;
        disp(['运行时间: ',num2str(toc)]);
        oa_mean = roundn(mean(oa),-4);
        oa_std = roundn(std(oa),-4);
        aa_mean = roundn(mean(aa),-4);
        aa_std = roundn(std(aa),-4);
        kappa_mean = roundn(mean(kappa),-4);
        kappa_std = roundn(std(kappa),-4);
        fprintf(fid,'%s %s %d  iter: %d   %g ± %g___%g ± %g___%g ± %g %s\n', DataSetName, classifier,number(i),iter,oa_mean*100,oa_std*100,aa_mean*100,aa_std*100,kappa_mean*100,kappa_std*100,massage);
        fprintf('%s %s %d      %g ± %g___%g ± %g___%g ± %g\n', DataSetName, classifier,number(i),oa_mean*100,oa_std*100,aa_mean*100,aa_std*100,kappa_mean*100,kappa_std*100);
        for j = 1:10
            file_name = char(strcat(DataSetName,'_',classifier,'_',int2str(number(i)),'_',mat2str(oa(j)),'_',massage));
            Label2color(reshape(my_map(j,:,:),size(data,1),size(data,2)),DataSetName,file_name);
        end
  
    end
    fclose(fid);
    % delete(gcp('nocreate'));
    oa
    aa
    kappa
    ua
end
