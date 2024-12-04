using Plots, CSV,DataFrames, StatsPlots

path = "C:\\Users\\j.sharma\\OneDrive - Scuola Superiore Sant'Anna\\P10 Microfabrication\\Experiments\\2024\\11.November\\15\\exp2\\"

filename= "all_velocity.png"
f= joinpath(path, filename)
fv= path*"all_velocity.csv"

df= CSV.read(fv,DataFrame)
#x= ["30s" "60s"  "120s"]
x= df[:,:velocity]
#y= [45.24 52.77 41.54]
#  y= df[:,:FFTcurvature]
# x= df[:,:Run]
 p1=histogram(x,xlabel="velocity(um/s)",ylabel="no. of particles",ylims= (0,40), xtickfont=font(12), ytickfont=font(12),color= :lightblue, legend= false)


# Create a boxplot
# p = @df df boxplot(:FFTcurvature, legend=false,ylabel="Frequency(mHz)", ylims=(0, 1.1),title="V5", bar_width=0.02)

# plot!(y,  kind="box")
savefig(p1, f)
