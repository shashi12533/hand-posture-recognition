function Dkl = KLDivMCGMM(qDist,pDist,N)
% This program will calculate the Dkl of q and p using stochastic
% integration. Both q and p must be GMM
% qDist: cell array for a GMM q in D(q||p)
% pDist: cell array for a GMM p in D(q||p)
% N: number of samples used in integration

% Given q and p, each GMM
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

% Sampling from q
X = zeros(D,N);
qX = zeros(1,N);
for n = 1:N
    r = rand(1); tmp = find(r > cumsum(pi_k_q,2)==0); zn = tmp(1); % the label zn
    mu_k = qDist{zn,2}; Sigma_k = qDist{zn,3};
    X(:,n) = mvnrnd(mu_k,Sigma_k);
    qX(1,n) = pdf(q_GMM_obj,X(:,n)');
end
% plot to see the distribution
% figure; plot(X(1,:),X(2,:),'b*'); daspect([1 1 1]);
% figure; plot3(X(1,:),X(2,:),qX(1,:),'b*');

% ===== calculate Dkl(q||p) ======
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

% Calculate Dkl(q||p)
qX_hat = qX/sum(qX,2); % normalize qX
Dkl = 0;
for n = 1:N
    Dkl = Dkl + qX_hat(n)*log(pdf(q_GMM_obj,X(:,n)')/pdf(p_GMM_obj,X(:,n)'));
end

end % KLDivMCGMM

