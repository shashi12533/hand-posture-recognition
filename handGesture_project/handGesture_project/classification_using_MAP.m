% classification



clear
clc
close all

% addpath to Dcs folder
addpath('./cal_div_KL_CS');


%% ------ retrieve the image filename -----
for symbol_folder = ['A','B','C','V']
    dirName = ['./DataBot/cropped/',symbol_folder]; % dir of images
    % --- list all the files in the directory
    fileList = fn_getAllFiles(dirName);
    image_list = cell(length(fileList),1);
    for i = 1:length(fileList)
        [pathstr, name, ext] = fileparts(fileList{i});
        image_list{i} = name;
    end
    addpath(dirName); % path of image
    
    
    % ==== Training =====
    % give a set of training image
    % Make a model of A B C and V
    n_img = size(image_list,1);
    f_vec_accum = [];
    for img_q = 1:n_img % accross row
        filename_q = image_list{img_q};
        % load the data
        load([filename_q,'_data']);
        f_vec_accum = [f_vec_accum; new_feat_vector];
    end
    
    % fit GMM to it
    figure;
    C = 10; % number of class
    options = statset('Display','final');
    obj = gmdistribution.fit(f_vec_accum(:,1:2),C,'Options',options,'Replicates',5);
    h = ezcontour(@(x,y)pdf(obj,[x y]),[0 1],[0 1]);
    % plot the GMM
    hold on;
    for c = 1:C
        mu = obj.mu(c,:)';
        plot(mu(1),mu(2),'k*','MarkerSize',15);
    end
    
    % convert to Bot's cell format
    gmmDist = fn_convert_gmmObj2Cellformat(obj);
    
    % save
    save(['training_model_model',symbol_folder],'obj','gmmDist','f_vec_accum','C');
    
end


%% === Testing ====
% give a set of test images
% classify each of the image according to MAP? k-nn?
% ------ retrieve the image filename -----

dirName = './DataBot/cropped/test'; % dir of images
% --- list all the files in the directory
fileList = fn_getAllFiles(dirName);
image_list = cell(length(fileList),1);
for i = 1:length(fileList)
    [pathstr, name, ext] = fileparts(fileList{i});
    image_list{i} = name;
end

n_img = size(image_list,1);

Dcs_matrix = zeros(n_img,n_img); 
Dkl_MC_matrix = zeros(n_img,n_img); 

cnt_row = 1;
cnt_col = 1;

for img_q = 1:n_img % accross row
    % load the data
    filename_q = image_list{img_q};
    load([filename_q,'_data']); qDist = gmmDist;
    cnt_col = 1;
    for symbol_folder = ['A','B','C','V'] % accross column
        % load the data
        load(['training_model_model',symbol_folder]); pDist = gmmDist;

        % Calculate Cauchy Schwarz divergence using our method
        tic;
        Dcs = CSDivGMM(qDist,pDist);
        disp(['Dcs = ',num2str(Dcs),'   runtime: ',num2str(toc),' sec']);
        
        % Calculate GMM with stochastic integration
        Ns = 100;
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

% Easy plot
figure; imagesc(Dcs_matrix); 
title('D_{CS}'); daspect([1 1 1]); xlabel('dist_p'); ylabel('dist_q'); colormap('gray'); colorbar;
print('-depsc','-r200',['Dcs_matrix_exp1.eps']);
print('-djpeg','-r200',['Dcs_matrix_exp1.jpg']);

figure; imagesc(Dkl_MC_matrix); 
title('D_{KL}'); daspect([1 1 1]); xlabel('dist_p'); ylabel('dist_q'); colormap('gray'); colorbar;
print('-depsc','-r200',['Dkl_MC_matrix_exp1.eps']);
print('-djpeg','-r200',['Dkl_MC_matrix_exp1.jpg']);

% % Fancy plot
% figure;
% edge_subplot_ind = [1:n_img+1,n_img+2:n_img+1:(n_img+1)^2];
% subplot(n_img+1,n_img+1,setdiff(1:(n_img+1)^2,edge_subplot_ind)); imagesc(Dcs_matrix); 
% set(gca,'xtick',[],'ytick',[]);
% % daspect([1 1 1]);
% colormap('gray'); colorbar; caxis([0 1]);
% 
% % Column-accross image
% cnt = 1;
% for col = [2:n_img+1]
%     filename_q = image_list{cnt};
%     subplot(n_img+1,n_img+1,col);
%     imshow([filename_q,'.bmp']);
%     cnt = cnt + 1;
% end
% 
% % Row-accross image
% cnt = 1;
% for row = [n_img+2:n_img+1:(n_img+1)^2]
%     filename_q = image_list{cnt};
%     subplot(n_img+1,n_img+1,row);
%     imshow([filename_q,'.bmp']);
%     cnt = cnt + 1;
% end
%     
% print('-depsc','-r200',['Dcs_matrix_exp1.eps']);
% print('-djpeg','-r200',['Dcs_matrix_exp1.jpg']);
