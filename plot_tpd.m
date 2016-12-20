function plot_tpd(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM)

sub=textread(SUB_LIST,'%s');
sub_num=length(sub);

file1=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_index_group_tpd.mat');
v1=load(file1);
file2=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_index_indi_tpd.mat');
v2=load(file2);
x=2:MAX_CL_NUM;

m_indi_tpd=nanmean(v2.indi_tpd);
std_indi_tpd=nanstd(v2.indi_tpd);

hold on;
plot(x,v1.group_tpd(2:end),'-r','Marker','*');
errorbar(x,m_indi_tpd(2:end),std_indi_tpd(2:end),'-b','Marker','*');
hold off;

set(gca,'XTick',x);
legend('group TpD','indi TpD','Location','SouthEast');
xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
title(strcat(ROI,'.TpD index'),'FontSize',14);
set(gcf,'Color','w');

output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_tpd.jpg');
export_fig(output,'-r300','-painters','-nocrop');

close;


