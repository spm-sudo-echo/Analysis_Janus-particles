using BlobTracking, Images, VideoIO, ImageView, FileIO, CSV, DataFrames
include("save_data.jl")

##--- INSERT: opens the video, creates a iterable stack of frames stored in "vid"
filename="VID006"   # name of the video to be tracked
pathORIG="C:\\Users\\j.sharma\\OneDrive - Scuola Superiore Sant'Anna\\P10 Microfabrication\\Experiments\\2024\\04.April\\09\\exp1\\"   # path of the folder containing the video to be tracked
folderDEST="tracking_results"   # name of the folder where to store the result of the tracking
pathDEST="C:\\Users\\j.sharma\\OneDrive - Scuola Superiore Sant'Anna\\P10 Microfabrication\\Experiments\\2024\\04.April\\09\\exp1\\" *folderDEST   # path of the folder where to store the result of the tracking

#-------------------------------------------------------------------------------

pathTOT=pathORIG*filename*".avi"
io   = VideoIO.open(pathTOT)
vid  = VideoIO.openvideo(io)
img  = first(vid)
imshow(img)
##--- Creates a blob tracker with the desired parameters ---
##
vid_cured=pathORIG*"cropped_vid.avi"

frame_c=collect(vid)
start_frame=1
end_frame=size(frame_c,1)
final_frames=frame_c[start_frame:end_frame,]
VideoIO.save(vid_cured, final_frames,framerate=12)
crop_io=VideoIO.open(vid_cured)
crop_vid=VideoIO.openvideo(crop_io)


##
#----- In this case mask is used to discard the part of the video showing the legend (Hirox) ---- if Mask is not required COMMENT IT INSIDE bt!!
#mask=trues(1530,2040)       # values in pixels 
#mask[1300:1530,1700:2040].=false

mask=falses(764,1020)       # values in pixels 
mask[140:560,1:1020].=true

crop_img=mask.*final_frames[1]

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
                amplitude_th = 0.008, # with less, like 0.007, it may detects false positives
                correspondence = HungarianCorrespondence(p=0.5, dist_th=4), # dist_th is the number of sigmas away from a predicted location a measurement is accepted.
)

#tune_size can be used to automatically tune the size array in bt based on img (the first img of vid). not mandatory.
#tune_sizes(bt, img)


result = track_blobs(bt, crop_vid,
                        display = nothing; #Base.display, # use nothing to omit displaying.
                        recorder = Recorder(),) # records result to video on disk


##--- Plots trajectories and start-end points for each blob ---

traces = trace(result, minlife=15) # Filter minimum lifetime of 15
measurement_traces = tracem(result, minlife=5)
drawimg = RGB.(crop_img)
draw!(drawimg, traces, c=RGB(0,0,0.5))
draw!(drawimg, measurement_traces, c=RGB(0.5,0,0))

save(pathDEST*"tracking_"*filename*".png", drawimg)
#-----> if you just need the coordinates whitout tracking, use this
#coords = get_coordinates(bt, vid)


##--- Saves data in a dataframe in .csv file. 4 columns: blob ID, time, x and y for each frame.
#framerate is the frame rate of the video
#-----> WRITE the ACTUAL framerate as second entry
resultfilename=pathDEST*"coordinates_"*filename*".csv"
save_data(result,20,resultfilename) #the second entry is the framerate, change it if you want to have the proper time in the excel file

