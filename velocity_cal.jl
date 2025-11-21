# Here we are doing curve fitting and calculating the velocity of MSD_ensemble or individual particles
# it can be used for multiple fit and velocity calculations
using DataFrames, LsqFit, Plots, CSV

function velocity_cal(pathDEST, filename, diamPart)
    f = pathDEST * "\\MSD_individual_" * filename * ".csv"
    fv = pathDEST * "\\velocity_individual_" * filename * ".csv"

    D = (1.380649e-23 * 298) / (6π * 1e-3 * (diamPart * 1e-6 / 2)) * 1e12     # Diffusive coefficient (um^2/s)
    Dr = (1.380649e-23 * 298) / (8π * 1e-3 * (diamPart * 1e-6 / 2)^3)       # Rotational diffusive coefficient
    tr = (Dr)^(-1)                                              # Rotational time scale

    df = CSV.read(f, DataFrame)

    start_frame = 1
    end_frame = 25
    gdf = groupby(df, :number)
    index = []
    vel = []

    for g in gdf
        k = first(g[start_frame:end_frame, :number])
        tdata = g[start_frame:end_frame, :tau]
        ydata = g[start_frame:end_frame, :single_MSD]

        j1, j2 = 4 * D, 1.0  # p[2] initial for v^2 ~1 (v~1 um/s)
        px = [j1, j2]
        model(y, p) = p[1] .* y .+ p[2] .* (y .* y)  # Fixed: MSD = 4Dt + v^2 t^2 (no 0.25)
        fit = LsqFit.curve_fit(model, tdata, ydata, px)
        param = fit.param

        velocity = sqrt(abs(param[2])) # velocity in um/s

        push!(index, k)
        push!(vel, velocity)
    end

    velocity_single_df = DataFrame(particle = index, velocity = vel)
    p1 = histogram(vel, xlabel="velocity(um/s)", ylabel="no. of particles", bins=0:0.5:15, xtickfont=font(12), ytickfont=font(12), color=:lightblue, legend=false)
    savefig(p1, pathDEST * "\\all_velocity_" * filename * ".png")
    CSV.write(fv, velocity_single_df)
end
############################################ following commands are for printing MSD_individual_particles and their fit##########################################
# f1 = pathDEST * "\\MSD_individual_fit_particle_$k" * filename * ".png"
# yfit = model(tdata, param)
# p = plot(tdata, ydata, seriestype=:scatter, label="Data", xlabel="Δt(s)", ylabel="MSD_ensemble")
# q = plot!(tdata, yfit, label="Fitted", title=" velocity = $velocity")
# savefig(q, f1)
#########################################################################################################################################################