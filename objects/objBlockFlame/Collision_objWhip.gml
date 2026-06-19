/// @description die to morningstar!
if other.flavor = 2
{
	bitsound(sndBlockBreak)
	scrStartScreenshake(48,0.7)
	instance_destroy()
}
else
	destroy_tile()