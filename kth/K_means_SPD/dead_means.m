function [new_cluster_list new_n_points_cl] = dead_means(cluster_list, n_points_cl)


new_cluster_list = cluster_list;
new_n_points_cl = n_points_cl;

idx_clusters_no_points = find( n_points_cl==0 );
[sorted_n_pts idxs] = sort (n_points_cl,'descend');

for i=1: length(idx_clusters_no_points)
    
    dead_mean_idx = idx_clusters_no_points(i);

    n_elem = sorted_n_pts(i);
    new_size_1 = floor(n_elem/2);
    new_size_2 = n_elem - new_size_1;
    
    max_mean_idx = idxs (i);
    k = max_mean_idx;
    one_cluster_list = {cluster_list{:,k}};
    
    
    new_list_1 = cell( length(cluster_list),1 );
    new_list_2 = cell( length(cluster_list),1 );
    
    new_list_1(1:new_size_1)  =  {one_cluster_list{1:new_size_1}  }';
    new_list_2(1:new_size_2) =   {one_cluster_list{1,new_size_1+1:n_elem}  };
    
    new_cluster_list(:,dead_mean_idx) = new_list_1;
    new_n_points_cl(dead_mean_idx) = new_size_1;
    
    new_cluster_list(:,k) = new_list_2;
    new_n_points_cl(k) = new_size_2;
    
end

