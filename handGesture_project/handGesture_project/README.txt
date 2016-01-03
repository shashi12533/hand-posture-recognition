-----------------------------------
To get it run:
-----------------------------------

0) We have cropped hand posture images with white ([1 1 1]) background in each folder. Let's say ['A','B','C','D','G','H','I','L','V','Y'] are all in the folder /home/student1/Dropbox/handGesture_project/train

1) Preprocessing and GMM extraction by running the code preprocess_separate_folder_image.m. After this step, you will notice that there are .mat files saved in each posture folder corresponding to each posture image.

2) Now you have 2 options: <1> making similarity matrix out of the database or <2> doing K-fold cross-validation

====================================================================================

<1> Making similarity matrix
1) Run calDiv_matrix.m: This will calculate the similarity matrix of all saples in the database
2) Copy the .mat results to /home/student1/Dropbox/handGesture_project/plotDivMatrixwithIcon
You can create a fancy plot where each row and column is represented by its corresponding image icon.

====================================================================================

<2> Classification
1) Run classification_crossvalid_folder_sweepDkl.m: The code will do K-fold cross validation on the image database and give the confusion matrix and run-time plot.

====================================================================================


preprocess_folder_image.m
This is one of the first codes in this folder. The code does preprocessing cropped hand images:
[1] retrieve filenames  
[2] remove the bottom most 15px from each image
[3] The feature vector contains x, y, and intensity
[4] fit MoG to the i([x,y]) for each of the image


preprocess_single_image.m
Do similar thingas the previous one except that it process on a single image basis.

preprocess_separate_folder_image.m
This code is very similar to preprocess_folder_image.m except that this code is much better organized such that it is able to preprocess images from different posture folders.

classification_using_MAP.m
This code just simply works as minimum-divergence classifier on image by image basis. It does not do k-fold cross-validation.

classification_crossvalid_folder.m
This code do classification using k-fold cross validation. It divides data into k groups, and test one group at a time using minimum divergence classifier. This code compare2 Dcs vs Dkl (stochastic integration), however, it does not sweep all the number of samples when calculating Dkl.

classification_crossvalid_folder_sweepDkl.m
Does everything the same way as classification_crossvalid_folder.m, except that it DOES SWEEP the number of samples for Dkl.

fancyPlot.m
This code plot images icon at the row and column of the similarity matrix. However, one problem is that we cannot make separate colormaps between the matrix and the image icons.

fancyPlot_differentcolormaps_withcolorfreeze.m
Erion tried to fix the problem using a function called "freezeColors.m" in order to freeze the colormap of the matrix and the image icons.

