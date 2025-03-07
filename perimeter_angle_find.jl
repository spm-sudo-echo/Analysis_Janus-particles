using SpecialFunctions, Plots

function find_phi1(a::Float64, b::Float64)
    # Step 1: Calculate eccentricity
    e = sqrt(1 - (b^2 / a^2))
    if e >= 1.0 || e < 0.0
        error("Invalid eccentricity (e must be between 0 and 1). Check a and b values.")
    end

    # Step 2: Compute the complete elliptic integral of the second kind E(e)
    E_complete = ellipk(e^2)  # Note: ellipk gives K(e), but for E(e), use ellipe
    E_complete = ellipe(e^2)  # Corrected to use ellipe for the complete elliptic integral of the second kind

    # Target value for the incomplete integral
    target = E_complete / 4.0

    # Step 3: Define the function to find the root
    function f(alpha)
        # Incomplete elliptic integral of the second kind E(alpha, e)
        return ellipe(alpha, e^2) - target
    end

    # Step 4: Use bisection method to find alpha (phi1/2)
    # Initial bounds for alpha (0 to pi/2, since E increases from 0 to E(e))
    a_lower = 0.0
    a_upper = pi / 2.0  # Upper bound for alpha (phi1/2 <= pi/2)

    # Check the function values at bounds
    if f(a_lower) * f(a_upper) >= 0
        error("Function values at bounds have the same sign. Adjust bounds.")
    end

    # Bisection method
    tolerance = 1e-6
    max_iterations = 1000
    alpha = (a_lower + a_upper) / 2.0

    for i in 1:max_iterations
        if f(alpha) == 0.0 || (a_upper - a_lower) / 2.0 < tolerance
            break
        end
        if f(alpha) > 0
            a_upper = alpha
        else
            a_lower = alpha
        end
        alpha = (a_lower + a_upper) / 2.0
    end

    # Step 5: Compute phi1
    phi1 = 2.0 * alpha

    # Step 6: Verify the result
    E_incomplete = ellipe(phi1 / 2.0, e^2)
    println("E(e) = $E_complete")
    println("Target = $target")
    println("E(phi1/2, e) = $E_incomplete")
    println("phi1 (radians) = $phi1")
    println("phi1 (degrees) = $(rad2deg(phi1))")

    return phi1
end

# Example usage
a = 2.0  # semi-major axis
b = 1.0  # semi-minor axis
phi1 = find_phi1(a, b)

# Optional: Plot the function to visualize the root
alpha_range = 0.0:0.01:pi/2
f_values = [ellipe(alpha, (sqrt(1 - (b^2 / a^2))^2)) - (ellipe((sqrt(1 - (b^2 / a^2))^2)) / 4) for alpha in alpha_range]
plot(alpha_range, f_values, label="f(alpha)", xlabel="alpha (radians)", ylabel="f(alpha)", title="Root Finding for phi1/2")
scatter!([phi1/2], [0.0], label="Root", color=:red)