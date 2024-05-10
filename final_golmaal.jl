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
um_px =  50/255 #for 800x  #100/382 for 600x         # micron to pixel convertion for Hirox microscope 
framerate = 25          # fps of the video in analysis
pixel_x=2040
pixel_y=1530

mask_x_start=350
mask_x_end=2000

mask_y_start=200
mask_y_end=1500


mask=falses(pixel_y,pixel_x)       # values in pixels 
mask[mask_y_start:mask_y_end,mask_x_start:mask_x_end].=true

#Path naming for file storage
filename="VID005"   # name of the video to be tracked
pathORIG="C:\\Users\\j.sharma\\OneDrive - Scuola Superiore Sant'Anna\\P10 Microfabrication\\Experiments\\2024\\05.May\\07\\exp1\\"   # path of the folder containing the video to be tracked
folderDEST="analysis_"*filename   # name of the folder where to store the result of the tracking
pathDEST=pathORIG*folderDEST   # path of the folder where to store the result of the tracking
datestamp=Dates.format(now(),"YYYY.mm.dd_HH.MM.SS")  # todays date
pathDEST=pathDEST*"_"*datestamp
mkdir(pathDEST)


pathVID=pathORIG*filename*".wmv"
io   = VideoIO.open(pathVID)
vid  = VideoIO.openvideo(io)
#video_frames = VideoIO.load(pathVID)

img= first(vid)# video_frames[70]
imshow(img)
#Cropping video temporally
#
start_frame=1*framerate
#end_frame=size(collect(vid),1)
end_frame= 47*framerate
crop_vid = temporal_crop_video(vid,framerate,start_frame,end_frame,filename,pathDEST) 
vid_crop=crop_vid
#
#track particle call
track_particles(framerate,filename,pathDEST,mask,vid_crop)

#mean_sqr_disp.jl variables
#folder input corresponnds to pathDEST
mean_sqr_disp(pathDEST,filename,framerate,um_px,diamPart)

#fitting_linear(pathDEST,filename,diamPart)
