///fadeframe scrolling
fadeframe += 1

if player_exists() = true && !(parPlayer.dashing or parPlayer.sliding or parPlayer.pounding)
	instance_destroy()

if fadeframe >= trail_lifetime
	instance_destroy()