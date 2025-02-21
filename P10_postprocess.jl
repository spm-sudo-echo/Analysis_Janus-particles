# this code is for thresholding the background of an image and wll be used for liposomes detection
using Images, ImageView, ImageDraw, ImageShow, ImageCore, Colors, ColorTypes, FileIO, Statistics, ImageFiltering, ImageTransformations, Plots, ImageSegmentation, ImageMorphology
using IndirectArrays
include("monolayer_analysis.jl")

pathi= raw"C:\Users\j.sharma\OneDrive - Scuola Superiore Sant'Anna\P10 Microfabrication\Experiments\2024\12.December\05\exp1\\"
name= "IMG022v2.jpg"

path= pathi*"\\"*name
 img= load(path)
#  imshow(RGB.(img))

gray_img = channelview(ColorTypes.Gray.(img))
imshow(gray_img)
enhanced_img = histeq(gray_img,300)
x_min, x_max = 500, 620
y_min, y_max = 53,140
cropped_img = enhanced_img[y_min:y_max, x_min:x_max]
imshow(cropped_img)
# Get the coordinates of pixels where intensity is between 0 and 0.2
black_pixels = findall(p -> 0 ≤ p ≤ 0.2, cropped_img)

# Convert CartesianIndex to (x, y) coordinates
x_coords = [p[2] for p in black_pixels]  # Column index (X)
y_coords = [p[1] for p in black_pixels] 
intensity_values = [enhanced_img[y, x] for (x, y) in zip(x_coords, y_coords)]
# Create a heatmap where (x, y) positions are colored by intensity
surface(x_coords, y_coords, intensity_values, 
        color=:viridis, 
        xlabel="X", ylabel="Y", 
        title="Intensity Distribution for Pixels in [0, 0.2]")

# Add colorbar for reference
colorbar!()
heatmap(x_coords, y_coords, intensity_values, color=:viridis, xlabel="X", ylabel="Y", title="Low Intensity Pixels")
plot(x_coords, y_coords, seriestype=:scatter, markersize=1, color=:red, legend=false)
# Display the number of such pixels
println("Number of pixels with intensity in [0, 0.2]: ", length(low_intensity_pixels))

enhanced_img[237,716]
heatmap(enhanced_img, color=:viridis, xlabel="X", ylabel="Y", title="Intensity Distribution")
histogram(vec(enhanced_img), bins=256, xlabel="Intensity", ylabel="Frequency", title="Intensity Histogram", color=:blue)
imshow(enhanced_img)
x = 1:size(enhanced_img, 2)  # X-axis (columns)
y = 1:size(enhanced_img, 1)  # Y-axis (rows)
z = Float64.(enhanced_img)   # Convert image to float for plotting

surface(x, y, z, xlabel="X", ylabel="Y", zlabel="Intensity", title="3D Intensity Distribution", color=:viridis)


gaussian_kernel = Kernel.gaussian(50)

background = imfilter(gray_img, gaussian_kernel)
background_subtracted = gray_img .- background
heatmap(background_subtracted, color=:viridis, xlabel="X", ylabel="Y", title="Intensity Distribution")
normalized_img = map(clamp01, background_subtracted)# for saving the image it should be in 0.0 to 1.0)
imshow(background_subtracted)
# imshow(normalized_img)
save(pathi*"\\background_subtracted.png",Gray.(normalized_img))
#threshold_value = otsu_threshold(background_subtracted)

threshold_value = otsu_threshold(background_subtracted)
binary_img = background_subtracted.>-0.055
# imshow(binary_img)


# Image size (modify as needed)
height = 240
width = 640

# binary_img = falses(height, width)  # Initialize binary image
# Define ellipse parameters
xc, yc = 312/2, 108/2  # Center of the ellipse
a, b = 304, 67   # Semi-major and semi-minor axes
num_points = 2000    # Number of points to sample
theta= -0.04
thickness = 5  # Thickness of the ellipse band
# Generate ellipse coordinates
# t = range(0, 2π, length=num_points)
# x = round.(Int, xc .+ a * cos.(t))
# y = round.(Int, yc .+ b * sin.(t))

function ellipse_coordinates(a, b, xc, yc, theta, num_points)
    t = range(0, 2π, length=num_points)
    x = xc .+ a * cos.(t)
    y = yc .+ b * sin.(t)
    ellipse_x = round.(Int, xc .+ x .* cos(theta) .- y .* sin(theta))
    ellipse_y = round.(Int, yc .+ x .* sin(theta) .+ y .* cos(theta))
    return ellipse_x, ellipse_y
end
for r in -thickness:thickness
    ellipse_x, ellipse_y = ellipse_coordinates(a + r, b + r, xc, yc, theta, num_points)
    for (x, y) in zip(ellipse_x, ellipse_y)
        if 1 ≤ x ≤ width && 1 ≤ y ≤ height
            binary_img[y, x] = true  # Fill entire elliptical band
        end
    end
end
# Apply rotation transformation
# ellipse_x = round.(Int, xc .+ x .* cos(theta) .- y .* sin(theta)) 
# ellipse_y = round.(Int, yc .+ x .* sin(theta) .+ y .* cos(theta))
# # Plot the ellipse onto the binary image
# for (x, y) in zip(ellipse_x, ellipse_y)
#     if 1 <= x <= width && 1 <= y <= height  # Ensure coordinates are within image bounds
#         binary_img[y, x] = true
#     end
# end

# Display the binary image with the ellipse
imshow(binary_img)
save(pathi*"\\modified_img_ellipse.png",Gray.(binary_img))

# ################## my manual method##################################

# original_img = copy(binary_img)
# imshow(original_img)
# a= 307
# b=72
# e=b/a

# round(Int64, b)

# ellipse_x = [t.+ 340 for t in (-a:1:a)]
# ellipse_y_up = [sqrt(((e*e).*(t.*t)).-1).+ 118.0 for t in ellipse_x]
# ellipse_y_down = [sqrt(((e*e).*(t.*t)).-1).- 118.0 for t in ellipse_x]
# plot(ellipse_y_up,ellipse_x)
# plot!(ellipse_y_down,ellipse_x)
# ellipse_x_int = [round(Int64, x) for x in ellipse_y_down]
# ellipse_y_int = [round(Int64, y) for y in ellipse_y_up]
# piar =[ellipse_y_int ellipse_x]
# plot(ellipse_x,ellipse_y_up)

# binary_img[ellipse,590:595].= true

# @show binary_img[102:130,590:595]     # remember the first index is the y coordinate and the second is the x coordinate
# imshow(binary_img)
# # Define ellipse coordinates
# ellipse_x = [t + 340 for t in (-a:1:a)]
# ellipse_y_up = [sqrt(((e*e) * (t*t)) - 1) + 118.0 for t in ellipse_x]
# ellipse_y_down = [-sqrt(((e*e) * (t*t)) - 1) + 118.0 for t in ellipse_x]

# # Convert to integer coordinates
# ellipse_x_int = [round(Int64, x) for x in ellipse_x]
# ellipse_y_up_int = [round(Int64, y) for y in ellipse_y_up]
# ellipse_y_down_int = [round(Int64, y) for y in ellipse_y_down]

# # Ensure binary_img exists and has the correct dimensions
# binary_img = falses(512, 512)  # Example size, adjust based on your actual image

# # Set pixels inside the binary image for the upper ellipse boundary
# for (x, y) in zip(ellipse_x_int, ellipse_y_up_int)
#     if 1 ≤ x ≤ size(binary_img, 2) && 1 ≤ y ≤ size(binary_img, 1)  # Ensure within bounds
#         binary_img[y, x] = true
#     end
# end

# # Set pixels for the lower ellipse boundary
# for (x, y) in zip(ellipse_x_int, ellipse_y_down_int)
#     if 1 ≤ x ≤ size(binary_img, 2) && 1 ≤ y ≤ size(binary_img, 1)  # Ensure within bounds
#         binary_img[y, x] = true
#     end
# end

# # Display the binary image
# imshow(binary_img)





#################################### for ellipse boundary detection and blurring their edges..not working##################


# @show binary_img


# # Find the boundaries of the ellipses
# ellipse_boundaries = imgradients(binary_img, KernelFactors.sobel, "reflect")[1] .> 0 # Use gradients to detect boundaries

# # Create a new image to store the result
# result_img = copy(binary_img)

# # Change the boundary pixels of ellipses to white
# result_img[ellipse_boundaries] .= 0  # Set boundaries to white

# # Overlay the original binary mask (to keep the particles inside the ellipses black)
# result_img[binary_img .== 1] .= 1

# # Save the final image
# save(pathi*"modified_image.png", (.!result_img))  # Invert to match the original image convention

# # Display the original and modified images
# imshow(img)
# imshow((.!result_img))

###################### another manual detection of the ellipses not working####################
   # Detect black regions as `true`

# Label the connected components in the binary image
# labeled_img = label_components(binary_img)

# # Create a copy of the original image to modify
# result_img = copy(gray_img)

# # Function to compute bounding box
# function compute_boundingbox(component_mask)
#     # Find all `true` pixel locations in the mask
#     indices = findall(component_mask)  # This gives a Vector of CartesianIndex
#     if isempty(indices)  # If no pixels are found, return a dummy bounding box
#         return CartesianIndex(1, 1), CartesianIndex(1, 1)
#     end

#     # Extract rows and columns from the CartesianIndex objects
#     rows = map(idx -> idx[1], indices)
#     cols = map(idx -> idx[2], indices)

#     # Get the minimum and maximum row/column indices
#     row_min, row_max = minimum(rows), maximum(rows)
#     col_min, col_max = minimum(cols), maximum(cols)

#     # Return the bounding box corners as CartesianIndex
#     return CartesianIndex(row_min, col_min), CartesianIndex(row_max, col_max)
# end


# # Iterate over each labeled component
# for label in 1:maximum(labeled_img)
#     # Extract the component as a binary mask
#     component_mask = labeled_img .== label

#     # Compute bounding box of the component
#     bbox_min, bbox_max = compute_boundingbox((component_mask))  # Convert to Tuple for indexing (component_mask)
#     bbox_range = Tuple(bbox_min), Tuple(bbox_max)
#     bbox = bbox_min[1]:bbox_max[1], bbox_min[2]:bbox_max[2]  # Create range for the bounding box
#     region = component_mask[bbox...]  # Extract region inside the bounding box

#     # Check if the region is an ellipse (based on aspect ratio or size)
#     region_area = count(region)
#     @show region_dims = size(region)
#     aspect_ratio = region_dims[1] / region_dims[2]  # Height-to-width ratio

#     # If it looks like an ellipse (adjust conditions as needed)
#     if region_area > 9 && 4.0 < aspect_ratio < 6.0  # Example conditions
#         # Set the boundary pixels of the ellipse to white
#         dilated = dilate(component_mask)  # Dilate the region slightly
#         boundary_mask = dilated .& .!component_mask      # Subtract interior from the dilated region
#         result_img[boundary_mask] .= 1.0  # Set boundary to white
        
#         # Keep particles inside the ellipse black
#         result_img[component_mask] .= 0.0  # Restore particles to black
#     end
# end

# # Save the final result
# save(pathi*"modified_ellipse_image.png", Gray.(result_img))

# # Display the original and modified images
# imshow(img)
# imshow(Gray.(result_img))











#####################################################################################
# labeled_seeds = label_components(binary_img)
# segmented_img = watershed(background_subtracted, labeled_seeds)

# # Function to convert labeled regions to RGB image
# function label_to_rgb(labeled_img::AbstractArray)
#     # Find the number of unique labels
#     labels = unique(labeled_img)
#     labels = labels[labels .> 0]  # Ignore the background (label 0)
    
#     # Generate random colors for each label
#     color_map = Dict(label => RGB(rand(), rand(), rand()) for label in labels)
    
#     # Map each label to its corresponding color
#     rgb_img = RGB.(zeros(size(labeled_img)))  # Start with a black image
#     for label in labels
#         rgb_img[labeled_img .== label] .= color_map[label]
#     end
    
#     return rgb_img
# end

# segmented_overlay = label_to_rgb(segmented_img)

# imshow(colored_labels, title="Watershed Segmentation")
# labels = labels_map(segmented_img)
# colored_labels = IndirectArray(labels, distinguishable_colors(maximum(labels)))
# masked_colored_labels = colored_labels .* (1 .- binary_img)  # Mask the background
# mosaic(img, colored_labels, masked_colored_labels; nrow=1)
# segmented_overlay = label2rgb(segmented_img)  # Colored segments
# imshow(segmented_overlay, title="Watershed Segmentation")
# imshow(binary_img)
# imshow(segmented_img)

# save(pathi*"assets/watershed.gif", cat(img, colored_labels, masked_colored_labels; dims=3); fps=1) 
# save(pathi*"\\binay_img.png",binary_img)

 




