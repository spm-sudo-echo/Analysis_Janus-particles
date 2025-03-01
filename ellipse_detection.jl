function analyze_ellipse_and_major_axis(img)
    # Convert to grayscale for easier processing (if not already grayscale)
    gray_img = Gray.(img)
    
    # Threshold the image to detect the black pixels (ellipse boundary)
    # Adjust the threshold value (0.1 here) based on your image contrast
    # Black pixels are close to 0, so we look for values less than a small threshold
    binary_img = gray_img .< 0.5  # Detect black pixels (value < 0.1)
    # Find the coordinates of the black pixels (ellipse boundary)
    points = Tuple{Int, Int}[]
    for i in axes(binary_img, 1), j in axes(binary_img, 2)
        if binary_img[i, j]  # Assuming true (1) for black pixels (value < 0.1)
            push!(points, (j, i))  # Note: (x, y) convention (column, row)
        end
    end
    
    if length(points) < 5
        error("Not enough points detected to fit an ellipse.")
    end
    
    # Fit an ellipse to the points
    # This is a simplified approach; in practice, you might use a library like EllipseFitting.jl or implement a more robust method
    function ellipse_error(params, points)
        x0, y0, a, b, theta = params  # Center (x0, y0), semi-major (a), semi-minor (b), rotation angle (theta)
        error_sum = 0.0
        for (x, y) in points
            # Transform point to ellipse coordinates (rotate and translate)
            dx = x - x0
            dy = y - y0
            angle = atan(dy, dx) - theta
            r = sqrt(dx^2 + dy^2)
            # Ellipse equation: (x'/a)^2 + (y'/b)^2 = 1, where x', y' are rotated coordinates
            x_prime = r * cos(angle)
            y_prime = r * sin(angle)
            error = (x_prime/a)^2 + (y_prime/b)^2 - 1
            error_sum += abs(error)
        end
        return error_sum
    end
    
    # Initial guess for ellipse parameters: center near the mean, axes based on point spread, theta = 0
    x_coords, y_coords = first.(points), last.(points)
    x_mean, y_mean = mean(x_coords), mean(y_coords)
    max_dist = maximum(norm.([(x - x_mean, y - y_mean) for (x, y) in points]))
    initial_params = [x_mean, y_mean, max_dist/2, max_dist/4, 0.0]  # [x0, y0, a, b, theta]
    
    # Optimize to find best-fit ellipse parameters
    result = optimize(params -> ellipse_error(params, points), initial_params, NelderMead())
    params = Optim.minimizer(result)
    x0, y0, a, b, theta = params
    
    # Determine the major axis (assume 'a' is the semi-major axis if a > b)
    is_major_a = a > b
    major_axis_length = 2 * (is_major_a ? a : b)
    minor_axis_length = 2 * (is_major_a ? b : a)

    return (
        x0=x0,
        y0=y0,
        a=major_axis_length/2,
        b=minor_axis_length/2,
        theta=theta
        )
end