function [oa,aa,kappa,ua,my_map] = hsi_classify(data,gt,nTrEachClass,index)

    [train_data, train_label, test_data, test_label,index_train, index_test, A, U, AA, UU ] =...
            ChooseSample(data,gt,nTrEachClass,index);

    train_data = double(train_data);
    test_data = double(test_data);
    oa = 0;
    aa = 0;
    kappa = 0;
    reg = [1e-6,1e-5,1e-4,1e-3,1e-2,1e-1,1e0,1e1,1e2,1e3,1e4,1e5,1e6];
    beta = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]; 

    [ACC,res] = classifymethod(train_data,train_label,test_data,test_label);
    my_map = zeros(size(data,1),size(data,2));
    my_map(index_train) = train_label;
    my_map(index_test) = res;
    [oa,aa,kappa,ua,~]=confusion(test_label,res);

end