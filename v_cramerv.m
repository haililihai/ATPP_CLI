function [es,esCi,chi2]=v_cramerv(x,y,confLevel)
% this function computes Cramer's V, including exact analytical CI
% ** NOTE: in the case of 2 by 2 tables Cramer's V is identical to phi
% except possibly for the sign), which will be taken care of in the last
% lines
% adapted from the Measures of Effect Size Toolbox, Harald Hentschke

if size(x,1)>1
    x=reshape(x,1,length(x(:)));
end
if size(y,1)>1
    y=reshape(y,1,length(y(:)));
end

tabxy=crosstab(x,y);
table=tabxy./numel(x); % probability

CONF=0.95;
if ~exist('confLevel','var') | isempty(confLevel)
    confLevel=CONF;
end

[nRow nCol]=size(table);
if nRow<2 || nCol<2
  error('table size must at least be 2 by 2');
end
% what kinda table?
if nRow==2 && nCol==2
  is2by2=true;
else
  is2by2=false;
end
% reject foul values
if any(any(~isfinite(table)))
  error('input variable table contains foul data (nan or inf))');
end
% --- check other input arguments
if confLevel<=0 || confLevel>=1
  error('input variable ''confLevel'' must be a scalar of value >0 and <1');
end

colSum=sum(table);
rowSum=sum(table,2);
n=sum(sum(table));
k=min(nRow,nCol);
df=(nRow-1)*(nCol-1);
% expected frequency of occurrence in each cell: product of row and
% column totals divided by total N
ef=(rowSum*colSum)/n;
% chi square stats
chi2=(table-ef).^2./ef;
chi2=sum(chi2(:));
% Cramer's V
es=sqrt(chi2/(n*(k-1)));
% CI (Smithson 2003, p. 40)
ncp=ncpci(chi2,'X2',df,'confLevel',confLevel);
esCi=sqrt((ncp+df)/(n*(k-1)));
% in case we are dealing with 2 by 2 tables heed sign
if is2by2
  if det(table)<0
    es=es*-1;
    esCi=fliplr(esCi)*-1;
  end
end
