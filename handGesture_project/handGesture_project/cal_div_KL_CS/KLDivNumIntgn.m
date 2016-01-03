function Dkl = KLDivNumIntgn(qX,pX,deltaX)
% Calculate the Dkl(q||p) using numerical integration
% That is $\int q(x)\log\frac{q(x)}{p(x)}dx$

qX = qX(:); pX = pX(:);
N = length(qX);
Dkl = zeros(N,1);
for n = 1:N
    if qX(n) == 0
        Dkl(n) = 0;
    else
        Dkl(n) = qX(n)*log(qX(n)/pX(n));
    end
end
Dkl = deltaX*sum(Dkl,1);