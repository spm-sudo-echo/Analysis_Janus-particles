function monolayer_analysis(binary_img; defect_size_threshold, multilayer_size_threshold)
    # Step 1: Identify connected components
    labeled_img = label_components(binary_img) 
 unique_labels = unique(labeled_img)[2:end]  # Exclude background (label 0)
    # imshow(binary_img)
    # Create defect and multilayer masks
    defect_mask = falses(size(binary_img))
    multilayer_mask = falses(size(binary_img))
    
    for label in unique_labels
        # Find indices of current component
       component_indices = findall(labeled_img .== label)
    component_size = length(component_indices)
        
        # if component_size <= defect_size_threshold
        #     # Mark as defect
        #     for idx in component_indices
        #         defect_mask[Tuple(idx)...] = true
        #     end
        # elseif component_size >= multilayer_size_threshold
        #     # Mark as multilayer
        #     for idx in component_indices
        #         multilayer_mask[Tuple(idx)...] = true
        #     end
        # end
        if component_size >= 1 && component_size <= defect_size_threshold
            # Mark as particle
            for idx in component_indices
                defect_mask[Tuple(idx)...] = true
            end
        end
        # if component_size >= 1 && component_size <= 100
        #     # Mark as particle
        #     for idx in component_indices
        #         multilayer_mask[Tuple(idx)...] = true
        #         println("in multilayer mask")
        #     end
        # end
    end
    
    # Step 2: Superimpose the masks onto the original binary image
    combined_img = RGB.(binary_img)
    for idx in findall(defect_mask)
        combined_img[Tuple(idx)...] = RGB(1.0, 0.0, 0.0)  # Red for defects
    end
    # for idx in findall(multilayer_mask)
    #     combined_img[Tuple(idx)...] = RGB(0.0, 0.0, 1.0)  # Blue for multilayers
    # end
    
    return combined_img, defect_mask, multilayer_mask
end

# function monolayer_analysis(binary_img, max_radius)
#     # Label the connected components in the binary image
#     labeled_img = label_components(binary_img)
#     unique_labels = unique(labeled_img)[2:end]  # Exclude label 0 (background)
    
#     # Create a copy of the binary image for modifications
#     cleaned_img = copy(binary_img)
    
#     for label in unique_labels
#         # Get the indices of the current component
#         component_indices = findall(labeled_img .== label)
        
#         # Calculate the area of the component
#         area = length(component_indices)
        
#         # Estimate the equivalent radius (assume the component is circular)
#         equivalent_radius = sqrt(area / π)
        
#         # Remove the component if the radius is <= max_radius
#         if equivalent_radius <= max_radius
#             for idx in component_indices
#                 cleaned_img[Tuple(idx)...] = 0  # Convert CartesianIndex to Tuple
#             end
#         end
#     end
    
#     return cleaned_img
# end
