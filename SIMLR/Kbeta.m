function distX = Kbeta(D_kernels, alphaK)
    [x,y,z] = size(D_kernels);
    distX = zeros(x,y);
    for i=1:1:z
       distX = distX + alphaK(i)*D_kernels(:,:,i);
    end

end
