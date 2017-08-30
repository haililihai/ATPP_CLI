function [mean_dice]=v_dice(x,y,varargin)
% Dice's coefficent for validation

kc=length(unique(x))-1;

dice = zeros(kc,1);
for ki = 1:kc
    tmp1 = (x==ki);
    tmp2 = (y==ki);
    if nargin==2
    	dice(ki) = 2*length(find(tmp1.*tmp2>0))/(length(find(tmp1>0))+length(find(tmp2>0)));
	elseif nargin==3
		tmp3 = (varargin{1}==ki);
		dice(ki) = 3*length(find(tmp1.*tmp2.*tmp3>0))/(length(find(tmp1>0))+length(find(tmp2>0))+length(find(tmp3>0)));
	end
end

mean_dice = nanmean(dice);

