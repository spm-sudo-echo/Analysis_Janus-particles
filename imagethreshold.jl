# this code is for thresholding the background of an image and wll be used for liposomes detection
using Images, ImageView, ImageDraw, ImageShow, ImageCore, Colors, ColorTypes, FileIO, Statistics, ImageFiltering, ImageTransformations, Plots, ImageSegmentation, ImageMorphology

include("monolayer_analysis.jl")
include("superimpose_binary_matrices.jl")
pathi= raw"C:\Users\j.sharma\OneDrive - Scuola Superiore Sant'Anna\P10 Microfabrication\liposome_analysis"
name= "monolayer.jpg"

path= pathi*"\\"*name
 img= load(path)
 imshow(RGB.(img))
 segments = meanshift(Gray.(img), 16, 8/255)
typeof(segments)
imshow(map(i->get_random_color(i), labels_map(segments)))
seg_img = Gray.(segments .== 1)
imshow(seg_img)
imshow(seg)
gray_img = channelview(ColorTypes.Gray.(img))
enhanced_img = histeq(gray_img,250)
imshow(enhanced_img)
gaussian_kernel = Kernel.gaussian(15)
background = imfilter(gray_img, gaussian_kernel)
background_subtracted = gray_img .- background
normalized_img = map(clamp01, background_subtracted)# for saving the image it should be in 0.0 to 1.0)
imshow(background_subtracted)
imshow(normalized_img)
save(pathi*"\\background_subtracted.png",Gray.(normalized_img))
#threshold_value = otsu_threshold(background_subtracted)

threshold_value = otsu_threshold(background_subtracted)
binary_img = background_subtracted.>threshold_value
imshow(binary_img)
save(pathi*"\\binay_img.png",binary_img)

##test code
# for i in 4:0.1:5
#     blob_img=i
#     filter_image = monolayer_analysis(binary_img,blob_img)
#     fimg=superimpose_binary_matrices(.!filter_image,binary_img)
#     imshow(fimg)
# end
for i in 50:5:100
    defect_size_threshold=4
    multilayer_size_threshold=i
    combined_img, defect_mask, multilayer_mask = monolayer_analysis(binary_img; defect_size_threshold, multilayer_size_threshold)
    imshow(combined_img,name="multilayer_size_threshold=$i")
end

imshow(binary_img)
imshow(combined_img)
imshow(defect_mask)
imshow(multilayer_mask)

##end test code


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