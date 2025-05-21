# This is the end scrip that incorporates the call to track_paticles.jl and MSD_singVid.jl.
#The aim is to have one script that includes all the input variables and path definitions.

using Images, VideoIO, ImageView, FileIO, CSV, DataFrames, Dates, StatsPlots, CategoricalArrays, Plots, NaNStatistics, LsqFit, Statistics, JSON3, FFMPEG, BlobTracking

gr()  

include("track_particles.jl")
include("temporal_crop_video.jl")
include("mean_sqr_disp.jl")
include("velocity_cal.jl")

#Variables for Analysis
diamPart=1.3  # mean diameter of the particles to be tracked, in microns
um_px =  50/316 # for 1000x#50/255 for 800x  #100/382 for 600x         # micron to pixel convertion for Hirox microscope 
framerate = 25         # fps of the video in analysis
pixel_x=2040   
pixel_y=1530
# This loop runs for multiple videos provided they are in the same folder and have the same magnification
for i in 1:1

# mask_x_start=502
# mask_x_end=2000

# mask_y_start=800
# mask_y_end=1500
#  mask=falses(pixel_y,pixel_x)       # values in pixels 
# mask[mask_y_start:mask_y_end,mask_x_start:mask_x_end].=true
 mask=trues(pixel_y,pixel_x)  

#Path naming for file storage

filename="VID00$i"   # name of the video to be tracked
pathORIG="C:\\Users\\j.sharma\\Scuola Superiore Sant'Anna\\Microscale Robotics Laboratory - DATA_2025 - DATA_2025\\Data\\HRX_Hirox-microscope\\P19\\03.March\\27032025\\PDA_Pd_0%\\"   # path of the folder containing the video to be tracked""C:\\Users\\j.sharma\\OneDrive - Scuola Superiore Sant'Anna\\P10 Microfabrication\\Experiments\\2024\\05.May\\07\\exp1\\"   # path of the folder containing the video to be tracked
folderDEST="analysis_"*filename   # name of the folder where to store the result of the tracking
pathDEST=pathORIG*folderDEST   # path of the folder where to store the result of the tracking
datestamp=Dates.format(now(),"YYYY.mm.dd_HH.MM.SS")  # todays date
pathDEST=pathDEST*"_"*datestamp
mkdir(pathDEST)

println("Reading the desired video.")
pathVID=pathORIG*filename*".wmv"   # path of the video to be tracked
io   = VideoIO.open(pathVID)
vid  = VideoIO.openvideo(io)
#video_frames = VideoIO.load(pathVID)

img= first(vid)# video_frames[70]
imshow(img)
# #Cropping video temporally
# println("Cropping the video to the desired limits.")
# #start_frame=1*framerate
# start_frame=1 #*framerate
# #end_frame=size(collect(vid),1)
# end_frame= 10#2*framerate
# crop_vid = temporal_crop_video(vid,framerate,start_frame,end_frame,filename,pathDEST) 
# vid_crop=crop_vid
# VideoIO.close(vid)

#track particle call
println("Tracking the particles.")
track_particles(framerate,filename,pathDEST,mask,vid)

#mean_sqr_disp.jl variables

#pathDEST= "C:\\Users\\j.sharma\\OneDrive - Scuola Superiore Sant'Anna\\P10 Microfabrication\\Experiments\\2024\\05.May\\07\\exp1\\analysis_VID005_2024.05.10_15.50.10\\"
#folder input corresponnds to pathDEST
println("Calculating MSD.")
mean_sqr_disp(pathDEST,filename,framerate,um_px,diamPart)
end
#fitting_linear(pathDEST,filename,diamPart)

# filenome="VID001"   # name of the video to be tracked
# framerate = 25          # fps of the video in analysis
# um_px=50/316 
# diamPart=3  # mean diameter of the particles to be tracked, in microns
# pathDEST= "C:\\Users\\j.sharma\\OneDrive - Scuola Superiore Sant'Anna\\P10 Microfabrication\\Experiments\\2024\\11.November\\18\\exp1\\analysis_VID001_2024.11.19_13.42.52\\"
# #folder input corresponnds to pathDEST

# mean_sqr_disp(pathDEST,filenome,framerate,um_px,diamPart)
# velocity_cal(pathDEST,filenome,diamPart)
