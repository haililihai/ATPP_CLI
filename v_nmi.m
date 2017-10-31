function [nmi,vi]=v_nmi(x,y)
% compute normalized mutual information and variation of information for vector x and y

if size(x,1)>1
    x=reshape(x,1,length(x(:)));
    x=x(~isnan(x));
end
if size(y,1)>1
    y=reshape(y,1,length(y(:)));
    y=y(~isnan(y));
end

% entropy of x and y
tabx = tabulate(x);
px = tabx(:,3)/100;
ex = -sum(px.*log(px));

taby = tabulate(y);
py = taby(:,3)/100;
ey = -sum(py.*log(py));

% joint entropy of x and y
tabxy = crosstab(x,y);
pxy = tabxy./numel(x);
exy = 0;
for i = 1:size(tabx,1)
    for j = 1:size(taby,1)
        if pxy(i,j)>0
            exy = exy - pxy(i,j)*log(pxy(i,j));
        end
    end
end

% mutual information
mi = ex + ey - exy;
% normalized (ex+ey)/2 is a tight upper bound on mi
nmi = 2*mi/(ex + ey);
% variation of information
vi = ex + ey - 2*mi;

