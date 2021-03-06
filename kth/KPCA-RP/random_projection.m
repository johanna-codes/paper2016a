function  random_projection(list_pac, r_points, path, load_sub_path, dim)
%r_points == length(list_pac)


%Stein Divergence Kernel
beta  = 1;
SD_Kernel = @(X,Y,beta) exp( -beta*( log(det( 0.5*(X + Y) )) - 0.5*log(det(X*Y )) ) );


X_train = zeros( dim, dim, r_points);
    

matlabpool(8) 


for i=1: r_points    
   
    
    person =  list_pac{i,1};
    action =  list_pac{i,2};
    c = list_pac{i,3};
    
    
    load_cov =  strcat( path, load_sub_path, '/Cov_', person, '_', action,  '_segm', num2str(c) , '.h5' );
    S = char(load_cov);
    data_one_cov= hdf5info(S);
    cov = hdf5read(data_one_cov.GroupHierarchy.Datasets(1));
    X_train(:,:,i) = cov;
end
matlabpool close


Ks = compute_kernel(X_train,X_train, SD_Kernel, beta);
[U,S,V] = svd(Ks); % use matrix V 

%To project each point, it means to project each covariance matrix.
save_rp_data = strcat('random_projection_data_dim',  num2str(r_points));
save(char(save_rp_data),'V', 'Ks', 'X_train');


