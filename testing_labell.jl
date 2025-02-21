using Images, ImageMorphology, ImageSegmentation, ImageIO, FileIO, Plots, ImageView

pathi= raw"C:\Users\j.sharma\Scuola Superiore Sant'Anna\Yashpal Singh Brar - 2025\01\30\\"
name= "1000x_2_contrastmax_coaxial_top.jpg"
name1= "flower.jpg"
path= pathi*"\\"*name
 binary_img= load(path)
 
        
# Convert to grayscale if needed
gray_img = Gray.(binary_img) # Converts to grayscale

# Perform connected components labeling (like `cv2.findContours`)
labeled_img = label_components(gray_img .> 0.5)  # Labels all connected objects

# Get properties of the labeled objects
regions = component_lengths(labeled_img)  # Get the size (area) of each region
@show regions
filter
# Display labeled regions
println("Detected regions and their areas: ", regions)

color_map = Dict(label => RGB(rand(), rand(), rand()) for label in regions)
colored_img = colorview(RGB, [color_map[label] for label in labeled_img])
# Highlight detected objects in an output image
output_img = label2rgb(labeled_img)  # Color-code the detected regions
save("output_contours.jpg", output_img)
imshow(colored_img)
