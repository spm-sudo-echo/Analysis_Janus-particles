# To crop the video on the time scale, reducing the number of frames analysed.
function temporal_crop_video(vid, framerate, start_frame, end_frame, filename, pathDEST) 
    vid_cured = pathDEST * "\\cropped_vid_" * filename * ".avi"
    seekstart(vid)
    writer = nothing
    current_frame = 0
    for frame in vid
        current_frame += 1
        if current_frame < start_frame
            continue
        end
        if current_frame > end_frame
            break
        end
        if writer === nothing
            writer = VideoIO.open_video_out(vid_cured, RGB.(frame), framerate=framerate)
        end
        VideoIO.write(writer, RGB.(frame))
    end
    if writer !== nothing
        close_video_out!(writer)
    end
    crop_io = VideoIO.open(vid_cured)
    crop_vid = VideoIO.openvideo(crop_io)
    return crop_vid
end