# This is the end scrip that incorporates the call to track_paticles.jl and MSD_singVid.jl.
#The aim is to have one script that includes all the input variables and path definitions.

using BlobTracking, Images, VideoIO, ImageView, FileIO, CSV, DataFrames, Dates
using StatsPlots, CategoricalArrays, Plots, NaNStatistics, LsqFit, CurveFit, Statistics, JSON3

gr()  

include("track_particles.jl")
include("temporal_crop_video.jl")
include("mean_sqr_disp.jl")
#Varaibales for Analysis
diamPart=3  # mean diameter of the particles to be tracked, in microns
um_px = 50/157          # micron to pixel convertion for Hirox microscope using the mid objective with 1000x lens (1/6.32)
framerate = 12          # fps of the video in analysis
pixel_x=1020
pixel_y=764

mask_x_start=1
mask_x_end=1020

mask_y_start=120
mask_y_end=580


mask=falses(pixel_y,pixel_x)       # values in pixels 
mask[mask_y_start:mask_y_end,mask_x_start:mask_x_end].=true

#Path naming for file storage
filename="VID009"   # name of the video to be tracked
pathORIG="C:\\Users\\y.brar\\Scuola Superiore Sant'Anna\\Jyoti Sharma - 09\\exp1\\"   # path of the folder containing the video to be tracked
folderDEST="analysis_"*filename   # name of the folder where to store the result of the tracking
pathDEST="C:\\Users\\y.brar\\Scuola Superiore Sant'Anna\\Jyoti Sharma - 09\\exp1\\" *folderDEST   # path of the folder where to store the result of the tracking
datestamp=Dates.format(now(),"YYYY.mm.dd_HH.MM.SS")  # todays date
pathDEST=pathDEST*"_"*datestamp
mkdir(pathDEST)


pathVID=pathORIG*filename*".avi"
io   = VideoIO.open(pathVID)
vid  = VideoIO.openvideo(io)
#video_frames = VideoIO.load(pathVID)

#img  = video_frames[70]
#imshow(img)
#Cropping video temporally
#
start_frame=5*12
#end_frame=size(collect(vid),1)
end_frame= 60*12
crop_vid = temporal_crop_video(vid,framerate,start_frame,end_frame,filename,pathDEST) 
vid_crop=crop_vid
#
#track particle call
track_particles(framerate,filename,pathDEST,mask,vid_crop)

#mean_sqr_disp.jl variables
#folder input corresponnds to pathDEST
mean_sqr_disp(pathDEST,filename,framerate,um_px,diamPart)

