SoundBox
========

HTML5 audio library where supported and optional Flash-based fallback

Options
=======


	SoundBox.defaults.flashOnly = true/false, deafult = false
	SoundBox.defaults.flashUrl 	= "flash audio player url for fallback", default = "./assets/dist/swf/player.swf"


Callbacks
=========
	SoundBox.callbacks.onProgress = function(percents){
		// firing when sound is downloading
	};
	
	SoundBox.callbacks.onTimeupdate = function(sec) {
		// firing when soind if playing
	};
	
	SoundBox.callbacks.onVolumeChange = function(volume){
		// firing when volume is change
	};
	
	SoundBox.callbacks.onPlay = function(){
		// firing when playing starts
	};
	
	SoundBox.callbacks.onPause = function(){
		// firing when sound is start or stop
	};
	
	SoundBox.callbacks.onError = function(error){
		// firing if some error occurred 
	};

Utils
=====

	SoundBox.utils.toPercent(value, total, decimal)
	SoundBox.utils.toPercent(percent, total, decimal)
	SoundBox.utils.humanizeTimer(time, withHours)

Constructor
===========
	var sound = var sound = new SoundBox.Sound()

Methods
=======

	sound.play() or sound.play(url) - play sound
	
	sound.stop() - stop sound
	
	sound.togglePause() - toggle pause sound
	
	sound.seek(seconds) - seek sound

Getters and setters
===================

	sound.set(property, value) - Directly set the native properties of an HTML5 audio element
	
	sound.get(property) - Directly get the native properties of an HTML5 audio element

NOTE:
	In flash available properties are:
	src, volume, currentTime, duration (readonly)




