 
function mean_sqr_disp(pathDEST,filename,framerate,um_px,diamPart)
include("drift_corr.jl")
include("mean_sqr_disp_cal.jl")

df = CSV.read(pathDEST*"\\coordinates_"*filename*".csv", DataFrame)

## --- Operation on the DataFrame: --------------------
df[!,:BlobID] = convert.(Int64,df[!,:BlobID]);
df[!,:Frame] = round.(Int64,df[:,:Time]./df[1,:Time])
df[!,:x] = df[!,:x]*um_px
df[!,:y] = df[!,:y]*um_px


##--- Rendering of the plots -------------------------
boxtrack=20    # Max X & Y in the box plots 
maxlimMSD=1.0   # Y Max in MSD plot
minlimMSD=0.0  # Y min in MSD plot

##---- On the basis of the entry, calculate: ---------
D=(1.380649e-23*298)/(6π*1e-3*(diamPart*1e-6/2))*1e12     # Diffusive coefficient (um^2/s)
Dr=(1.380649e-23*298)/(8π*1e-3*(diamPart*1e-6/2)^3)       # Rotational diffusive coefficient
tr=(Dr)^(-1)                                              # Rotational time scale

##--- Apply the drift correction through the function "drift_corr.jl" ---
##--- Return gdf_clean_corrected, immobile_tracks, jump_tracks, short_tracks, discard_tracks ---
gdf_clean_corrected, immobile_tracks, jump_tracks, short_tracks, discard_tracks = drift_correct(df,um_px,framerate,filename,pathDEST)

##--- Calculate number of detected traks -------------
nTraks=length(gdf_clean_corrected)
##--- Find Max length of time vector -----------------
lt = maximum([size(g)[1] for g in gdf_clean_corrected])
tauMax=ceil(Int,lt/10) # Decide the time interval (ceil is the excess approximation, floor for defect one)


##--- Plots a restricted number of track, traslated to zero ---> you may have to change axes limits!!!

##--- Initialize 0TRAJECTORY Plot -------------------
graphSDtrck =plot(); 

idx = []
for i in 1:length(gdf_clean_corrected)
    push!(idx,i)
end

for i in rand(idx,min(length(idx),10))

    ## Define the zero position
    x0i= gdf_clean_corrected[i][1,:x]
    y0i = gdf_clean_corrected[i][1,:y]
    ## Add column and fill it with data
    plot!(graphSDtrck, gdf_clean_corrected[i][!,:x].-x0i,gdf_clean_corrected[i][!,:y].-y0i, xlims=(-boxtrack,boxtrack), ylims=(-boxtrack,boxtrack),legend=false,aspect_ratio = 1,framestyle = :box)    
  
      
end

display(graphSDtrck)

##--- Calculates & Plots the MSD   ---> you may have to change axes limits!!!

##--- Initialize Plot single MSDs -----------------
graphsingMSD=plot()
matrMSD=fill(NaN, tauMax+1, length(idx))
drift_part_neglect=fill(0.0,tauMax+1,1)
lim_factor=2

xMSD=Array(0:1/framerate:tauMax/framerate)

##--- Calculating the MSD of a diffusing particle
for tau in 1:tauMax+1
    drift_part_neglect[tau,1]=lim_factor*4*D*xMSD[tau]
end

##--- Calculate the MSD through the function "MSDfun.jl" ---
##--- Return MSD -----------------------------------

par_idx=[]
for i in 1:length(idx)#-7
 matrMSD[1:tauMax+1, i] = MSDcal(gdf_clean_corrected[idx[i]],tauMax)
 if  (matrMSD[framerate+1, i]>drift_part_neglect[framerate+1, 1])
    println("active particle is = $i")
    push!(par_idx,i)
end
end

active_MSD=fill(NaN, tauMax+1, length(par_idx))
j=0
for i in 1:length(par_idx)
    active_MSD[:,i] = matrMSD[:,par_idx[i]]
end

##---Calculating the total and active particles
ap=length(par_idx)
tp=length(idx)

#MSD=vec(nanmean(matrMSD, dims=2))    #mean of MSD, so average plot
#dsMSD=vec(nanstd(matrMSD; dims=2))

MSD=vec(nanmean(active_MSD, dims=2))    #mean of MSD, so average plot
dsMSD=vec(nanstd(active_MSD; dims=2))
#std((active_MSD; dims=2))
if (ap!=0)
    maxlimMSD=2*maximum(MSD)
end
#plot!(graphsingMSD,xMSD,matrMSD, ylims=(minlimMSD,maxlimMSD), legend=false)    # plots of the single MSDs of each track
plot!(graphsingMSD,xMSD,active_MSD, ylims=(minlimMSD,maxlimMSD), legend=false)
plot!(graphsingMSD,xMSD,MSD, #=yerror=dsMSD=# ylims=(minlimMSD,maxlimMSD), marker=true,legend=false);    # plots the MSD over the single traks
xlabel!("Δt [s]");
ylabel!("MSD [μm²]")
display(graphsingMSD)

##--- Initialize Plot MEDIA MSD ------------------
graphMSD=plot();
plot!(graphMSD,xMSD,MSD, #=yerror=dsMSD=# ylims=(minlimMSD,maxlimMSD), marker=true,legend=false);  # plots the MSD alone
xlabel!("Δt [s]");
ylabel!("MSD [μm²]")
display(graphMSD)


##--- SAVE WITHOUT the fit --> this is done in a different script ---
png(graphsingMSD, pathDEST*"\\singMSD_"*filename)
title!(graphsingMSD,"Active particles = $ap \n Total Particles = $tp")
png(graphsingMSD, pathDEST*"\\singMSD_info_"*filename)
png(graphMSD, pathDEST*"\\MSD_ensemble_"*filename)
png(graphSDtrck, pathDEST*"\\tracks_"*filename)

##--- Save a .csv with the MSD to overlay plots in a second moment ---
MSD_df=DataFrame(tau=xMSD, MSD=MSD, MSDerror=dsMSD)
CSV.write(pathDEST*"\\MSD_ensemble_"*filename*".csv", MSD_df)

##--- Save variables --------------------------------
d=Dict("length_idx"=>length(idx), "tauMax"=>tauMax,"nTracks"=>nTraks,"um_px"=>um_px, "framerate"=>framerate, "diamPart"=>diamPart,"idx"=>idx,"D"=>D,"Dr"=>Dr,"tr"=>tr)
JSON3.write(pathDEST*"\\var_PROVA_"*filename*".json", d)
#--to read the JSON3 file and get back the variables--
#d2= JSON3.read(read("file.json", String))
#for (key,value) in d2
#        @eval $key = $value
#end

end