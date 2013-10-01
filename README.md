SoundBox
========

HTML5 audio library where supported and optional Flash-based fallback

Options
===============

SoundBox.defaults.flashOnly 	: true/false
SoundBox.defaults.flashUrl 		: flash audio player url for fallback

Callbacks
=========

SoundBox.callbacks.onProgress 		: firing if sound is downloading and returns percnts
SoundBox.callbacks.onTimeupdate 	: firing if soind if playing and return current time
SoundBox.callbacks.onVolumeChange 	: firing when volume is change
SoundBox.callbacks.onPlay 			: firing when playing starts
SoundBox.callbacks.onPause 			: firing when sound is start or stop
SoundBox.callbacks.onError 			: firing if some error occurred 

Utils
=====

SoundBox.utils.toPercent(value, total, decimal)
SoundBox.utils.toPercent(value, total, decimal)
SoundBox.utils.humanizeTimer(time, withHours)