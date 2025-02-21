# Intensity value analysis of a particles in the ellipse video
using Images,VideoIO, DataFrames, CSV,ImageView, ImageDraw, ImageShow, FileIO, Statistics 
pathi= raw"C:\Users\j.sharma\OneDrive - Scuola Superiore Sant'Anna\P10 Microfabrication\Experiments\2024\12.December\05\exp1\\"
name_photo= "IMG022.jpg"
name_vid= "VID001"
# path_photo= pathi*name_photo
# img=load(path_photo)
# imshow(RGB.(img))
pathVID=pathi*name_vid*".avi"
time_start= time()
io   = VideoIO.open(pathVID)
vid  = VideoIO.openvideo(io)
x_min, x_max = 1275, 1900
y_min, y_max = 735, 895
xc, yc = 334, 74
xe1, ye1 = 501, 16
xe2, ye2 = 526, 122
m1 = (ye1 - yc)/(xe1 - xc)
b1 = yc - m1*xc
m2 = (ye2 - yc)/(xe2 - xc)
b2 = yc - m2*xc


#imshow(img)
 frame_count = 0
 number= []
 particles= []
for frame in vid
    img=frame
    img = img[y_min:y_max, x_min:x_max]
imshow(img)
mask=falses(size(img))
for i in 1:size(img,1)
    for j in 1:size(img,2)
        if i > m1*j + b1 && i < m2*j + b2
            mask[i,j] = true
        end
    end
end

img=img.*mask
img_turn=findall(p -> p ==RGB{N0f8}(0.0,0.0,0.0), img)
img[img_turn].=true
 global frame_count
    frame_count = frame_count .+ 1
    # imshow(RGB.(img))
    # img = img[y_min:y_max, x_min:x_max]
    # imshow(RGB.(img))
    gray_img = channelview(ColorTypes.Gray.(img))
    # imshow(gray_img)
    enhanced_img = histeq(gray_img,300)
    #crop_img = enhanced_img[y_min:y_max, x_min:x_max]
    # imshow(crop_img)
    black_pixels = findall(p -> 0 ≤ p ≤ 0.2, enhanced_img)
    # println( "black pixels are ", length(black_pixels))
    push!(number,frame_count)
    push!(particles,length(black_pixels))
    # println("In Frame $frame_count...." , "black pixels are ", length(black_pixels))
    # sleep(0.1)
end

df=DataFrame(frame=number,black_pixels=particles)
file= pathVID*name_vid*"analysis.csv"
CSV.write(file, df)
time_end= time()
println("Time taken is ", time_end-time_start)