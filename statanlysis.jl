# this code is for statistical analysis of velocity data obtained from Phthon tracking of particles in videos
#data is generated from Phython scripts of Yashpal Singh Brar and here only the analysis is done in Julia
using DataFrames, CSV, Plots, Statistics, NaNStatistics, Distributions

pathi= raw"C:\Users\j.sharma\Scuola Superiore Sant'Anna\Yashpal Singh Brar - 2025\11\19\Control\\"

filename = "all_velocities.csv"

data = CSV.read(pathi*filename, DataFrame)

velocity=data[:, :velocity]

# Basic statistics
log_velocity = log.(velocity)  # Adding a small constant to avoid negative values so that it can be later fitted to LogNormal distribution
  d = fit(LogNormal,log_velocity)
plot!(x->pdf(d,x)*N*d_step,0,hist_lim,label="LogNormal",color=color,linewidth=2)
plot1 = histogram(log_velocity, bins=200, title="Velocity Distribution", xlabel="log(v) (um/s)", ylabel="Frequency", legend=false, ylims=(0, 50))

display(plot1)

savefig(plot1, pathi*"log_velocity_distribution.png")

