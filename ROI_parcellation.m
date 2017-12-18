function ROI_parcellation(PWD,ROI,SUB_LIST,MAX_CL_NUM,POOLSIZE,METHOD,LEFT,RIGHT)
% ROI parcellation

SUB = textread(SUB_LIST,'%s');

method = METHOD;
N = MAX_CL_NUM-1;

% modify temporary dir
temp_dir=tempname();
mkdir(temp_dir);
if exist('parcluster')
	pc=parcluster('local');
	pc.JobStorageLocation=temp_dir;
else
	sched=findResource('scheduler','type','local');
	sched.DataLocation=temp_dir;
end

% open pool
if exist('parpool')
	p=parpool('local',POOLSIZE);
else
	matlabpool('local',POOLSIZE);
end

parfor i = 1:length(SUB);
	
if LEFT == 1
    outdir_L = strcat(PWD,'/',SUB{i},'/',SUB{i},'_',ROI,'_L','_',method);
    if ~exist(outdir_L,'dir') mkdir(outdir_L); end
    data = load(strcat(PWD,'/',SUB{i},'/',SUB{i},'_',ROI,'_L_matrix/connection_matrix.mat')); 
    coordinates = data.xyz;
    matrix = data.matrix;
    
    panduan = any(matrix');
    coordinates = coordinates(panduan,:);
    matrix = matrix(panduan,:);

    nii = load_untouch_nii(strcat(PWD,'/',SUB{i},'/',SUB{i},'_',ROI,'_L_DTI.nii.gz'));
    image_f=nii.img;

 	for k=1:N
        filename=strcat(outdir_L,'/',ROI,'_L_',num2str(k+1),'.nii');
		if ~exist(filename,'file')
		    display(strcat(SUB{i},'_',ROI,'_L_',num2str(k+1),' processing...'));
            switch method
                case 'sc'
                    matrix1 = matrix*matrix';
                    matrix1 = matrix1-diag(diag(matrix1));   
                    index=sc3(k+1,matrix1);
                case 'kmeans'
                    index=kmeans(matrix,k+1,'Replicates',300);
			    otherwise
                    error('Error: Unknown clustering method!');
            end
            image_f(:,:,:)=0;
			for j = 1:length(coordinates)
				image_f(coordinates(j,1)+1,coordinates(j,2)+1,coordinates(j,3)+1)=index(j);
			end
			nii.img=image_f;
			save_untouch_nii(nii,filename);
		end
    end
	display(strcat(SUB{i},'_',ROI,'_L',' Done!'));
end

if RIGHT == 1
	outdir_R = strcat(PWD,'/',SUB{i},'/',SUB{i},'_',ROI,'_R','_',method);
    if ~exist(outdir_R,'dir')  mkdir(outdir_R); end
    data = load(strcat(PWD,'/',SUB{i},'/',SUB{i},'_',ROI,'_R_matrix/connection_matrix.mat')); 
    coordinates = data.xyz;
    matrix = data.matrix;
    
    panduan = any(matrix');
    coordinates = coordinates(panduan,:);
    matrix = matrix(panduan,:);

    nii = load_untouch_nii(strcat(PWD,'/',SUB{i},'/',SUB{i},'_',ROI,'_R_DTI.nii.gz'));
    image_f=nii.img;
    
	for k=1:N
        filename=strcat(outdir_R,'/',ROI,'_R_',num2str(k+1),'.nii');
		if ~exist(filename,'file')
		    display(strcat(SUB{i},'_',ROI,'_R_',num2str(k+1),' processing...'));
            switch method
                case 'sc'
                    matrix1 = matrix*matrix';
                    matrix1 = matrix1-diag(diag(matrix1));   
                    index=sc3(k+1,matrix1);
                case 'kmeans'
                    index=kmeans(matrix,k+1,'Replicates',300);
			    otherwise
                    error('Error: Unknown clustering method!');
            end
            image_f(:,:,:)=0;
			for j = 1:length(coordinates)
				image_f(coordinates(j,1)+1,coordinates(j,2)+1,coordinates(j,3)+1)=index(j);
			end
			nii.img=image_f;
			save_untouch_nii(nii,filename);
		end
    end
    display(strcat(SUB{i},'_',ROI,'_R',' Done!'));
end
end

% close pool
if exist('parpool')
	delete(p);
else
	matlabpool close;
end
