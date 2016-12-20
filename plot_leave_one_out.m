function plot_leave_one_out(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,LorR)

if LorR == 1
    LR='L';
elseif LorR == 0
    LR='R';
end

sub=textread(SUB_LIST,'%s');
sub_num=length(sub);

file=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_leave_one_out.mat');
v=load(file);
x=2:MAX_CL_NUM;

m_dice=nanmean(v.dice);
std_dice=nanstd(v.dice);
m_nmi=nanmean(v.nminfo);
std_nmi=nanstd(v.nminfo);
m_cv=nanmean(v.cv);
std_cv=nanstd(v.cv);

hold on;
errorbar(x,m_dice(2:end),std_dice(2:end),'-r','Marker','*');
errorbar(x,m_nmi(2:end),std_nmi(2:end),'-b','Marker','*');
errorbar(x,m_cv(2:end),std_cv(2:end),'-g','Marker','*');
hold off;

set(gca,'XTick',x);
legend('Dice','NMI','CV','Location','SouthEast');
xlabel('Number of clusters','FontSize',14);ylabel('Indice','FontSize',14);
title(strcat(ROI,'.',LR,' leave one out'),'FontSize',14);
set(gcf,'Color','w');

output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_leave_one_out.jpg');
export_fig(output,'-r300','-painters','-nocrop');
close;

% VI with non-significant label
m_vi=nanmean(v.vi);
std_vi=nanstd(v.vi);
errorbar(x,m_vi(2:end),std_vi(2:end),'-r','Marker','*');
for k=2:MAX_CL_NUM-1
    h=ttest2(v.vi(:,k),v.vi(:,k+1),0.05,'left');
    if h==0
        sigstar({[k,k+1]},[nan]);
    end
end

set(gca,'XTick',x);
xlabel('Number of clusters','FontSize',14);ylabel('VI','FontSize',14);
title(strcat(ROI,'.',LR,' leave one out VI'),'FontSize',14);
set(gcf,'Color','w');

output=strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_leave_one_out_vi.jpg');
export_fig(output,'-r300','-painters','-nocrop');
close;


