# this code is for statistical analysis of velocity data obtained from Python tracking of particles in videos
# data is generated from Python scripts of Yashpal Singh Brar and here only the analysis is done in Julia
using DataFrames, CSV, Plots, Statistics, NaNStatistics, Distributions, HypothesisTests

# Paths and filenames for both datasets
path_non_spaced = raw"C:\Users\j.sharma\Scuola Superiore Sant'Anna\Yashpal Singh Brar - 2025\11\19\Control\\"
filename_non_spaced = "all_velocities_control.csv"

path_spaced = raw"C:\Users\j.sharma\Scuola Superiore Sant'Anna\Yashpal Singh Brar - 2025\11\19\Spaced\\"  # Update if different
filename_spaced = "all_velocities_spaced.csv"  # Update with actual filename

# Load data
data_non_spaced = CSV.read(path_non_spaced * filename_non_spaced, DataFrame)
velocities_non_spaced = data_non_spaced[:, :velocity]
@show mean(velocities_non_spaced)

data_spaced = CSV.read(path_spaced * filename_spaced, DataFrame)
velocities_spaced = data_spaced[:, :velocity]
@show mean(velocities_spaced)

# Function to shift data and fit lognormal (applied to each dataset)
function shift_and_fit(velocity)
    min_val = minimum(velocity)
    println("Minimum velocity value: ", min_val)
    shift_constant = abs(min_val) + 0.5  # Make positive with buffer; use abs if negatives possible
    shifted_velocity = velocity .+ shift_constant
    d = fit(LogNormal, shifted_velocity)
    println("Fitted Shifted LogNormal distribution: ", d)
    return shifted_velocity, d, shift_constant
end

# Process non-spaced
shifted_non_spaced, d_non_spaced, shift_non_spaced = shift_and_fit(velocities_non_spaced)

# Process spaced
shifted_spaced, d_spaced, shift_spaced = shift_and_fit(velocities_spaced)

# --- Plotting for Non-Spaced ---
p_non = histogram(velocities_non_spaced, 
                  normalize=:pdf, 
                  label="Histogram of Non-Spaced Data", 
                  bins=200, 
                  title="Shifted Lognormal Fit (Non-Spaced)",
                  xlabel="Velocity (um/s)",
                  ylabel="Density")

x_range_non = range(minimum(velocities_non_spaced), maximum(velocities_non_spaced), length=200)
pdf_values_non = pdf.(d_non_spaced, x_range_non .+ shift_non_spaced)
plot!(p_non, x_range_non, pdf_values_non, label="Fit Non-Spaced", color=:red, linewidth=3)

peak_non = mean(d_non_spaced) - shift_non_spaced
median_non = median(d_non_spaced) - shift_non_spaced
plot!(p_non, [peak_non], [pdf(d_non_spaced, peak_non + shift_non_spaced)], seriestype=:scatter, label="Mean $(round(peak_non, digits=1))", color=:yellow, markersize=6)
plot!(p_non, [median_non], [pdf(d_non_spaced, median_non + shift_non_spaced)], seriestype=:scatter, label="Median $(round(median_non, digits=1))", color=:orange, markersize=6)

display(p_non)
savefig(p_non, path_non_spaced * "fitted_lognormal_non_spaced.png")

# --- Plotting for Spaced (similar) ---
p_spaced = histogram(velocities_spaced, 
                     normalize=:pdf, 
                     label="Histogram of Spaced Data", 
                     bins=200, 
                     title="Shifted Lognormal Fit (Spaced)",
                     xlabel="Velocity (um/s)",
                     ylabel="Density")

x_range_spaced = range(minimum(velocities_spaced), maximum(velocities_spaced), length=200)
pdf_values_spaced = pdf.(d_spaced, x_range_spaced .+ shift_spaced)
plot!(p_spaced, x_range_spaced, pdf_values_spaced, label="Fit Spaced", color=:red, linewidth=3)

peak_spaced = mean(d_spaced) - shift_spaced
median_spaced = median(d_spaced) - shift_spaced
plot!(p_spaced, [peak_spaced], [pdf(d_spaced, peak_spaced + shift_spaced)], seriestype=:scatter, label="Mean $(round(peak_spaced, digits=1))", color=:yellow, markersize=6)
plot!(p_spaced, [median_spaced], [pdf(d_spaced, median_spaced + shift_spaced)], seriestype=:scatter, label="Median $(round(median_spaced, digits=1))", color=:orange, markersize=6)

display(p_spaced)
savefig(p_spaced, path_non_spaced * "fitted_lognormal_spaced.png")  # Or use path_spaced

# --- Comparison Plots ---
# # Boxplot for raw velocities
# plot_box = boxplot([velocities_non_spaced velocities_spaced], label=["Non-Spaced" "Spaced"],
#                    title="Velocity Comparison", ylabel="Velocity (um/s)", legend=:topright)
# display(plot_box)
# savefig(plot_box, path_non_spaced * "velocity_boxplot_comparison.png")

# --- Basic Statistics for Each ---
function compute_stats(vel)
    μ = mean(vel)
    σ = std(vel)
    skew = skewness(vel)
    kurt = kurtosis(vel)
    return (mean=μ, std=σ, skewness=skew, kurtosis=kurt)
end

stats_non_spaced = compute_stats(velocities_non_spaced)
stats_spaced = compute_stats(velocities_spaced)

@show stats_non_spaced[4]
println("Non-Spaced Stats: ", stats_non_spaced)
println("Spaced Stats: ", stats_spaced)

# --- Hypothesis Tests ---
# Log-transform shifted data for normality checks and t-test
log_non_spaced = log.(shifted_non_spaced)
log_spaced = log.(shifted_spaced)

# Normality checks (Shapiro-Wilk on log-shifted)
p_log_non = pvalue(ShapiroWilkTest(log_non_spaced))
p_log_spaced = pvalue(ShapiroWilkTest(log_spaced))
println("Shapiro-Wilk p-value (Log Non-Spaced): $p_log_non")
println("Shapiro-Wilk p-value (Log Spaced): $p_log_spaced")

# Variance test on log-shifted
var_test = LeveneTest(log_non_spaced, log_spaced)
p_var = pvalue(var_test)
println("Levene's Test p-value (log scale): $p_var")

# Non-parametric: Mann-Whitney U (on original velocities; one-sided: spaced > non-spaced)
mw_result = MannWhitneyUTest(velocities_spaced, velocities_non_spaced)
p_mw = pvalue(mw_result, tail=:right)
println("Mann-Whitney p-value (Spaced > Non-Spaced): $p_mw")
if p_mw < 0.05
    println("Evidence that spaced velocities are higher.")
else
    println("No significant evidence of difference.")
end

# Parametric: t-test on log-shifted (one-sided)
if p_var > 0.05
    ttest_result = EqualVarianceTTest(log_spaced, log_non_spaced)
else
    ttest_result = UnequalVarianceTTest(log_spaced, log_non_spaced)
end
p_ttest = pvalue(ttest_result, tail=:right)
println("t-Test p-value on log scale (Spaced > Non-Spaced): $p_ttest")

# Cohen's d (effect size)
pooled_sd = sqrt( ((length(velocities_spaced)-1)*stats_spaced[2] + (length(velocities_non_spaced)-1)*stats_non_spaced[2]) / (length(velocities_spaced) + length(velocities_non_spaced) - 2) )
cohens_d = (mean(velocities_spaced) - mean(velocities_non_spaced)) / pooled_sd
println("Cohen's d: $cohens_d")  # Positive value indicates spaced > non-spaced