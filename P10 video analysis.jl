# Intensity value analysis of a particles in the ellipse video
# each video first set the correct parameters from the first(vid) image and then run the loop for each frame

using Images,VideoIO, DataFrames, CSV,ImageView, ImageDraw, ImageShow, FileIO, Statistics 
pathi= raw"C:\Users\j.sharma\OneDrive - Scuola Superiore Sant'Anna\P10 Microfabrication\Experiments\2024\12.December\05\exp1\\"
name_photo= "IMG022.jpg"
name_vid= "VID001"
# path_photo= pathi*name_photo
# img=load(path_photo)
# imshow(RGB.(img))
pathVID=pathi*name_vid*".avi"
outfile= "analysis_eqR_ellipse21"
time_start= time()
io   = VideoIO.open(pathVID)
vid  = VideoIO.openvideo(io)

x_min, x_max = 360, 980
y_min, y_max = 750, 925
first_img= first(vid)
final_img=first_img[y_min:y_max, x_min:x_max] # use this to cut the single ellipse
imshow(final_img) # showing the cut image of the ellipse
save(pathi*"\\single_ellipse21.png",final_img)
xc, yc = 325, 90     # centre of the ellipse w.r.t the cut image
xe1, ye1 = 100, 50     # first cutting point in the cone w.r.t the cut image
xe2, ye2 = 546, 36  # second cutting point in the cone w.r.t the cut image
m1 = (ye1 - yc)/(xe1 - xc)
b1 = yc - m1*xc
m2 = (ye2 - yc)/(xe2 - xc)
b2 = yc - m2*xc
global mask=falses(size(final_img))
for i in 1:size(final_img,1)
    for j in 1:size(final_img,2)
        if i < j*m1 + b1 && i > j*m2 + b2
            mask[i,j] = true
        end
    end
end

final_img=final_img.*mask

imshow(final_img)
#                                   
# gray_img = channelview(ColorTypes.Gray.(final_img))
# enhanced_img = histeq(gray_img,10)
# imshow(final_img)
# imshow(gray_img)
# imshow(enhanced_img)

save(pathi*name_vid*outfile*".jpg",final_img)
 frame_count = 0
 number= []
 particles= []
for frame in vid
    img=frame
    img = img[y_min:y_max, x_min:x_max]
# imshow(img)
# mask=falses(size(img))
# for i in 1:size(img,1)
#     for j in 1:size(img,2)
#         if i > m1*j + b1 && i < m2*j + b2
#             mask[i,j] = true
#         end
#     end
# end

img=img.*mask
# imshow(img)
img_turn=findall(p -> p ==RGB{N0f8}(0.0,0.0,0.0), img)
img[img_turn].=true
# imshow(img)
 global frame_count
    frame_count = frame_count .+ 1
    # imshow(RGB.(img))
    # img = img[y_min:y_max, x_min:x_max]
    # imshow(RGB.(img))
    gray_img = channelview(ColorTypes.Gray.(img))
    # imshow(gray_img)
    # enhanced_img = histeq(gray_img,50)
    #crop_img = enhanced_img[y_min:y_max, x_min:x_max]
    # imshow(enhanced_img)
    black_pixels = findall(p -> 0 ≤ p ≤ 0.45, gray_img)
    # println( "black pixels are ", length(black_pixels))
    push!(number,frame_count)
    push!(particles,length(black_pixels))
    # println("In Frame $frame_count...." , "black pixels are ", length(black_pixels))
    # sleep(0.1)
end

df=DataFrame(frame=number,black_pixels=particles)
file= pathVID*name_vid*outfile*".csv"
CSV.write(file, df)
time_end= time()
println("Time taken is ", time_end-time_start)

# threshold_value = otsu_threshold(gray_img)
# binary_img = background_subtracted.> threshold_value
# imshow(binary_img)
########################### background thresholding ############################
# gaussian_kernel = Kernel.gaussian(200)

# background = imfilter(gray_img, gaussian_kernel)
# background_subtracted = gray_img .- background
# imshow(Gray.(background_subtracted))
# normalized_img = map(clamp01, background_subtracted)
# imshow(background_subtracted)
# imshow(normalized_img)
# threshold_value = otsu_threshold(background_subtracted)
# binary_img = background_subtracted.> threshold_value
# imshow(binary_img)