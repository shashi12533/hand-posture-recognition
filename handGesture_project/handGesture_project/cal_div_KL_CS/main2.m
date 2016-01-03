% Run 3 types of divergences on 3D data
% Divergences are Cauchy-Schwarz divergence (Dcs),
% Kullback-Leibler using monte carlo (stochastic integration) Dkl-MC
% and Kullback-Leibler using numerical integration Dkl-NI
% Compare the trend of the value and the run-time

clear all
close all
clc

qDist = cell(3,3);
pDist = cell(3,3);

% qDist{1,1} = 0.3; qDist{1,2} = [0 0 0]'; qDist{1,3} = eye(3);
% qDist{2,1} = 0.2; qDist{2,2} = [3 0 0]'; qDist{2,3} = eye(3);
% qDist{3,1} = 0.2; qDist{3,2} = [0 3 0]'; qDist{3,3} = eye(3);
% qDist{4,1} = 0.2; qDist{4,2} = [1.5 1.5 0]'; qDist{4,3} = eye(3);
% qDist{5,1} = 0.1; qDist{5,2} = [3 3 0]'; qDist{5,3} = eye(3);

qDist{1,1} = 0.3; qDist{1,2} = [0 0 0]'; qDist{1,3} = eye(3);
qDist{2,1} = 0.3; qDist{2,2} = [3 0 0]'; qDist{2,3} = eye(3);
qDist{3,1} = 0.4; qDist{3,2} = [8 0 0]'; qDist{3,3} = eye(3);

cnt = 1;
Dcs = zeros(1,1000)*nan;
Dkl_SI = zeros(1,1000)*nan;
Dkl_NI = zeros(1,1000)*nan;
Dcs_t = zeros(1,1000)*nan;
Dkl_SI_t = zeros(1,1000)*nan;
Dkl_NI_t = zeros(1,1000)*nan;

shift_list = [-20:1:20];
% shift_list = [-2:1:2];
for shift = shift_list
    %     pDist{1,1} = 0.3; pDist{1,2} = [0 0 0+shift]'; pDist{1,3} = eye(3);
    %     pDist{2,1} = 0.2; pDist{2,2} = [3 0 0+shift]'; pDist{2,3} = eye(3);
    %     pDist{3,1} = 0.2; pDist{3,2} = [0 3 0+shift]'; pDist{3,3} = eye(3);
    %     pDist{4,1} = 0.2; pDist{4,2} = [1.5 1.5 0+shift]'; pDist{4,3} = eye(3);
    %     pDist{5,1} = 0.1; pDist{5,2} = [3 3 0+shift]'; pDist{5,3} = eye(3);
    
    pDist{1,1} = 0.3; pDist{1,2} = [0 0+shift 0]'; pDist{1,3} = eye(3);
    pDist{2,1} = 0.3; pDist{2,2} = [3 0+shift 0]'; pDist{2,3} = eye(3);
    pDist{3,1} = 0.4; pDist{3,2} = [8 0+shift 0]'; pDist{3,3} = eye(3);
    
    % ===============================  calculate Dcs -- closed form solution
    tic;
    Dcs(cnt) = CSDivGMM(qDist,pDist);
    Dcs_t(cnt) = toc;
    
    % ================================ calculate Dkl -- stochastic integration
    N = 1000;
    tic;
    Dkl_SI(cnt) = KLDivMCGMM(qDist,pDist,N);
    Dkl_SI_t(cnt) = toc;
    
    % ===============================  Calculate Dkl -- numerical integration
    % make GMM object from q
    D = length(qDist{1,2}); % dimension of the data
    K_q = size(qDist,1); % number of the Gaussian component in q
    pi_k_q = zeros(1,K_q); % the prior prob
    MU = zeros(D,K_q);
    SIGMA = zeros(D,D,K_q);
    for k = 1:K_q
        pi_k_q(1,k) = qDist{k,1};
        MU(:,k) = qDist{k,2};
        SIGMA(:,:,k) = qDist{k,3};
    end
    % make GMM object of q
    q_GMM_obj = gmdistribution(MU',SIGMA,pi_k_q);
    
    % % plot q
    % ezsurf(@(x,y)pdf(q_GMM_obj,[x y]),[-10 20],[-10 10])
    
    % Make GMM out of p
    K_p = size(pDist,1); % number of the Gaussian component in q
    pi_k_p = zeros(1,K_p); % the prior prob
    MU = zeros(D,K_p);
    SIGMA = zeros(D,D,K_p);
    for k = 1:K_p
        pi_k_p(1,k) = pDist{k,1};
        MU(:,k) = pDist{k,2};
        SIGMA(:,:,k) = pDist{k,3};
    end
    % make GMM object of p
    p_GMM_obj = gmdistribution(MU',SIGMA,pi_k_p);
    
    % % plot p
    % ezsurf(@(x,y)pdf(p_GMM_obj,[x y]),[-10 20],[-10 10])
    
    tic;
    % make the grid
    dx1 = 0.1; dx2 = 0.1; dx3 = 0.1;
    x1 = [-15:dx1:23];
    x2 = [-15:dx2:15];
    x3 = [-5:dx1:5];
    [xI,yI,zI] = meshgrid(x1,x2,x3);
    qX = pdf(q_GMM_obj,[xI(:),yI(:),zI(:)]);
    pX = pdf(p_GMM_obj,[xI(:),yI(:),zI(:)]);
    
    % % plot the point cloud
    % figure; hold on;
    % plot3(xI(:),yI(:),qX,'b*');
    % plot3(xI(:),yI(:),pX,'r*');
    % xlabel('x'); ylabel('y');
    
    deltaX = dx1*dx2*dx3;
    
    Dkl_NI(cnt) = KLDivNumIntgn(qX,pX,deltaX);
    Dkl_NI_t(cnt) = toc;
    
    cnt = cnt + 1;
    
end

% ---- plot the Div ----
Dcs = Dcs(1,~isnan(Dcs));
Dkl_SI = Dkl_SI(1,~isnan(Dkl_SI));
Dkl_NI = Dkl_NI(1,~isnan(Dkl_NI));
Dcs_t = Dcs_t(1,~isnan(Dcs_t));
Dkl_SI_t = Dkl_SI_t(1,~isnan(Dkl_SI_t));
Dkl_NI_t = Dkl_NI_t(1,~isnan(Dkl_NI_t));


figure; hold on;
plot(shift_list,Dcs,'b*-');
plot(shift_list,Dkl_SI,'ro-');
plot(shift_list,Dkl_NI,'kx-');
legend('Dcs',['Dkl (SI): ',num2str(N),' sample'],['Dkl (NI): \Deltax=',num2str(dx1)]);
title('comparison of divergences'); xlabel('shift'); ylabel('divergence value');
print('-depsc','-r200',['compareDiv_3D.eps']);

figure; hold on;
plot(shift_list,Dcs_t,'b*-');
plot(shift_list,Dkl_SI_t,'ro-');
plot(shift_list,Dkl_NI_t,'kx-');
legend('Dcs',['Dkl (SI): ',num2str(N),' sample'],['Dkl (NI): \Deltax=',num2str(dx1)]);
title('run-time'); xlabel('shift'); ylabel('time (sec)');
print('-depsc','-r200',['compareRuntime_3D.eps']);