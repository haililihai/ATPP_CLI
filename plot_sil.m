function plot_sil(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,LorR)

if LorR == 1
    LR='L';
elseif LorR == 0
    LR='R';
end

sub=textread(SUB_LIST,'%s');
sub_num=length(sub);

file1=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_group_silhouette.mat');
v1=load(file1);
file2=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_indi_silhouette.mat');
v2=load(file2);
x=2:MAX_CL_NUM;

m_indi_sil=nanmean(v2.indi_sil);
std_indi_sil=nanstd(v2.indi_sil);

hold on;
plot(x,v1.group_sil(2:end),'-r','Marker','*');
errorbar(x,m_indi_sil(2:end),std_indi_sil(2:end),'-b','Marker','*');
hold off;

set(gca,'XTick',x);
legend('group silhouette','indi silhoutte','Location','SouthEast');
xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
title(strcat(ROI,'.',LR,' silhouette index'),'FontSize',14);
set(gcf,'Color','w');

output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_silhouette.jpg');
export_fig(output,'-r300','-painters','-nocrop');

close;


