% Example
load GMM_out1, gmm1 = gmm;
load GMM_out2, gmm2 = gmm;

Dcs = CSDivGMM(gmm1,gmm2);
disp(['Cauchy-Schwarz divergence CS(gmm1||gmm2)= ',num2str(Dcs)]);

