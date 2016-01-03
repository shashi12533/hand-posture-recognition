% This code calculate the divergence matrix from array of images in the
% data set and plot a fancy plot.

clear
clc
close all

% addpath to Dcs folder
addpath('./cal_div_KL_CS');

%% User define
Ns = 100; % number of samples for Dkl stochastic Integration
C = 10; % number of components for GMM
ext_of_interest = '.bmp';
EM_rep = 1;
M = 2; % M-fold cross validation
symbol = ['A','B','C']; % ['A','V']; the name of the folder. Note that the order of folder is corresponding to the # 1, 2, 3, 4
n_symbol = length(symbol);
%% ------ retrieve the image filename -----
image_list = [];
class_groundtruth = [];
cnt_class = 1;
for symbol_folder = symbol
    dirName = ['./train/',symbol_folder]; % dir of images
    addpath(dirName); % path of image
    % --- list all the files in the directory
    fileList = fn_getAllFiles(dirName);
    image_list_tmp = cell(length(fileList),1);
    cnt_ext = 1; % counter for extension
    for i = 1:length(fileList)
        [pathstr, name, ext] = fileparts(fileList{i});
        if strcmp(ext_of_interest,ext)
            image_list_tmp{cnt_ext} = name;
            cnt_ext = cnt_ext + 1;
        end
    end
    image_list_tmp = image_list_tmp(1:cnt_ext-1,1);
    image_list = [image_list;image_list_tmp];
    class_groundtruth = [class_groundtruth; cnt_class*ones(cnt_ext-1,1)];
    cnt_class = cnt_class + 1;
end

n_img = size(image_list,1);
% -- M-fold cross-validation ---
x_valid = zeros(n_img,1);
for i = 1:n_img
    tmp = randperm(M);
    x_valid(i) = tmp(1);
end

%% Do the training and testing with M-fold cross validation

acc_confusion_matrix_Dcs = zeros(n_symbol,n_symbol);
acc_confusion_matrix_Dkl = zeros(n_symbol,n_symbol);

for m = 1:M
    % test image index
    test_image_list = image_list(x_valid==m,1);
    test_class_groundtruth = class_groundtruth(x_valid==m,1);
    % train image index
    train_image_list = image_list(x_valid~=m,1);
    train_class_groundtruth = class_groundtruth(x_valid~=m,1);
    % make model for each type
    for model = 1:n_symbol % [A, B, C, V]
        
        % ==== Training =====
        % give a set of training image
        % Make a model of A B C and V
        train_per_model = train_image_list(train_class_groundtruth == model);
        n_img_permodel = size(train_per_model,1);
        f_vec_accum = [];
        for img_q = 1:n_img_permodel % accross row
            filename_q = train_per_model{img_q};
            % load the data
            load([filename_q,'_data']);
            f_vec_accum = [f_vec_accum; new_feat_vector];
        end
        
        % fit GMM to it

        options = statset('Display','final');
        obj = gmdistribution.fit(f_vec_accum(:,1:2),C,'Options',options,'Replicates',EM_rep);
%         figure;
%         h = ezcontour(@(x,y)pdf(obj,[x y]),[0 1],[0 1]);
%         % plot the GMM
%         hold on;
%         for c = 1:C
%             mu = obj.mu(c,:)';
%             plot(mu(1),mu(2),'k*','MarkerSize',15);
%         end
        
        % convert to Bot's cell format
        gmmDist = fn_convert_gmmObj2Cellformat(obj);
        
        % save
        save(['training_model',num2str(model)],'obj','gmmDist','f_vec_accum','C');
        movefile(['training_model',num2str(model),'.mat'],['./train']);
    end
    
    % ==== TEST ======
    addpath(['./train']);
    n_img_test = size(test_image_list,1);
    
    Dcs_matrix = zeros(n_img_test,n_symbol);
    Dkl_MC_matrix = zeros(n_img_test,n_symbol);
    
    cnt_row = 1;
    cnt_col = 1;
    
    for img_q = 1:n_img_test % accross row
        % load the data
        filename_q = test_image_list{img_q};
        load([filename_q,'_data']); qDist = gmmDist;
        cnt_col = 1;
        for model = 1:n_symbol % accross column
            % load the data
            load(['training_model',num2str(model)]); pDist = gmmDist;
            
            % Calculate Cauchy Schwarz divergence using our method
            tic;
            Dcs = CSDivGMM(qDist,pDist);
            disp(['Dcs = ',num2str(Dcs),'   runtime: ',num2str(toc),' sec']);
            
            % Calculate GMM with stochastic integration
            tic;
            Dkl_MC = KLDivMCGMM(qDist,pDist,Ns);
            disp(['Dkl_MC = ',num2str(Dkl_MC),'   runtime: ',num2str(toc),' sec']);
            
            % put them in a matrix
            Dcs_matrix(cnt_row,cnt_col) = Dcs;
            Dkl_MC_matrix(cnt_row,cnt_col) = Dkl_MC;
            
            cnt_col = cnt_col+1;
        end
        cnt_row = cnt_row+1;
    end
    
    % classification accuracy
    [minV, Dcs_class_MAP] = min(Dcs_matrix,[],2);
    [minV, Dkl_class_MAP] = min(Dkl_MC_matrix,[],2);
    
    confusion_matrix_Dcs = zeros(n_symbol,n_symbol);
    confusion_matrix_Dkl = zeros(n_symbol,n_symbol);
    for j = 1:n_img_test
        confusion_matrix_Dcs(Dcs_class_MAP(j),test_class_groundtruth(j)) = confusion_matrix_Dcs(Dcs_class_MAP(j),test_class_groundtruth(j)) + 1;
        confusion_matrix_Dkl(Dcs_class_MAP(j),test_class_groundtruth(j)) = confusion_matrix_Dkl(Dcs_class_MAP(j),test_class_groundtruth(j)) + 1;
    end
        
    % accumulated confusion
    acc_confusion_matrix_Dcs = acc_confusion_matrix_Dcs + confusion_matrix_Dcs;
    acc_confusion_matrix_Dkl = acc_confusion_matrix_Dkl + confusion_matrix_Dkl;
    
%     % ==== Easy plot =====
%     figure; imagesc(Dcs_matrix);
%     title('D_{CS}'); daspect([1 1 1]); xlabel('dist_p'); ylabel('dist_q'); colormap('gray'); colorbar;
%     print('-depsc','-r200',['Dcs_matrix_x_valid',num2str(m),'.eps']);
%     print('-djpeg','-r200',['Dcs_matrix_x_valid',num2str(m),'.jpg']);
%     
%     figure; imagesc(Dkl_MC_matrix);
%     title('D_{KL}'); daspect([1 1 1]); xlabel('dist_p'); ylabel('dist_q'); colormap('gray'); colorbar;
%     print('-depsc','-r200',['Dkl_MC_matrix_x_valid',num2str(m),'.eps']);
%     print('-djpeg','-r200',['Dkl_MC_matrix_x_valid',num2str(m),'.jpg']);
end

% plot the accumulation confusion matrix
figure; imagesc(acc_confusion_matrix_Dcs); xlabel('class groundtruth'); ylabel('class detected'); title('D_{CS}');
figure; imagesc(acc_confusion_matrix_Dkl); xlabel('class groundtruth'); ylabel('class detected'); title('D_{KL}');

