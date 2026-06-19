/// @description sfx + die
if other.object_index = objWhip
{
	bitsound(sndBlockBreak)
	scrStartScreenshake(48,0.7)
	instance_destroy()
}
else
	destroy_tile()