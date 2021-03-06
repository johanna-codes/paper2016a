function project_points (list_pac, path, load_sub_path,r_points, folder_name, kernel_type)

%matlabpool(8) 

if strcmp( kernel_type, 'stein')
    
    load_rp_data = strcat('random_projection_data_dim',  num2str(r_points));
    load( char(load_rp_data)); % Loading V & X_train. See random_projection
    
    %Stein Divergence Kernel
    beta  = 1;
    SD_Kernel = @(X,Y,beta) exp( -beta*( log(det( 0.5*(X + Y) )) - 0.5*log(det(X*Y )) ) );
    
    for i=1: length(list_pac)
        
        person =  list_pac{i,1};
        action =  list_pac{i,2};
        num_covs = list_pac{i,3};
        %show_you = strcat(person,  '_', action);
        %disp(show_you);
        
        %parfor c  = 1:num_covs
        for c = 1:num_covs
            load_cov =  strcat( path, load_sub_path, '/Cov_', person, '_', action,  '_segm', num2str(c) , '.h5' );
            S = char(load_cov);
            data_one_cov= hdf5info(S);
            Xi = hdf5read(data_one_cov.GroupHierarchy.Datasets(1)); % One covariance point
            %size(X_train)
            K_hat = compute_kernel(Xi,X_train, SD_Kernel, beta);
            x_i = K_hat*V;
            
            %pp = projected point
            save_pp =  strcat('./', folder_name, '/pp_', person, '_', action,  '_segm', num2str(c) , '.h5' );
            hdf5write(char(save_pp), '/dataset1', x_i);
            
        end
    end
    

end


if strcmp( kernel_type, 'poly')
    
    load_rp_data = strcat('PolyKernelrandom_projection_data_dim',  num2str(r_points));
    load( char(load_rp_data), 'V',  'X_train'); % Loading V & X_train. See random_projection
    
   %Polynomial Kernel - See mlsda paper on Manifolds
   best_n = 12;
   gamma = 1/best_n;
   LED_POLY_KERNEL = @(X,Y,gamma,best_n)( ( gamma*( trace(logm(X)'*logm(Y)) ) )^best_n );
    
    for i=1: length(list_pac)
        
        person =  list_pac{i,1};
        action =  list_pac{i,2};
        num_covs = list_pac{i,3};
        %show_you = strcat(person,  '_', action);
        %disp(show_you);
        
        %parfor c  = 1:num_covs
        for c = 1:num_covs
            load_cov =  strcat( path, load_sub_path, '/Cov_', person, '_', action,  '_segm', num2str(c) , '.h5' );
            S = char(load_cov);
            data_one_cov= hdf5info(S);
            Xi = hdf5read(data_one_cov.GroupHierarchy.Datasets(1)); % One covariance point
            %size(X_train)
            K_hat = compute_proj_kernel(Xi,X_train, LED_POLY_KERNEL, gamma, best_n);
            x_i = K_hat*V;
            
            %pp = projected point
            save_pp =  strcat('./', folder_name, '/pp_', person, '_', action,  '_segm', num2str(c) , '.h5' );
            hdf5write(char(save_pp), '/dataset1', x_i);
            
        end
    end
    

end

%matlabpool close





