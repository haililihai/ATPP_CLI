function y = projsplx(x)

[m,n] = size(x);

sum1 = sum(x,1);
mins = min(x);

x = x - repmat((sum1-1)/m, m, 1);
xx = x;
for i=1:n
    ft = 1;
    if mins(1,i)<0
        f = 1;
        lambda_m=0;
        while abs(f)>0.1
           f = 0;
           xx(:, i) = x(:, i) - repmat(lambda_m,m,1);
           npos = sum(xx(:,i)>0);
           temp = xx(:,i);
           temp(find(temp<0))=0;
           f = f+sum(temp);
           lambda_m = lambda_m + (f-1)/npos;
           if ft > 100
               x(:,i) = temp;
               break;
           end
           ft = ft+1;
        end        
    end
    x(find(x<0)) = 0; 
end
y = x;



