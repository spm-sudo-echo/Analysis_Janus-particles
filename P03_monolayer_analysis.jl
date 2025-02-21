# this code is for thresholding the background of an image and wll be used for liposomes detection
using Images, ImageView, ImageDraw, ImageShow
using ImageCore, Colors, ColorTypes, FileIO, Statistics
using ImageFiltering, ImageTransformations, Plots, ImageSegmentation, ImageMorphology
using ImageFeatures,OpenCV, ImageEdgeDetection, Clustering, ImageComponentAnalysis
include("monolayer_analysis.jl")
include("superimpose_binary_matrices.jl")
pathi= raw"C:\Users\j.sharma\Scuola Superiore Sant'Anna\Yashpal Singh Brar - 2025\01\30\\"
name= "1000x_2_contrastmax_coaxial_top.jpg"
name1= "flower.jpg"
path= pathi*"\\"*name
 img= load(path)
 rgb_img = RGB.(img)
 imshow(RGB.(img))
gray_img = Gray.(img)  
imshow(gray_img)
# imshow(enhanced_img)
blue_img = channelview(ColorTypes.blue.(rgb_img))
upper_threshold = 1.0
lower_threshold = 0.5
num_pixels = length(blue_img)                 # Total pixels in the image
num_defects = sum(p-> lower_threshold<=p<=upper_threshold, blue_img)/num_pixels 
println("Fraction of not monolayer %: ", num_defects*100)    # Count pixels where intensity is ≈ 1
for i in eachindex(blue_img)
  if lower_threshold<=blue_img[i]<=upper_threshold
    rgb_img[i] = RGB(0.0, 0.0, 1.0) #set to blue
  end
end
imshow(rgb_img)
save(pathi*"\\detected_defects.png",rgb_img)


# r = fuzzy_cmeans(img, 3, 2)
# centers = colorview(RGB, r.centers)
# img_cluster=centers[2].*reshape(r.weights[:,2],axes(img))
# imshow(img_cluster)




# img_no_green = RGB.([RGB(c.r, 0, c.b) for c in rgb_img])
# imshow(img_no_green)
# 

# imshow(blue_img)
# r = fuzzy_cmeans(rgb_img, 3, 2)
# centers = colorview(RGB, r.centers)
# r.centers
# centers[1]*reshape(r.weights[:,1])
# imshow(centers)
# img_cluster=centers[3].*reshape(r.weights[:,3],axes(rgb_img))
# imshow(img_cluster)

# data = reshape(img, :, 3)
# k = 2 
# R = kmeans(data, k; maxiter=200, display=:iter)
# a = assignments(R) # get the assignments of points to clusters
# c = counts(R) # get the cluster sizes
# M = R.centers
# L = reshape(a, size(img, 1), size(img, 2))
# imshow(L)
# title("Labeled Image")
# BW = L .== 2
# CC = label_components(BW)
# p = regionprops(CC, :Area, :Centroid)
# gray_img = channelview(ColorTypes.Gray.(img))
# # enhanced_img = histeq(gray_img,255)
# imshow(gray_img)
# histogram(vec(reinterpret(UInt8,gray_img)))# gives histogram of gray image intensity on 0 to 255 range where 0 is black and 255 is white



# defect_size_threshold=15
# multilayer_size_threshold=80
# out1 = tophat(gray_img)
# imshow(out1)
# bw = Gray.(img) .> 0.5
# imshow(bw)
# dist = 1 .- distance_transform(feature_transform(bw))
# markers = label_components(dist .< -15.0)
# imshow(markers)
# segments = watershed(dist, markers)
# imshow((labels_map(segments)))
########################## edge detection code#######################
 img_edges = detect_edges(gray_img, Canny(spatial_scale = 1.4))
 connections= label_components(img_edges)
 imshow(connections)
 imshow(img_edges)#     gaussian_kernel = Kernel.gaussian(35)
 gaussian_kernel = Kernel.gaussian(35)
 background = imfilter(gray_img, gaussian_kernel)
  background_subtracted = gray_img .- background
  normalized_img = map(clamp01, background_subtracted)# for saving the image it should be in 0.0 to 1.0)
 # imshow(background_subtracted)
 # imshow(normalized_img)
 # save(pathi*"\\background_subtracted.png",Gray.(normalized_img))
 threshold_value = otsu_threshold(background_subtracted)
 
 # threshold_value = otsu_threshold(background_subtracted)
 @show binary_img = background_subtracted.> threshold_value
 # imshow(binary_img)
 # save(pathi*"\\binay_img.png",binary_img)
 ###################### working code for what is not monolayer detection########################
 #  # Convert to Float64 for proper intensity calculations (if needed)
 #  gray_img = Float64.(gray_img)

 maskCV = reshape(binary_img, (1, size(binary_img, 1), size(binary_img, 2)))
 maskCV = UInt8.(trunc.(Int, maskCV))
 global c
 c, h = OpenCV.findContours(maskCV, OpenCV.RETR_EXTERNAL, OpenCV.CHAIN_APPROX_NONE);
 global contours
 contours = c
 OpenCV.contourArea(contours)
 #  image,contours,hierarchy = OpenCV.findContours(maskCV,OpenCV.RETR_LIST,OpenCV.CHAIN_APPROX_NONE)
#  OpenCV.findContours(binary_img)
# 4. Filter only circular connected components

# combined_img, defect_mask, multilayer_mask = monolayer_analysis(gray_img; defect_size_threshold, multilayer_size_threshold)
#     gaussian_kernel = Kernel.gaussian(35)

#     background = imfilter(gray_img, gaussian_kernel)
# background_subtracted = gray_img .- background
# normalized_img = map(clamp01, background_subtracted)# for saving the image it should be in 0.0 to 1.0)
# imshow(background_subtracted)
# imshow(normalized_img)
# save(pathi*"\\background_subtracted.png",Gray.(normalized_img))
# #threshold_value = otsu_threshold(background_subtracted)

# threshold_value = otsu_threshold(background_subtracted)
# binary_img = background_subtracted.> threshold_value
# imshow(binary_img)
# save(pathi*"\\binay_img.png",binary_img)
###################### working code for what is not monolayer detection########################
#  # Convert to Float64 for proper intensity calculations (if needed)
#  gray_img = Float64.(gray_img)
 
#  # Compute the fraction of pixels with intensity 1
#  num_pixels = length(gray_img)                 # Total pixels in the image
#  num_ones = count(p -> 0.8 <= p <=1.0, gray_img)      # Count pixels where intensity is ≈ 1
 
#  fraction = num_ones / num_pixels              # Fraction of pixels with intensity 1
 
#  for i in eachindex(gray_img)
#     if 0.8 <= gray_img[i] <=1.0
#         rgb_img[i] = RGB(1, 0, 0)  # Set to red
#     end
# end
# imshow(rgb_img)
# save(pathi*"detected_defects.png",rgb_img)
#  println("Fraction of pixels with intensity 1: ", fraction)

 #######################################################################################


##test code
# for i in 4:0.1:5
#     blob_img=i
#     filter_image = monolayer_analysis(binary_img,blob_img)
#     fimg=superimpose_binary_matrices(.!filter_image,binary_img)
#     imshow(fimg)
# end
#     defect_size_threshold=700
#     multilayer_size_threshold=80
#     combined_img, defect_mask, multilayer_mask = monolayer_analysis(binary_img; defect_size_threshold, multilayer_size_threshold)
#     combined_img, defect_mask, multilayer_mask = monolayer_analysis(.!binary_img; defect_size_threshold, multilayer_size_threshold)
#     imshow(combined_img,name="multilayer_size_threshold=$(multilayer_size_threshold) and defect_size_threshold=$(defect_size_threshold)")
#     save(pathi*"\\defects_tracked.png",combined_img)
#     imshow(combined_img)
    
# imshow(binary_img)
# imshow(.!binary_img)

# imshow(defect_mask)
# imshow(multilayer_mask)

##end test code

#=
save(pathi*"\\binary_img.png",binary_img)
inverted_img = .!binary_img
imshow(inverted_img)
save(pathi*"\\inverted_binary_img.png",inverted_img)
labeled_img = label_components(inverted_img,dims=2)
imshow(labeled_img)
# labeled_img = label_components(binary_img)
# imshow(labeled_img)
connected_components = component_boxes(labeled_img)
size(connected_components)
# dark_spots = findall(labeled_img .== 0)
dark_spots =[]
# Plot the dark spots on top of the labeled image
#  scatter(dark_spots .|> Tuple, legend=false, aspect_ratio=:equal, size=(600,600), markersize=2, color=:red)
 imshow(binary_img)
 # Find dark spots in the coded image
for component in connected_components
    # component is a Vector{Tuple{Int64, Int64}} (list of pixel coordinates)
    @show xs = map(coord -> coord[1], component)  # Extract x-coordinates
    @show ys = map(coord -> coord[2], component)  # Extract y-coordinates

    # Compute bounding box
    x_min, x_max = minimum(xs), maximum(xs)
    y_min, y_max = minimum(ys), maximum(ys)

    # Compute centroid
    centroid = ((x_min + x_max) / 2, (y_min + y_max) / 2)
    @show area = length(component)
    if 1 ≤ area ≤ 1000  # Adjust area limits as needed
        push!(dark_spots, (centroid=centroid, bbox=(x_min, y_min, x_max, y_max), area=area))
    end
end

println("Detected dark spots:")
for spot in dark_spots
    println("Centroid: $(spot.centroid), Area: $(spot.area), Bounding Box: $(spot.bbox)")
end
typeof(dark_spots)
size(dark_spots)

drawimg=RGB.(img)
ax=imshow(gray_img)
p = heatmap(gray_img, color=:gray, axis=false) 
for spot in dark_spots
    
    x, y = spot.centroid[2], spot.centroid[1]
    scatter!([x], [y], color=:red, markersize=0.3, legend=false)
end
display(p)
=#
# segments = meanshift(Gray.(img), 16, 8/255)
# typeof(segments)
# imshow(map(i->get_random_color(i), labels_map(segments)))
# seg_img = Gray.(segments .== 1)
# imshow(seg_img)
# imshow(seg)
# t= pathi*"\\processed_image.png" 
# savefig(pathi,enhanced_img)
#background_subtracted = clamp01(background_subtracted)
# @show gray_img = channelview(img) |> x -> mean(x, dims=1)
# size(gray_img)
# # imshow(gray_img)
# # if ndims(gray_img) == 2
# #     # For 2D images (grayscale)
# #     padding = Pad{2}(:replicate, (10, 10), (10, 10))  # Pad x and y
# # # elseif ndims(gray_img) == 3
# # #     # For 3D images (e.g., RGB)
# # #     padding = Pad{3}(:replicate, (10, 10), (10, 10), (0, 0))  # Pad x, y, and not color channels
# # # else
# #     error("Unsupported image dimensionality")
# # end
#  padding = Pad(:replicate, 2,4) 
# # padded_img = padarray(gray_img, padding)
# threshold_value = 0.82# choose between 0 and 1
# @show local_mean = imfilter(img,Kernel.Laplacian())
# binary_img = Float64.(img) .> Float64.(local_mean)
# #imshow(thresholded_img)
# thresholded_img = binary_img .|> x -> x ? 1.0 : 0.0  # Map true -> 1.0 (white), false -> 0.0 (black)
# thresholded_img = Float64.(thresholded_img) # ensure the image is of type Float64
# thresholded_img = dropdims(thresholded_img, dims=1) #display setting
# imshow(thresholded_img)