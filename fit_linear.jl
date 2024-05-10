using DataFrames, LsqFit, Plots


#function fitting_linear(pathDEST,filename,diamPart)

pathDEST= "C:\\Users\\j.sharma\\OneDrive - Scuola Superiore Sant'Anna\\P10 Microfabrication\\Experiments\\2024\\05.May\\07\\exp1\\analysis_VID005_2024.05.07_17.35.55\\" 

filename= "VID005"
f= pathDEST*"\\MSD_ensemble"*filename*".csv"

f1= pathDEST*"\\MSD_ensemble"*filename*".png"

D=(1.380649e-23*298)/(6π*1e-3*(diamPart*1e-6/2))*1e12     # Diffusive coefficient (um^2/s)
Dr=(1.380649e-23*298)/(8π*1e-3*(diamPart*1e-6/2)^3)       # Rotational diffusive coefficient
tr=(Dr)^(-1)                                              # Rotational time scale

df= CSV.read(f,DataFrame)

#model(y,p)= p[1]*y+ p[2]*(y^2)+p[3]

model(y,p)= p[1]+p[2]*y

start_frame= 1
end_frame= 100

tdata= df[start_frame:end_frame, :tau]

ydata= df[start_frame:end_frame, :MSD]

j1= 4*D+ 5*tr

p0 = [0, j1]
#fit = curve_fit(model, tdata, ydata)
#param = fit.param
#yfit= model(tdata, param)

p=plot(tdata,ydata, seriestype=:scatter, label="Data", xlabel= "Δt(s)", ylabel="MSD_ensemble")
#q= plot!(tdata,yfit,label="Fitted", title= "p0 = $p0")

display(p)
savefig(p,f1)

#end