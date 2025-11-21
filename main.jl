##########################################################################################
# For a FASTER run of the code, use more threads in Julia by starting Julia with the command:
# 1. Open Command Prompt or PowerShell.
# 2. Run: set JULIA_NUM_THREADS=4 (temporary for the session).
# 3. For persistence, go to System Properties > Advanced > Environment Variables, and add a new user/system variable.
# 4. Then launch: julia your_script.jl
# 5. In PowerShell, you can chain: $env:JULIA_NUM_THREADS=4; julia your_script.jl

# or alternatively you can start Julia with the command:
# julia -t 4 your_script.jl
# or julia -t auto your_script.jl to use all avialable threads.

# or alternatively, as I am using VS Code as IDE, you can set the number of threads in the settings:
# 1. Go to settings
# 2. Search for julia.NumThreads
# 3. Click on Edit in settings.json
# 4. Add "julia.NumThreads": "auto"  # or set a specific number like "4"

# Check the number of threads in Julia with:
# Threds.nthreads()
#########################################################################################


# This is the end script that incorporates the call to track_particles.jl and MSD_singVid.jl.
# The aim is to have one script that includes all the input variables and path definitions.

using Images, VideoIO, ImageView, FileIO, CSV, DataFrames, Dates, StatsPlots, CategoricalArrays, Plots, NaNStatistics, LsqFit, Statistics, JSON3, FFMPEG, BlobTracking
gr()

include("track_particles.jl")
include("temporal_crop_video.jl")
include("mean_sqr_disp.jl")
include("mean_sqr_disp_cal.jl")
include("velocity_cal.jl")
include("save_data.jl")
include("drift_corr.jl")
start_time = time()
# This loop runs for multiple videos provided they are in the same folder and have the same magnification
folder_path = [raw"C:\Users\y.brar\OneDrive - Scuola Superiore Sant'Anna\Work\Yashpal\2025\11\19\Spaced\exp1\\"]

# Variables for Analysis
diamPart = 3.0  # mean diameter of the particles to be tracked, in microns
um_px = 100/382  # 50/316 for 1000x #50/255 for 800x  #100/382 for 600x #100/251 for 400x         # micron to pixel conversion for Hirox microscope 
framerate = 25         # fps of the video in analysis
pixel_x = 2040  
pixel_y = 1530
# This loop runs for multiple videos provided they are in the same folder and have the same magnification
for folder in folder_path
    println(folder)
    for i in 3:3
        mask = trues(pixel_y, pixel_x)  

        println("Number of threads: ", Threads.nthreads())

        # Path naming for file storage
        filename = "VID00$i"
        pathORIG = folder   # name of the video to be tracked
        folderDEST = "analysis_" * filename   # name of the folder where to store the result of the tracking
        pathDEST = pathORIG * folderDEST   # path of the folder where to store the result of the tracking
        datestamp = Dates.format(now(), "YYYY.mm.dd_HH.MM.SS")  # today's date
        pathDEST = pathDEST * "_" * datestamp
        mkdir(pathDEST)

        println("Reading the desired video.")
        pathVID = pathORIG * filename * ".wmv"   # path of the video to be tracked
        io = VideoIO.open(pathVID)
        vid = VideoIO.openvideo(io)

        img = first(vid)
        imshow(img)
        #Cropping video temporally (uncomment if needed to speed up by reducing frames)
        #println("Cropping the video to the desired limits.")
        #start_frame = 1
        #end_frame = 5 * framerate
        #crop_vid = temporal_crop_video(vid, framerate, start_frame, end_frame, filename, pathDEST) 
        #vid = crop_vid  # Replace original vid with cropped

        println("Tracking the particles.")
        track_particles(framerate, filename, pathDEST, mask, vid)
        println("Calculating MSD.")
        mean_sqr_disp(pathDEST, filename, framerate, um_px, diamPart)
        end_time = time()
        println("Analysis time: ", end_time - start_time)
    end
end