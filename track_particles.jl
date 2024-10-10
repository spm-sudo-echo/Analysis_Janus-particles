
function track_particles(framerate,filename,pathDEST,mask,vid)

    include("save_data.jl")

    img  = first(vid)
  
    ##--- Creates a blob tracker with the desired parameters ---

    #---- Preprocessor is used , in this case to revert black & white (NIKON) :-----
    function preprocessor(storage, img)
        storage .= Float32.(img)
        #update!(medbg, storage) # update the background model
        storage .= abs.(1 .- img)  # You can save some computation by not calculating a new background image every sample
    end

    bt = BlobTracker(6:8, # array of blob sizes we want to detect
                    3.0, # σw Dynamics noise std. (kalman filter param)
                    10.0,  # σe Measurement noise std. (pixels) (kalman filter param)
                mask=mask, # image processing before the detection
                preprocessor = preprocessor, # image processing before the detection
                 

                  
                    amplitude_th = 0.007, # with less, like 0.007, it may detects false positives
                    correspondence = HungarianCorrespondence(p=0.5, dist_th=4), # dist_th is the number of sigmas away from a predicted location a measurement is accepted.
    )

    #tune_size can be used to automatically tune the size array in bt based on img (the first img of vid). not mandatory.
    #tune_sizes(bt, img)


    result = track_blobs(bt, vid,
                            display = nothing; #Base.display, # use nothing to omit displaying.
                            recorder = Recorder(),) # records result to video on disk


    ##--- Plots trajectories and start-end points for each blob ---

    traces = trace(result, minlife=15) # Filter minimum lifetime of 15
    measurement_traces = tracem(result, minlife=5)
    vid_super=pathDEST*"\\super_vid_"*filename*".avi"

    frame_c=collect(vid)
    #start_frame=1
    #end_frame=size(frame_c,1)
    final_frames=frame_c[start_frame:end_frame,]
    for frame in frame_c
        img= vid[frame]
        println("in the animation")
    img=mask.*img
    drawimg = RGB.(img)
    draw!(drawimg, traces, c=RGB(0,0,0.5))
    draw!(drawimg, measurement_traces, c=RGB(0.5,0,0))
    VideoIO.write(vid_super,drawimg)
    VideoIO.close(vid_super)
    end
    save(pathDEST*"\\tracking_"*filename*".png", drawimg)
    #-----> if you just need the coordinates whitout tracking, use this
    #coords = get_coordinates(bt, vid)


    ##--- Saves data in a dataframe in .csv file. 4 columns: blob ID, time, x and y for each frame.
    #framerate is the frame rate of the video
    #-----> WRITE the ACTUAL framerate as second entry
    resultfilename=pathDEST*"\\coordinates_"*filename*".csv"
    save_data(result,framerate,resultfilename) #the second entry is the framerate, change it if you want to have the proper time in the excel file

end