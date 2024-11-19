# this code is for thresholding the background of an image and wll be used for liposomes detection
using Images,ImageView, FileIO, Statistics, ImageFiltering, ImageTransformations,Plots

pathi= raw"C:\Users\j.sharma\OneDrive - Scuola Superiore Sant'Anna\P10 Microfabrication\liposome_analysis"
name= "Active GUv.png"

path= pathi*"\\"*name
@show img= load(path)

gray_img = channelview(ColorTypes.Gray.(img))
enhanced_img = histeq(gray_img,250)
imshow(enhanced_img)
gaussian_kernel = Kernel.gaussian(15)
background = imfilter(gray_img, gaussian_kernel)
background_subtracted = gray_img .- background
imshow(background_subtracted)
savefig(path*"\\background_subtracted.png",background_subtracted)
threshold_value = otsu_threshold(background_subtracted)
binary_img = background_subtracted .> threshold_value
imshow(binary_img)
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