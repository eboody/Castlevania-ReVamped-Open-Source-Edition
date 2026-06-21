/// @description clear stale pixels before room drawing
// The 20:9 build uses a wider application surface.  Clear every frame so
// pixels from previous rooms/camera states cannot survive in pillar areas.
draw_clear(c_black);
