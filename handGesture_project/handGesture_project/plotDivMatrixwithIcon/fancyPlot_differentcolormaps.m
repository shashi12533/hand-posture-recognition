clear;

%% Fancy plot
load divmatrixwholedataset
symbol = ['A','B','C','D','G','H','I','L','V','Y'];

figure;
C = 11;
R = 11;

% matrix2plot = Dcs_matrix; % Dkl_MC_matrix;
matrix2plot = Dkl_MC_matrix;

% normalize the similarity matrix
matrix2plot = matrix2plot - min(matrix2plot(:),[],1);
matrix2plot = matrix2plot/max(matrix2plot(:),[],1);

cmap1 = colormap('jet');
cmap2 = colormap('gray');
cmap = [cmap1; cmap2];
colormap(cmap);

edge_subplot_ind = [1:C,C+1:C:R*C];
subplot(R,C,setdiff(1:R*C,edge_subplot_ind)); 
imagesc(matrix2plot,[0 2]); 
% % colormap('jet'); % daspect([1 1 1]);
colorbar;
% set(gca,'xtick',[],'ytick',[]); % remove the x,y-tick labels
set(gca,'XTick',[5:10:100]); set(gca,'XTickLabel',symbol');
set(gca,'YTick',[5:10:100]); set(gca,'YTickLabel',symbol');
set(gca,'XAxisLocation','top');

% Column-accross image
% % colormap('gray'); % daspect([1 1 1]);
cnt = 1;
for col = [2:C]
    filename_q = [num2str(cnt)];
    subplot(R,C,col);
    tmpImg = double(imread([filename_q,'.bmp'])) / 255;
    image((tmpImg*64 + 64)); axis off;
    cnt = cnt + 1;
end

% Row-accross image
cnt = 1;
for row = [C+1:C:R*C]
    filename_q = [num2str(cnt)];
    subplot(R,C,row);
    tmpImg = double(imread([filename_q,'.bmp'])) / 255;
    image((tmpImg*64 + 64)); axis off;
    cnt = cnt + 1;
end

% print('-depsc','-r200',['Dcs_matrix_exp1.eps']);
% print('-djpeg','-r200',['Dcs_matrix_exp1.jpg']);