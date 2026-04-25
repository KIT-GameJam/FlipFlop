extends AudioStreamPlayer2D

func play_sfx(sfx: AudioStreamMP3):
	if playing:
		if stream == sfx:
			return
		else:
			stop()
	stream = sfx
	play()

func stop_sfx():
	if playing:
		stop()
