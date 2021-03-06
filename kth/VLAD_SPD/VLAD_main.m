clear all
clc

%Wanda
%addpath('/home/johanna/toolbox/libsvm-3.20/matlab')
%path  = '~/codes/codes-git/paper2016a/trunk/kth/';


%Mounted Wanda @ UQ
path = '/home/johanna-uq/WANDA_DRIVE/';
addpath('/home/johanna-uq/Toolbox/libsvm-320/matlab')


dbstop error;
%dbstop in vec_TestingSet at 10
%dbstop in vec_Clusters at 5
%dbstop in vlda_svm_train at 35
%% 
K = 256;
folder_name_cl = 'clustersSPD_15-Feb-2016_K_256';

%% 
show_you = strcat('Folder: ', folder_name_cl);
disp(show_you);

dim = 14;
actions = importdata('actionNames.txt');
all_people = importdata('people_list.txt');
scale_factor = 1;
shift = 0;

%%
load_sub_path =strcat('overlapped_covariances/Covs/sc1/scale', int2str(scale_factor), '-shift',  int2str(shift));


n_actions = length(actions);
people_test =   [ 2 3 5 6 7  8  9  10 22 ];
people_train = [ 1 4 11 12 13 14 15 16 17 18 19 20 21 23 24 25];

%pac : people, action, cells
[list_pac_tr total_num_covs_tr] = get_list( n_actions, path, all_people, actions, load_sub_path, people_train);
[list_pac_te total_num_covs_te] = get_list( n_actions, path, all_people, actions, load_sub_path, people_test);

%vec_Clusters(path, folder_name_cl, K, dim);
%vec_TestingSet (path, load_sub_path, list_pac_te, dim );
% vec_TrainingSet (path, load_sub_path, list_pac_tr, dim );

%% Getting descriptors for Training Set

 for i=1:length(list_pac_tr)
     one_video_pac = {list_pac_tr{i,:}};
     [cluster_list_one_video n_points_cl] = assign_points(one_video_pac, K,path, load_sub_path, folder_name_cl);
     disp('Get VLAD descriptors')
     get_vlad_descriptors (one_video_pac, cluster_list_one_video, n_points_cl, dim, K);
 end


%% Getting descriptors for Testing Set

% for i=1:length(list_pac_te)
%     one_video_pac = {list_pac_te{i,:}};
%     [cluster_list_one_video n_points_cl] = assign_points(one_video_pac, K,path, load_sub_path, folder_name_cl);
%     disp('Get VLAD descriptors')
%     get_vlad_descriptors (one_video_pac, cluster_list_one_video, n_points_cl, dim, K);
% end

%% Train and Test with SVM

%vlda_svm_train(K, dim, list_pac_tr);
%[predicted_label, accuracy, prob_estimates] = vlda_svm_test(K, dim, list_pac_te);


