
function track_particles(framerate,filename,pathDEST,mask,vid)

    include("save_data.jl")
    video=vid
    img  = first(vid)
    
    ##--- Creates a blob tracker with the desired parameters ---

    #---- Preprocessor is used , in this case to revert black & white (NIKON) :-----
    function preprocessor(storage, img)
        storage .= Float32.(img)
    #     gray_img = channelview(ColorTypes.Gray.(img))
    #     gaussian_kernel = Kernel.gaussian(50)

    #     background = imfilter(gray_img, gaussian_kernel)
    # background_subtracted = gray_img .- background
    # threshold_value = otsu_threshold(background_subtracted)
    # binary_img = background_subtracted.>threshold_value
        #update!(medbg, storage) # update the background model
        @show storage .= abs.(1 .- img)  # You can save some computation by not calculating a new background image every sample
    end

    bt = BlobTracker(6:8, # array of blob sizes we want to detect
                    3.0, # σw Dynamics noise std. (kalman filter param), increase for faster and noisy blobs
                    10.0,  # σe Measurement noise std. (pixels) (kalman filter param), increase for blurry images
                mask=mask, # image processing before the detection
                preprocessor = preprocessor, # image processing before the detection
                 

                  
                    amplitude_th = 0.01, # with less, like 0.007, it may detects false positives
                    correspondence = HungarianCorrespondence(p=1.0, dist_th=1), # dist_th is the number of sigmas away from a predicted location a measurement is accepted.
    )

    #tune_size can be used to automatically tune the size array in bt based on img (the first img of vid). not mandatory.
    # tune_sizes(bt, img)
    
    result = track_blobs(bt, vid,
                            display = nothing; #Base.display, # use nothing to omit displaying.
                            recorder = Recorder(),) # records result to video on disk


    ##--- Plots trajectories and start-end points for each blob ---

    traces = trace(result, minlife=15) # Filter minimum lifetime of 15
    measurement_traces = tracem(result, minlife=5)
    vid_super=pathDEST*"\\tracked_vid_"*filename*".mp4"

    totf=VideoIO.counttotalframes(vid)
    frame_index = 0
    frames = Array{Array}(undef, totf)
    for frame in video
        frame_index += 1
        frames[frame_index] = frame
    end
    img_one=RGB.(frames[1])
    writer = VideoIO.open_video_out(vid_super,img_one,framerate=framerate)
    for i in 1:totf
        imga=frames[i]
        imga=mask.*imga
        drawimg = RGB.(imga)
        draw!(drawimg, traces, c=RGB(0,0,0.5))
        draw!(drawimg, measurement_traces, c=RGB(0.5,0,0))
        VideoIO.write(writer,drawimg)
        if i==totf
            save(pathDEST*"\\tracking_"*filename*".png", drawimg)
        end
    end 
    close_video_out!(writer)
    VideoIO.close(video)
    VideoIO.close(vid)
  
    #-----> if you just need the coordinates whitout tracking, use this
    #coords = get_coordinates(bt, vid)

    ##--- Saves data in a dataframe in .csv file. 4 columns: blob ID, time, x and y for each frame.
    #framerate is the frame rate of the video
    #-----> WRITE the ACTUAL framerate as second entry
    resultfilename=pathDEST*"\\coordinates_"*filename*".csv"
    save_data(result,framerate,resultfilename) #the second entry is the framerate, change it if you want to have the proper time in the excel file
end