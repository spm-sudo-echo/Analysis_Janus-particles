using CSV
using DataFrames

# saves data in a dataframe in .csv file. 4 columns: blob ID, time, x and y for each frame.
# framerate is the frame rate of the video
function save_data(result, framerate, resultfilename)
    blobid = Int[]
    time = Float64[]
    coord_x = Float64[]
    coord_y = Float64[]
    for i in eachindex(result.blobs)
        for j in eachindex(result.blobs[i].trace)
            coords = result.blobs[i].trace[j]
            push!(blobid, i)
            push!(time, j / framerate)
            push!(coord_x, coords[2]) # Confirm if x/y swapped based on convention
            push!(coord_y, coords[1])
        end
    end

    # creating DataFrame
    data = DataFrame(BlobID = blobid,
                     Time = time,
                     x = coord_x,
                     y = coord_y) 

    CSV.write(resultfilename, data)
end