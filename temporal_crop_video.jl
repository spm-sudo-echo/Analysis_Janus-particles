#To crop the video on the time scale, reducing the number of frames analysed.

function temporal_crop_video(vid,framerate,start_frame,end_frame,filename,pathDEST) 

    vid_cured=pathDEST*"\\cropped_vid_"*filename*".avi"

    frame_c=collect(vid)
    #start_frame=1
    #end_frame=size(frame_c,1)
    final_frames=frame_c[start_frame:end_frame,]
    VideoIO.save(vid_cured, final_frames,framerate=framerate)
    crop_io=VideoIO.open(vid_cured)
    crop_vid=VideoIO.openvideo(crop_io)

    return crop_vid
    
end