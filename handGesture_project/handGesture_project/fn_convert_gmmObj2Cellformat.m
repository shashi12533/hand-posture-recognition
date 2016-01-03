function qDist = fn_convert_gmmObj2Cellformat(gmm_obj)
% This function onvert the gmm obj format into Bot's format
% The gmm Bot's format is:
% qDist is a cell array of C x 3, where C is the number of Gaussian
% components and 3 is P(w), mu and Sigma

C = gmm_obj.NComponents;
qDist = cell(C,3); % pi, mean and Sigma
for c = 1:C
    qDist{c,1} = gmm_obj.PComponents(c); 
    qDist{c,2} = gmm_obj.mu(c,:)'; 
    qDist{c,3} = gmm_obj.Sigma(:,:,c);
end