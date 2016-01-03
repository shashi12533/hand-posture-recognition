% This code calculate the divergence of 2 hand images

clear
clc
close all

% addpath to Dcs folder
addpath('/home/student1/MATLABcodes/handGesture/cal_div_KL_CS');

% load the data
load ckaisea1_crop_data
qDist = gmmDist;

load bfritza1_crop_data
% load bfritzc1_crop_data
% load ckaisea1_crop_data
pDist = gmmDist;

% Calculate Cauchy Schwarz divergence using our method
tic;
Dcs = CSDivGMM(qDist,pDist);
disp(['Dcs = ',num2str(Dcs),'   runtime: ',num2str(toc),' sec']);

% Calculate GMM with stochastic integration
Ns = 100;
tic;
Dkl_MC = KLDivMCGMM(qDist,pDist,Ns);
disp(['Dkl_MC = ',num2str(Dkl_MC),'   runtime: ',num2str(toc),' sec']);
