using Plots

path = "C:\\Users\\j.sharma\\OneDrive - Scuola Superiore Sant'Anna\\P10 Microfabrication\\Experiments\\2024\\"

f= path*"velocity_histogram.png"
fv= path*"velocity_individual.csv"

df= CSV.read(fv,DataFrame)
#x= ["30s" "60s"  "120s"]

#y= [45.24 52.77 41.54]

x= df[:,:velocity]

p1=histogram(x,xlabel="velocity(um/s)",ylabel="no. of particles",ylims= (0,15), xtickfont=font(12), ytickfont=font(12),color= :lightblue, legend= false)

savefig(p1,f)