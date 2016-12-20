function index=sc3(k, W)
% derived from SpectralClustering (Ingo Buerk)
% Hai Li

    dim=size(W,1);
    degs=sum(W,2);
    D = spdiags(degs,0,dim,dim); % sparse diag matrix
    L = D - W;
    degs(degs==0)=eps; % in case of dividing by zero
    D_sqrt=spdiags(1./(degs.^0.5),0,dim,dim);
    L_sym=D_sqrt*L*D_sqrt;

    % the k smallest eigenvalues closet to eps (nonzero)
    % k+5, hard coded, find the nonzero eigenvalues
    [U, d]=eigs(L_sym,k+5,eps);

    % find nonzero eigenvalues
    [idx,tmp]=find(diag(d));
    starting=idx(1);
    U=U(:,starting:starting+k-1);

    % row-wise normalization
    U=bsxfun(@rdivide, U, sqrt(sum(U.^2,2)));

    index = kmeans(U, k, 'Replicates',300);
end
