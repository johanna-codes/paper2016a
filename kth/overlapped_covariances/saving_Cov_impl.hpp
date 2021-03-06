inline
OverlappedCovs_kth::OverlappedCovs_kth( const std::string in_path,
				    const std::string in_actionNames,  
				    const float in_scale_factor, 
				    const int in_shift
				    
)
:path(in_path), actionNames(in_actionNames), scale_factor(in_scale_factor), shift(in_shift)
{
  actions.load( actionNames );  
}



///****************************************************************************************
///****************************************************************************************
//One covariance matrix per video

inline
void
OverlappedCovs_kth::calculate_covariances( field<string> in_all_people, int  in_dim  )
{
  all_people = in_all_people;
  dim = in_dim;
  int n_actions = actions.n_rows;
  int n_peo =  all_people.n_rows;
  //all_people.print("people");
  
  
  field <std::string> parallel_names(n_peo*n_actions,4); 
  int k =0;
  
  
  for (int pe = 0; pe< n_peo; ++pe)
  {
    for (int act=0; act<n_actions; ++act)
    {
      
      
      std::stringstream load_folder;
      std::stringstream load_feat_video_i;
      std::stringstream load_labels_video_i;
      
      // Shifting both
      load_folder << path << "scale" << scale_factor << "-shift"<< shift ;
      //load_folder << path <<"kth-features_dim" << dim <<  "/sc" << sc << "/scale" << scale_factor << "-shift"<< shift ;
      
      
      //      If you want to use. You have to add the  flag_shift in this method. 
      //	if (flag_shift) //Horizontal Shift
      //       {
	// 	load_folder << path << "/kth-features_dim" << dim <<  "_openMP/sc" << sc << "/scale" << scale_factor << "-horshift"<< shift ;
      //       
      //       }
      //       
      //       if (!flag_shift)//Vertical Shift
      //       {
	// 	load_folder << path << "./kth-features_dim" << dim <<  "_openMP/sc" << sc << "/scale" << scale_factor << "-vershift"<< shift ;
      // 	
      // 	
      //       }
      //       
      
      
      
      load_feat_video_i << load_folder.str() << "/" << all_people (pe) << "_" << actions(act) << "_dim" << dim  << ".h5";
      load_labels_video_i << load_folder.str() << "/lab_" << all_people (pe) << "_" << actions(act) << "_dim" << dim  << ".h5";
      
      
      std::ostringstream ss1;
      std::ostringstream ss2;
      ss1 << pe;
      ss2 << act;
      
      
      parallel_names(k,0) = load_feat_video_i.str();
      parallel_names(k,1) = load_labels_video_i.str();
      parallel_names(k,2) = ss1.str();
      parallel_names(k,3) = ss2.str();
      k++;
      
    }
  }
  
  
  omp_set_num_threads(1); //Use only 8 processors
  
  
  
  #pragma omp parallel for 
  for (int k = 0; k< parallel_names.n_rows; ++k)
  {
    std::string load_feat_video_i   = parallel_names(k,0);
    std::string load_labels_video_i = parallel_names(k,1);
    
    int pe   = atoi( parallel_names(k,2).c_str() );
    int act  = atoi( parallel_names(k,3).c_str() );
    
     cout << all_people (pe) << "_" << actions(act) << endl;
    one_video_multiple_covs(load_feat_video_i, load_labels_video_i, pe, act );

  }

  
  
}


inline
void
OverlappedCovs_kth::one_video_multiple_covs( std::string load_feat_video_i, std::string load_labels_video_i, int pe, int act )
{
  //   #pragma omp critical
  //   {
    //   cout << load_feat_video_i << endl;
    //   getchar();
    //   }
    
    mat mat_features_video_i;    
    mat_features_video_i.load( load_feat_video_i, hdf5_binary );  
    
    vec labels;
    labels.load( load_labels_video_i, hdf5_binary );
    
    int n_vec = mat_features_video_i.n_cols;
    
    
    std::stringstream save_folder;
    
    //Shifting both
    save_folder << "./Covs/sc1" <<  "/scale" << scale_factor << "-shift"<< shift ;
    
    
    {
      //      If you want to use. You have to add the  flag_shift in this method. 
      //	   if (flag_shift) //Horizontal Shift
      //       {
	// 
	// 	save_folder << "./kth-one-CovsMeans-mat/sc" << sc << "/scale" << scale_factor <<  "-horshift"<< shift ;
	// 	
	//       }
	//       
	//       if (!flag_shift)//Vertical Shift
	//       {
	  // 	 save_folder << "./kth-one-CovsMeans-mat/sc" << sc << "/scale" << scale_factor << "-vershift"<< shift ;
	  //       }
	  //       
    }   
    
    
    
    int seg_length = 5;
    int num_frames;
    
    int length_lab = labels.n_elem;
    num_frames = labels(length_lab-1);
    
    //cout << labels( 0 ) << " ";
    //cout << num_frames << " " << endl;
    
    int num_covs = 0;
    mat seg_vec;
    
    
     for (int i=2; i<=num_frames-seg_length; ++i)
    {
      
      running_stat_vec<rowvec> stat_seg(true);
       
       for (int j=i; j<i+seg_length; ++j )
       {
	 
	 uvec q1 = find(labels == j);
	 //cout << q1.n_elem << endl;
	 seg_vec = mat_features_video_i.cols( q1 );
	 //cout << seg_vec.n_cols << " - " << seg_vec.n_rows << endl;
	 
	 for (int l=0; l<seg_vec.n_cols; ++l)
	 {
	   //cout << l << " ";
	   vec sample = seg_vec.col(l); 
	   stat_seg (sample);
	   
	}
	 
      }
      
     
      //By manual inspection, If the segment contains 
      //a reduced number of pixels, then discard it
     
      if (stat_seg.count() > 100 )  {
      
      
      num_covs++;
      std::stringstream save_Covs;
      save_Covs << save_folder.str() << "/Cov_" <<  all_people (pe) << "_" << actions(act) << "_segm" << num_covs <<  ".h5";
      mat seg_cov= stat_seg.cov();
      
      seg_cov = mehrtash_suggestion( seg_cov );
      
      //cout << save_Covs.str() << endl; 
      seg_cov.save(  save_Covs.str(), hdf5_binary ); 
      }
      else
      {
	 //cout << stat_seg.count() << " " ;
      }
    	
     }
     
     
     //cout << endl;
     
    
    //cout << num_covs << endl;
    vec vecNumCovs;
    
    vecNumCovs << num_covs << endr;
    
    std::stringstream save_vecNumCovs;
    save_vecNumCovs << save_folder.str() << "/NumCov_" <<  all_people (pe) << "_" << actions(act) <<  ".dat";
    
    vecNumCovs.save( save_vecNumCovs.str(), raw_ascii ) ; 
    //getchar();
     
    
    
}



inline
mat
OverlappedCovs_kth::mehrtash_suggestion(mat cov_i)
{
  //Following Mehrtash suggestions as per email dated June26th 2014
  mat new_covi;
  
  double THRESH = 0.000001;
  new_covi = 0.5*(cov_i + cov_i.t());
  vec D;
  mat V;
  eig_sym(D, V, new_covi);
  uvec q1 = find(D < THRESH);
  
  
  if (q1.n_elem>0)
  {
    for (uword pos = 0; pos < q1.n_elem; ++pos)
    {
      D( q1(pos) ) = THRESH;
      
    }
    
    new_covi = V*diagmat(D)*V.t();  
    
  }  
  
  return new_covi;
    //end suggestions
}
