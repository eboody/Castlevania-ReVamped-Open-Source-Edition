/// @description die to morningstar!
if other.flavor > 0
{
	bitsound(sndBlockBreak)
	scrStartScreenshake(48,0.7)
	instance_destroy()
}
else
	destroy_tile()