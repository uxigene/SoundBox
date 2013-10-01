$(function() {
	SoundBox.defaults.flashOnly = false
	SoundBox.callbacks.onProgress = function(percents){
		$("#buffer-progress").css("width", percents+"%")
	};
	SoundBox.callbacks.onTimeupdate = function(sec) {
		percents = SoundBox.util.toPercent(sec, sound.get("duration"))
		time = SoundBox.util.humanizeTimer(sec)
		total = SoundBox.util.humanizeTimer(sound.get("duration"))
		$("#timer").html(time +" / "+ total)
		$("#play-progress").css("width", percents+"%")
	};
	SoundBox.callbacks.onVolumeChange = function(volume){

	};
	SoundBox.callbacks.onPlay = function(){
		$("#pause").removeClass("active")
	};
	SoundBox.callbacks.onPause = function(){
		$("#pause").addClass("active")
	};
	SoundBox.callbacks.onError = function(error){
		
	};

	var sound = new SoundBox.Sound()

	$("#play").on("click", function(ev) {
		sound.play("/my_sound.mp3")
	})

	$("#pause").on("click", function(ev) {
		sound.togglePause()
	})

	$("#stop").on("click", function(ev) {
		sound.stop()
	})

	$("#mute").on("click", function(ev) {
		sound.toggleMute()
		$(this).toggleClass("active")
	})

	$("#progress").on("click", function(ev) {
		percents = (ev.clientX - ev.currentTarget.offsetLeft) / ev.currentTarget.clientWidth * 100
		duration =  sound.get("duration")
		sec = SoundBox.util.fromPercent(percents, duration)
		sound.seek(sec)
	})
})