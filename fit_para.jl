# Here we are doing curve fitting and calculting the velocity of MSD_ensemble or individual particles

using DataFrames, LsqFit, Plots, CurveFit, CSV


#function fitting_linear(pathDEST,filename,diamPart)

pathDEST= "C:\\Users\\j.sharma\\OneDrive - Scuola Superiore Sant'Anna\\P10 Microfabrication\\Experiments\\2024\\06.June\\14\\exp1\\analysis_VID008_2024.06.19_17.51.22\\" 

filename= "VID008"
f= pathDEST*"\\MSD_ensemble_"*filename*".csv"

f1= pathDEST*"\\MSD_ensemble_fit_"*filename*".png"
diamPart=3
D=(1.380649e-23*298)/(6π*1e-3*(diamPart*1e-6/2))*1e12     # Diffusive coefficient (um^2/s)
Dr=(1.380649e-23*298)/(8π*1e-3*(diamPart*1e-6/2)^3)       # Rotational diffusive coefficient
tr=(Dr)^(-1)                                              # Rotational time scale

df= CSV.read(f,DataFrame)

#model(y,p)= p[1]*y+ p[2]*(y^2)+p[3]

start_frame= 1
end_frame= 25

tdata= df[start_frame:end_frame, :tau]

ydata= df[start_frame:end_frame, :MSD]

j1= 4*D

j2= 5.0

p0 = [j1, j2]
model(y,p)= p[1].*y+p[2].*(0.25.*y.*y)
fit = curve_fit(model, tdata, ydata,p0)
param = fit.param
yfit= model(tdata, param)
velocity= sqrt(param[2])
p=plot(tdata,ydata, seriestype=:scatter, label="Data", xlabel= "Δt(s)", ylabel="MSD_ensemble")
q= plot!(tdata,yfit,label="Fitted", title= " velocity = $velocity")

plot(p,q)
display(p)
savefig(p,f1)

#end