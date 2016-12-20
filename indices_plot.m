function indices_plot(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,LEFT,RIGHT,split_half,pairwise,leave_one_out,cont,hi_vi,sil,tpd)

if split_half==1
    if LEFT==1
        plot_split_half(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1);
    end
    if RIGHT==1
        plot_split_half(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0);
    end
end

if leave_one_out==1
    if LEFT==1
        plot_leave_one_out(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1);
    end
    if RIGHT==1
        plot_leave_one_out(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0);
    end
end

if pairwise==1
    if LEFT==1
        plot_pairwise(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1);
    end
    if RIGHT==1
        plot_pairwise(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0);
    end
end

if cont==1
    if LEFT==1
        plot_cont(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1)
    end
    if RIGHT==1
        plot_cont(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0)
    end
end

if hi_vi==1
    if LEFT==1
        plot_hi(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1)
        plot_vi(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1)
    end
    if RIGHT==1
        plot_hi(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0)
        plot_vi(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0)
    end
end

if sil==1
    if LEFT==1
        plot_sil(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,1)
    end
    if RIGHT==1
        plot_sil(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,0)
    end
end

if tpd==1
    plot_tpd(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM)
end

