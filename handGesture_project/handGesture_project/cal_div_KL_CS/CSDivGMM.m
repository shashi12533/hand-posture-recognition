function Dcs = CSDivGMM(qDist,pDist)
% This program will calculate the Dcs of q and p using closed-form
% expression. Both q and p must be GMM
% qDist: cell array for a GMM q in D(q||p)
% pDist: cell array for a GMM p in D(q||p)

% Given q and p, each GMM
D = length(qDist{1,2}); % dimension of the data
M = size(qDist,1); % number of the Gaussian component in q
pi_m = zeros(1,M); % the prior prob
MU_m = zeros(D,M);
SIGMA_m = zeros(D,D,M);
for m = 1:M
    pi_m(1,m) = qDist{m,1};
    MU_m(:,m) = qDist{m,2};
    SIGMA_m(:,:,m) = qDist{m,3};
end
% make GMM object of q
q_GMM_obj = gmdistribution(MU_m',SIGMA_m,pi_m);


% Make GMM out of p
K = size(pDist,1); % number of the Gaussian component in q
pi_k = zeros(1,K); % the prior prob
MU_k = zeros(D,K);
SIGMA_k = zeros(D,D,K);
for k = 1:K
    pi_k(1,k) = pDist{k,1};
    MU_k(:,k) = pDist{k,2};
    SIGMA_k(:,:,k) = pDist{k,3};
end
% make GMM object of p
p_GMM_obj = gmdistribution(MU_k',SIGMA_k,pi_k);


% ====== start approach I =========
% This approach describe the Dcs straightforward, so there is no efficient
% implematation at all.
% Calculate the first term
term1 = 0;
for m = 1:M
    for k = 1:K
        zmk = mvnpdf(MU_m(:,m),MU_k(:,k),SIGMA_m(:,:,m) + SIGMA_k(:,:,k));
        term1 = term1 + pi_m(1,m)*pi_k(1,k)*zmk;
    end
end

% Calculate the second term
term2 = 0;
for m = 1:M
    for k = 1:M
        zmk = mvnpdf(MU_m(:,m),MU_m(:,k),SIGMA_m(:,:,m) + SIGMA_m(:,:,k));
        term2 = term2 + pi_m(1,m)*pi_m(1,k)*zmk;
    end
end

% Calculate the second term
term3 = 0;
for m = 1:K
    for k = 1:K
        zmk = mvnpdf(MU_k(:,m),MU_k(:,k),SIGMA_k(:,:,m) + SIGMA_k(:,:,k));
        term3 = term3 + pi_k(1,m)*pi_k(1,k)*zmk;
    end
end

Dcs = -log(term1)+0.5*log(term2)+0.5*log(term3);


end % CSDivGMM

