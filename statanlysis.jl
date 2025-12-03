# this code is for statistical analysis of velocity data obtained from Python tracking of particles in videos
# data is generated from Python scripts of Yashpal Singh Brar and here only the analysis is done in Julia
using DataFrames, CSV, Plots, Statistics, NaNStatistics, Distributions

pathi = raw"C:\Users\j.sharma\Scuola Superiore Sant'Anna\Yashpal Singh Brar - 2025\11\19\Control\\"

filename = "all_velocities.csv"

data = CSV.read(pathi * filename, DataFrame)

velocity = data[:, :velocity]
@show mean(velocity)

# 1. Determine the shift constant 'c'
min_val = minimum(velocity)
println("Minimum velocity value: ", min_val)
# Set shift to make all values positive (add a small buffer if needed)
shift_constant = min_val + 0.5 # Dynamic; adjust buffer as needed (e.g., +0.01 for stability)
# shift_constant = 0.0
# 2. Shift the data so all values are positive
shifted_velocity = velocity .+ shift_constant

# Fit LogNormal to the SHIFTED (positive) data
d = fit(LogNormal, shifted_velocity)
println("Fitted Shifted LogNormal distribution: ", d)

# --- Plotting the Histogram (of original data) and the Fitted Curve (adjusted for shift) ---

# Plot the histogram of the ORIGINAL data, normalized as PDF (density)
p = histogram(velocity, 
              normalize=:pdf,  # Use :pdf to match PDF scale (integrates to 1)
              label="Histogram of Original Data", 
              bins=200, 
              title="Shifted Lognormal Fit Overlay on Histogram",
              xlabel="Velocity (um/s)",
              ylabel="Density")

# Generate x-values for a smooth curve plot over the original data range
x_range = range(minimum(velocity), maximum(velocity), length=200)  # Or set upper to 10.0 if preferred

# Calculate the PDF values for the fitted distribution 'd' across the shifted range
# (Evaluate at x + shift_constant to overlay on original scale)
pdf_values = pdf.(d, x_range .+ shift_constant)

# Overlay the line plot of the PDF
plot!(p, x_range, pdf_values,
      label="Fitted Shifted Lognormal PDF", 
      color=:red, 
      linewidth=3)

# Peak (mean) marker, adjusted back to original scale
peak_d = mean(d) - shift_constant  # Mean of shifted dist, shifted back
median_d = median(d) - shift_constant  # Median of shifted dist, shifted back
plot!(p, [peak_d], [pdf(d, peak_d + shift_constant)],  # PDF at shifted point
      seriestype=:scatter,
      label="Mean $(round(peak_d, digits=1)) (μm/s)", 
      color=:yellow, 
      markersize=6)
plot!(p, [median_d], [pdf(d, median_d + shift_constant)],  # PDF at shifted point
      seriestype=:scatter,
      label="Median $(round(median_d, digits=1)) (μm/s)", 
      color=:orange, 
      markersize=6)
# Display and save the plot
display(p)
savefig(p, pathi * "fitted_lognormal.png")