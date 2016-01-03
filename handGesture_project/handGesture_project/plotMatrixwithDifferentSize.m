I=rand(10,10,30);
II=zeros(size(I,1),size(I,2));



figure,
R=5; C=4; % pick the rows and columns

%we are going to leave top corner blank
CH=sub2ind([C R],2:C,ones(1,C-1));
RH=sub2ind([C R],ones(1,R-1),2:R);


%Here is where we plot little guys
for ii=CH %lets do columns
subplot(R,C,ii)
Iv=exp(squeeze(I(:,:,ii)));
imagesc(Iv);
II=II+Iv; %just for fun;
set(gca,'xtick',[],'ytick',[]);
daspect([1 1 1]);
end


for ii=RH %lets do rows
subplot(R,C,ii)
Iv=log(squeeze(I(:,:,ii)));
imagesc(Iv);
II=II+Iv; %just for fun;
set(gca,'xtick',[],'ytick',[]);
daspect([1 1 1]);
end


% Big Plot goes here
 subplot(R,C,setdiff(1:R*C,[1 CH RH]));
 imagesc(II);
 set(gca,'xtick',[],'ytick',[]);
 daspect([1 1 1]);