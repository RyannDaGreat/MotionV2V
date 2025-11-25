demo_video_paths = [
    #"swan_zoom_out.mp4_selected.mp4",
    #"swan_faster.mp4_selected.mp4",
    "swam_freezecam.mp4_selected.mp4",
    "re_penguin.mp4_selected.mp4",
    "pinwheel_newspaper.mp4_selected.mp4",
    "megaphone_left.mp4_selected.mp4",
    #"highway_fastercar_motorcyclechase.mp4_selected.mp4",
    "freeze_candle_cam.mp4_selected.mp4",
    "duck_zoom_cut.mp4_selected.mp4",
    #"don_quixote.mp4_selected.mp4",
    "dograce_corgiwin.mp4_selected.mp4",
    #"cheerleader_2.mp4_selected.mp4",
    "cat_fish.mp4_selected.mp4",
    "car_move_left.mp4_selected.mp4",
    "basketball_2.mp4_selected.mp4",
]
demo_videos = load_videos(demo_video_paths, use_cache=True)
demo_videos = [video[:, 30:] for video in demo_videos]
demo_videos=[demo_video[::2] for demo_video in demo_videos]
arrow_image = load_image("../../arrow.png", use_cache=True)
arrow_image = resize_image_to_fit(arrow_image, height=128)
arrow_image=as_float_image(arrow_image)
arrow_image = with_image_alpha(arrow_image, get_image_alpha(arrow_image)*.8)
arrow_image=as_byte_image(arrow_image)
demo_videos = [
    skia_stamp_video(
        video, [arrow_image], canvas_origin="center", sprite_origin="center"
    )
    for video in eta(demo_videos, "Adding Arrows")
]

demo_pairs=[vertically_concatenated_videos(a,b) for a,b in split_into_sublists(demo_videos,2,keep_remainder=False)]
demo_pairs=[resize_images(x,size=.5) for x in demo_pairs]
full_video = np.concatenate(demo_pairs)

teaser_mp4_path = save_video_mp4(full_video,'teaser/teaser_video.mp4',framerate=15,video_bitrate='max')
teaser_gif_path = convert_to_gif_via_ffmpeg(teaser_mp4_path,framerate=15)

print(teaser_gif_path)

