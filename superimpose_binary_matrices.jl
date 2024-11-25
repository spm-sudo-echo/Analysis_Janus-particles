function superimpose_binary_matrices(A, B)
    # Ensure A and B are the same size
    if size(A) != size(B)
        throw(ArgumentError("Matrices A and B must have the same dimensions."))
    end

    # Create an empty RGB image
    x, y = size(A)
    combined_img = fill(RGB(0, 0, 0), x, y)  # Start with a black image

    # Iterate over each pixel
    for i in 1:x, j in 1:y
        if A[i, j] == 1 && B[i, j] == 1
            combined_img[i, j] = RGB(1, 1, 1)  # White for overlap
        elseif A[i, j] == 1
            combined_img[i, j] = RGB(0, 0, 0)  # black for A
        elseif B[i, j] == 1
            combined_img[i, j] = RGB(0, 1, 0)  # Green for B
        end
    end

    return combined_img
end
