/// @description final GUI-space black-bar mask
// Some GUI/end-draw/post-processing code can draw after the world Draw End pass.
// Paint the safe-area bars again in GUI coordinates as the last mask so spillover
// cannot remain visible in the pillarbox/letterbox regions.
aspect_draw_black_bars_gui();
