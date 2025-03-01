using Images, VideoIO, DataFrames, CSV, ImageShow, Statistics, ColorTypes, ImageSegmentation, CoordinateTransformations, Optim, LinearAlgebra, ImageView
include("ellipse_detection.jl")
# ---- Configuration ----
pathi = raw"C:\Users\j.sharma\OneDrive - Scuola Superiore Sant'Anna\P10 Microfabrication\Experiments\2024\12.December\05\exp1\\"
name_vid = "VID001"
pathVID = pathi * name_vid * ".avi"
outfile = "testttt..equators_ellipse21_v3"

# ---- Crop Region and Ellipse Parameters ----
x_min, x_max = 360, 980
y_min, y_max = 750, 925


# ---- Utility Function to Create Masks ----
function create_ellipse_masks(img_size,x0,y0,a,b,theta)
    θ = atan(b, a)
    m1, m2 = tan(-θ), tan(θ)
    b1, b2 = y0 - m1 * x0, y0 - m2 * x0
    maskeqL,maskeqR,maskpoleU,maskpoleD = ntuple(_->falses(img_size), 4)
    for i in 1:img_size[1], j in 1:img_size[2]
        if i < j*m1 + b1 && i > j*m2 + b2
            maskeqL[i, j] = true
        elseif i > j*m1 + b1 && i < j*m2 + b2
            maskeqR[i, j] = true
        elseif i< j*m1 + b1 && i < j*m2 + b2
            maskpoleU[i, j] = true
        elseif i> j*m1 + b1 && i > j*m2 + b2
            maskpoleD[i, j] = true
        end
        if ((j-x0)cos(theta)+(i-y0)sin(theta))^2/a^2 + ((j-x0)sin(theta)-(i-y0)cos(theta))^2/b^2 > 1
            maskeqL[i, j] = false
            maskeqR[i, j] = false
            maskpoleU[i, j] = false
            maskpoleD[i, j] = false
        end
    end

    return maskeqL, maskeqR, maskpoleU, maskpoleD
end
# ---- Findind all the black pixels in the image created by mask and converting them to white----
function findallblack(maskeqL, maskeqR, maskpoleU, maskpoleD)
    img_turn_eqL=findall(p -> p ==RGB{N0f8}(0.0,0.0,0.0), maskeqL)
    maskeqL[img_turn_eqL].=true
    img_turn_eqR=findall(p -> p ==RGB{N0f8}(0.0,0.0,0.0), maskeqR)
    maskeqR[img_turn_eqR].=true
    img_turn_poleU=findall(p -> p ==RGB{N0f8}(0.0,0.0,0.0), maskpoleU)
    maskpoleU[img_turn_poleU].=true
    img_turn_poleD=findall(p -> p ==RGB{N0f8}(0.0,0.0,0.0), maskpoleD)
    maskpoleD[img_turn_poleD].=true
    return maskeqL, maskeqR, maskpoleU, maskpoleD
end

# ---- Process One Frame below a threshold_value----
function process_frame(frame, maskeqL, maskeqR, maskpoleU, maskpoleD, threshold)
    cropped = frame[y_min:y_max, x_min:x_max]
    maskeqL, maskeqR, maskpoleU, maskpoleD = cropped .* maskeqL, cropped .* maskeqR, cropped .* maskpoleU, cropped .* maskpoleD
    maskeqL, maskeqR, maskpoleU, maskpoleD = findallblack(maskeqL, maskeqR, maskpoleU, maskpoleD)
    # Convert to grayscale
    grayL = channelview(ColorTypes.Gray.(maskeqL))
    grayR = channelview(ColorTypes.Gray.(maskeqR))
    grayU = channelview(ColorTypes.Gray.(maskpoleU))
    grayD = channelview(ColorTypes.Gray.(maskpoleD))

    # Find dark pixels
    blackeqL = findall(p -> 0 ≤ p ≤ threshold, grayL)
    blackeqR = findall(p -> 0 ≤ p ≤ threshold, grayR)
    blackpoleU = findall(p -> 0 ≤ p ≤ threshold, grayU)
    blackpoleD = findall(p -> 0 ≤ p ≤ threshold, grayD)

    return length(blackeqL), length(blackeqR), length(blackpoleU), length(blackpoleD)
end

# ---- Main Processing ----
function analyze_video()
    time_start = time()

    io = VideoIO.open(pathVID)
    vid = VideoIO.openvideo(io)

    first_img = first(vid)
    cropped_img = first_img[y_min:y_max, x_min:x_max]
    x0,y0,a,b,theta=analyze_ellipse_and_major_axis(cropped_img) 

    # Save cropped image
    save(pathi * "\\single_ellipse21.png", cropped_img)

    # Generate masks for left/right ellipse regions
    maskeqL, maskeqR, maskpoleU, maskpoleD = create_ellipse_masks(size(cropped_img),x0,y0,a,b,theta)

    # Process all frames
    frame_count = 0
    number, peqL, peqR, poleU, poleD = Int[], Int[], Int[], Int[], Int[]

    for frame in vid
        frame_count += 1
        countL, countR, countU, countD = process_frame(frame, maskeqL, maskeqR, maskpoleU, maskpoleD, 0.45)

        push!(number, frame_count)
        push!(peqL, countL)
        push!(peqR, countR)
        push!(poleU, countU)
        push!(poleD, countD)
    end

    # Save results to CSV
    df = DataFrame(frame=number, peqL=peqL, peqR=peqR, poleU=poleU, poleD=poleD)
    CSV.write(pathVID * name_vid * outfile * ".csv", df)

    println("Processing completed in $(round(time() - time_start; digits=2)) seconds.")
end

# ---- Run Everything ----
analyze_video()
