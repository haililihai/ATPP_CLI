function plot_pairwise(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,LorR)

if LorR == 1
    LR='L';
elseif LorR == 0
    LR='R';
end

sub=textread(SUB_LIST,'%s');
sub_num=length(sub);

file=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_pairwise.mat');
v=load(file);
x=2:MAX_CL_NUM;

mat_cv=[];
mat_dice=[];
mat_nmi=[];
mat_vi=[];
mask=triu(ones(sub_num),1); % upper triangular part
for kc=2:MAX_CL_NUM
    col_cv=v.cv(:,:,kc);
    mat_cv(:,kc)=col_cv(find(mask));
    col_dice=v.dice(:,:,kc);
    mat_dice(:,kc)=col_dice(find(mask));
    
    col_nmi=v.nminfo(:,:,kc);     
    mat_nmi(:,kc)=col_nmi(find(mask));
    col_vi=v.vi(:,:,kc); 
    mat_vi(:,kc)=col_vi(find(mask));
end

hold on;
errorbar(x,mean(mat_dice(:,2:kc)),std(mat_dice(:,2:kc)),'-r','Marker','*');
errorbar(x,mean(mat_nmi(:,2:kc)),std(mat_nmi(:,2:kc)),'-b','Marker','*');
errorbar(x,mean(mat_cv(:,2:kc)),std(mat_cv(:,2:kc)),'-g','Marker','*');
hold off;

set(gca,'XTick',x);
legend('Dice','NMI','CV','Location','SouthEast');
xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
title(strcat(ROI,'.',LR,' pairwise'),'FontSize',14);
set(gcf,'Color','w');

output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_pairwise.jpg');
export_fig(output,'-r300','-painters','-nocrop');

close;

% VI with non-significant label
errorbar(x,mean(mat_vi(:,2:kc)),std(mat_vi(:,2:kc)),'-r','Marker','.');
for k=2:MAX_CL_NUM-1
    h=ttest2(v.vi(:,k),v.vi(:,k+1),0.05,'left');
    if h==0
        sigstar({[k,k+1]},[nan]);
    end
end

set(gca,'XTick',x);
xlabel('Number of clusters','FontSize',14);ylabel('VI','FontSize',14);
title(strcat(ROI,'.',LR,' pairwise VI'),'FontSize',14);
set(gcf,'Color','w');

output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_pairwise_vi.jpg');
export_fig(output,'-r300','-painters','-nocrop');

close;


