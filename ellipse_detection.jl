using Images, ImageSegmentation, CoordinateTransformations, Optim, LinearAlgebra, Statistics, ImageView

function analyze_ellipse_and_major_axis(img)
    # 1. Load the image
    #img = load(image_path)
    #imshow(img)
    # Convert to grayscale for easier processing (if not already grayscale)
    gray_img = Gray.(img)
    
    # 2. Threshold the image to detect the black pixels (ellipse boundary)
    # Adjust the threshold value (0.1 here) based on your image contrast
    # Black pixels are close to 0, so we look for values less than a small threshold
    binary_img = gray_img .< 0.5  # Detect black pixels (value < 0.1)
    imshow(binary_img)
    # 3. Find the coordinates of the black pixels (ellipse boundary)
    points = Tuple{Int, Int}[]
    for i in axes(binary_img, 1), j in axes(binary_img, 2)
        if binary_img[i, j]  # Assuming true (1) for black pixels (value < 0.1)
            push!(points, (j, i))  # Note: (x, y) convention (column, row)
        end
    end
    
    if length(points) < 5
        error("Not enough points detected to fit an ellipse.")
    end
    
    # 4. Fit an ellipse to the points
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
    
    # 5. Calculate the center of the ellipse
    #center = (x0, y0)
    
    # 6. Determine the major axis (assume 'a' is the semi-major axis if a > b)
    is_major_a = a > b
    major_axis_length = 2 * (is_major_a ? a : b)
    minor_axis_length = 2 * (is_major_a ? b : a)
    
    # Equation for lines deviding the ellipse into equal areas.
    θ = atan(minor_axis_length, major_axis_length)
    m1, m2 = tan(-θ), tan(θ)
    b1, b2 = y0 - m1 * x0, y0 - m2 * x0


    # 7. Equation of the major axis line
    # The major axis is aligned with the angle theta (rotation of the ellipse)
    # Line equation: y - y0 = m(x - x0), where m = tan(theta)
    #m = tan(theta)  # Slope of the major axis
    #c = y0 - m * x0  # Y-intercept
    
    # Line equation in slope-intercept form: y = mx + c
    #major_axis_equation = "y = $(round(m, digits=2))x + $(round(c, digits=2))"
    
    # Alternatively, in general form: Ax + By + C = 0
    #A = -m  # Coefficient of x
    #B = 1   # Coefficient of y
    #C = -c  # Constant term
    #general_form = "($(round(A, digits=2)))x + ($(round(B, digits=2)))y + ($(round(C, digits=2))) = 0"
    
    return (
        m1 = m1,
        m2 = m2,
        b1 = b1,
        b2 = b2
    )
end
#=
# Example usage (replace "path/to/your/image.jpg" with the actual path to your image)
try
    result = analyze_ellipse_and_major_axis("C:/Users/y.brar/OneDrive - Scuola Superiore Sant'Anna/Desktop/single_ellipse21.png")
    println("Center of the ellipse: ($(result.center[1]), $(result.center[2]))")
    println("Major axis equation (slope-intercept): $(result.major_axis_slope_intercept)")
    println("Major axis equation (general form): $(result.major_axis_general_form)")
    println("Major axis length: $(result.major_axis_length)")
    println("Minor axis length: $(result.minor_axis_length)")
catch e
    println("Error: $e")
end
=#