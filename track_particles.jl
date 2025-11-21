function track_particles(framerate, filename, pathDEST, mask, vid,  um_px, diamPart)
    img = first(vid)
    
    ##--- Creates a blob tracker with the desired parameters ---
    #---- Preprocessor is used, in this case to revert black & white -----
    function preprocessor(storage, img)
        storage .= Float32.(img)
        storage .= abs.(1 .- img)  # Invert; adjust if background is dark
    end

    # ADDED: Compute dynamic blob size range based on um_px and diamPart
    pixel_diam = diamPart / um_px  # Expected diameter in pixels
    min_factor = 0.8  # Adjust lower bound (e.g., 0.7 for smaller variations)
    max_factor = 1.2  # Adjust upper bound (e.g., 1.1 to ignore doublets more strictly)
    min_size = max(5, floor(Int, pixel_diam * min_factor))  # Ensure minimum reasonable size
    max_size = ceil(Int, pixel_diam * max_factor)
    if max_size - min_size < 3  # Ensure a minimum range width
        max_size = min_size + 4
    end
    blob_range = min_size:max_size
    println("Computed blob size range: $blob_range (based on pixel_diam ≈ $(round(pixel_diam, digits=2)))")  # For debugging

    bt = BlobTracker(blob_range, # array of blob sizes we want to detect
                     3.0, # σw Dynamics noise std. (kalman filter param), increase for faster and noisy blobs
                     10.0,  # σe Measurement noise std. (pixels) (kalman filter param), increase for blurry images
                     mask = mask, # image processing before the detection
                     preprocessor = preprocessor,                 
                     amplitude_th = 0.005, # with less, like 0.007, it may detects false positives
                     correspondence = HungarianCorrespondence(p=1.0, dist_th=1), # dist_th is the number of sigmas away from a predicted location a measurement is accepted.
    )

    result = track_blobs(bt, vid,
                         display = nothing, # Use Base.display if visualization needed during tracking
                         recorder=nothing,  # No recording (add Recorder if needed, but it adds overhead)
                         threads=true,  # Enable multi-threading (start Julia with multiple threads)
                         ignoreempty=true  # Skip processing empty frames
    )

    ##--- Plots trajectories and start-end points for each blob ---
    traces = trace(result, minlife=5) # Filter minimum lifetime of 5 frames
    measurement_traces = tracem(result, minlife=5)
    vid_super = pathDEST * "\\tracked_vid_" * filename * ".mp4"

    totf = VideoIO.counttotalframes(vid)
    seekstart(vid)  # Reset to beginning without reloading
    img_one = RGB.(first(vid))
    writer = VideoIO.open_video_out(vid_super, img_one, framerate=framerate)
    i = 0
    drawimg = []
    for frame in vid
        i += 1
        imga = mask .* frame
        drawimg = RGB.(imga)
        draw!(drawimg, traces, c=RGB(0,0,0.5))
        draw!(drawimg, measurement_traces, c=RGB(0.5,0,0))
        VideoIO.write(writer, drawimg)
    end
    save(pathDEST * "\\tracking_" * filename * ".png", drawimg)
    close_video_out!(writer)
    VideoIO.close(vid)
  
    ##--- Saves data in a dataframe in .csv file. 4 columns: blob ID, time, x and y for each frame.
    resultfilename = pathDEST * "\\coordinates_" * filename * ".csv"
    save_data(result, framerate, resultfilename) # the second entry is the framerate
end