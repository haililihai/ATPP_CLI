function [dice]=v_dice(x,y,kc)
% Dice's coefficent for validation

if nargin<3 
	kc = max(x(:));
end

num = 0;
den = 0;
dice_m = zeros(kc,1);
for ki = 1:kc
    tmp1 = (x==ki);
    tmp2 = (y==ki);
    dice_m(ki) = 2*length(find(tmp1.*tmp2>0))/(length(find(tmp1>0))+length(find(tmp2>0)));
end

dice = nanmean(dice_m);

