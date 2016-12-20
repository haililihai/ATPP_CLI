function plot_hi(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,LorR)

if LorR == 1
    LR='L';
elseif LorR == 0
    LR='R';
end

sub=textread(SUB_LIST,'%s');
sub_num=length(sub);

file1=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_group_hi.mat');
v1=load(file1);
file2=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_indi_hi.mat');
v2=load(file2);
x=3:MAX_CL_NUM;

m_indi_hi=nanmean(v2.indi_hi);
std_indi_hi=nanstd(v2.indi_hi);

hold on;
plot(x,v1.group_hi(3:end),'-r','Marker','*');
errorbar(x,m_indi_hi(3:end),std_indi_hi(3:end),'-b','Marker','*');
hold off;

set(gca,'XTick',x);
legend('group hi','indi hi','Location','SouthEast');
xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
title(strcat(ROI,'.',LR,' hierarchy index'),'FontSize',14);
set(gcf,'Color','w');

output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_hi.jpg');
export_fig(output,'-r300','-painters','-nocrop');
close;


