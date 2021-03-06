% In this code, we do the following
% 1) Load the hand image, make a binary image
% 2) cut away the bottom part of the image
% 3) Using GMM to fit the x y I. Note that this is not traditional GMM,
% instead we sample the point from the original image

% This code preprocess the data and put them back to each image's original
% folder

clear
close all
clc

%% ==== USER-Define ======
n_base = 10; % number of sample per intensity unit
C = 10; % number of class
EM_rep = 1;
rm_neck = 15;
ext_of_interest = '.bmp';
%% ------ retrieve the image filename -----

for symbol_folder = ['A','B','C','D']; % ['A','B','C','D','G','H','I','L','V','Y']
    dirName = ['./train/',symbol_folder]; % dir of images
    addpath(dirName); % path of image
    % --- list all the files in the directory
    fileList = fn_getAllFiles(dirName);
    image_list = cell(length(fileList),1);
    % Get all the file names in the directory
    cnt_ext = 1; % counter for extension
    for i = 1:length(fileList)
        [pathstr, name, ext] = fileparts(fileList{i});
        if strcmp(ext_of_interest,ext)
        image_list{cnt_ext} = name;
        cnt_ext = cnt_ext + 1;
        end
    end
    image_list = image_list(1:cnt_ext-1,1);
    
    % --- preprocessing -----
    for img = 1:size(image_list,1);
        filename = image_list{img};
        I_gray = imread([filename,ext_of_interest]);
        
        % normalize the intensity to 0-1
        I_gray = double(I_gray)/255;
        I_gray(I_gray == 1) = 0;
        
        % make a binary image oh hand
        I_bin = I_gray;
        I_bin(I_gray ~= 0) = 1;
        
        % plot the histogram accross the row
        hist_row = sum(I_bin,2);
        % figure; plot(hist_row,'b*-');
        
        % trip the "neck" of the hand
        I_gray = I_gray(1:end-rm_neck,:);
        I_bin = I_bin(1:end-rm_neck,:);
        % figure;
        % subplot(1, 2, 1); imagesc(I_gray); daspect([1 1 1]); colorbar;
        % subplot(1, 2, 2); imagesc(I_bin); daspect([1 1 1]); colorbar;
        
        % normalize the pixel locations
        [n_row, n_col] = size(I_gray);
        [pixel_loc_col,pixel_loc_row] = meshgrid(1:n_col, 1:n_row);
        pixel_loc_norm_col = pixel_loc_col/n_col;
        pixel_loc_norm_row = pixel_loc_row/n_row;
        % figure; imagesc(pixel_loc_norm_col);
        % figure; imagesc(pixel_loc_norm_row);
        
        % the feature vector col, row, I
        feat_vector = [pixel_loc_norm_col(:), pixel_loc_norm_row(:), I_gray(:)];
        feat_vector = feat_vector(feat_vector(:,3)~=0,:);
%         figure; plot3(feat_vector(:,1), feat_vector(:,2), feat_vector(:,3), 'b*');
        
        % % fit GMM to it === but this is not what we want
        % C = 5;
        % options = statset('Display','final');
        % obj = gmdistribution.fit(feat_vector,C,'Options',options);
        %
        % % plot the GMM
        % hold on;
        % for c = 1:C
        %     mu = obj.mu(c,:)';
        %     plot3(mu(1),mu(2),mu(3),'r*','MarkerSize',12);
        % end
        
        % sample from the image
        n_I = ceil(feat_vector(:,3)*n_base);
        new_feat_vector = []; % the new features
        
        for i = 1:size(n_I)
            for j = 1:n_I(i)
                new_feat_vector = [new_feat_vector; feat_vector(i,:)];
            end
        end
        
        % fit GMM to it
        
        options = statset('Display','final');
        obj = gmdistribution.fit(new_feat_vector(:,1:2),C,'Options',options,'Replicates',EM_rep);
%         figure; h = ezcontour(@(x,y)pdf(obj,[x y]),[0 1],[0 1]);
%         % plot the GMM
%         hold on;
%         for c = 1:C
%             mu = obj.mu(c,:)';
%             plot(mu(1),mu(2),'k*','MarkerSize',15);
%         end
        
        % convert to Bot's cell format
        gmmDist = fn_convert_gmmObj2Cellformat(obj);
        
        % save
        save([filename,'_data'],'obj','gmmDist','new_feat_vector','feat_vector','I_gray','I_bin','C','n_base');
        movefile([filename,'_data.mat'],dirName); % move the file to the original directory
        
    end

    rmpath(dirName); % remove path of image
end











