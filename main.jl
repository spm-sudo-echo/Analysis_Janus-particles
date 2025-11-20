# This is the end scrip that incorporates the call to track_paticles.jl and MSD_singVid.jl.
#The aim is to have one script that includes all the input variables and path definitions.

using Images, VideoIO, CSV, DataFrames, Dates, Plots, NaNStatistics, Statistics, JSON3, FFMPEG, BlobTracking
gr()  

#BlobTracking.PROGRESS[1] = false
include("track_particles.jl")
include("mean_sqr_disp.jl")
include("mean_sqr_disp_cal.jl")
include("drift_corr.jl")
include("temporal_crop_video.jl")

# This loop runs for multiple videos provided they are in the same folder and have the same magnification
folder_path = [raw"C:\Users\y.brar\OneDrive - Scuola Superiore Sant'Anna\Work\Yashpal\2025\11\19\Control\exp2\\"]   

#Varaibales for Analysis
diamPart = 3.0  # mean diameter of the particles to be tracked, in microns
um_px = 100/382  # 50/316 for 1000x #50/255 for 800x  #100/382 for 600x #100/251 for 400x         # micron to pixel convertion for Hirox microscope 
framerate = 25  # fps of the video in analysis
pixel_x = 2040
pixel_y = 1530

video_indices = 1:1  # Flexible: Adjust this range or list for multiple videos, e.g., [1,2,3,5]

# This loop runs for multiple videos provided they are in the same folder and have the same magnification

for folder in folder_path
    println(folder)
    for i in video_indices
        start_time = time()

        filename = "VID" * lpad(string(i), 3, '0')
        datestamp = Dates.format(now(), "YYYY.mm.dd_HH.MM.SS")
        pathDEST = folder * "\\analysis_" * filename * "_" * datestamp # path of the folder where to store the result of the tracking
        mkdir(pathDEST)

        println("Reading the desired video.")
        pathVID = joinpath(folder, filename * ".wmv")   # path of the video to be tracked
        io = VideoIO.open(pathVID)
        vid = VideoIO.openvideo(io)

        mask = trues(pixel_y, pixel_x)

        #Cropping video temporally
        println("Cropping the video to the desired limits.")
        #start_frame=1*framerate
        start_frame=1 #*framerate
        # #end_frame=size(collect(vid),1)
        end_frame= 1*framerate
        crop_vid = temporal_crop_video(vid,framerate,start_frame,end_frame,filename,pathDEST) 
        vid_crop=crop_vid
        VideoIO.close(vid)

        println("Tracking the particles.")
        #track_particles(framerate, filename, pathDEST, mask, vid)
        track_particles(framerate, filename, pathDEST, mask, vid_crop)

        println("Calculating MSD.")
        mean_sqr_disp(pathDEST, filename, framerate, um_px, diamPart)

        VideoIO.close(io)
        end_time = time()
        println("Analysis time: ", end_time - start_time)
    end
end


#fitting_linear(pathDEST,filename,diamPart)

# filenome="VID001"   # name of the video to be tracked
# framerate = 25          # fps of the video in analysis
# um_px=50/316 
# diamPart=3  # mean diameter of the particles to be tracked, in microns
# pathDEST= "C:\\Users\\j.sharma\\OneDrive - Scuola Superiore Sant'Anna\\P10 Microfabrication\\Experiments\\2024\\11.November\\18\\exp1\\analysis_VID001_2024.11.19_13.42.52\\"
# #folder input corresponnds to pathDEST
# mean_sqr_disp(pathDEST,filenome,framerate,um_px,diamPart)
#velocity_cal(pathDEST,filename,diamPart)
