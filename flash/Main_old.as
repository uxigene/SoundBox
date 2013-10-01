package 
{

	import flash.display.MovieClip;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.SoundChannel;
	import flash.utils.setInterval;

	public class Main extends MovieClip
	{
		var mySoundTransform:SoundTransform = new SoundTransform();
		var mySound:Sound = null;
		var mySoundChannel:SoundChannel = null;
		var pausePoint:Number = 0.00;
		var isPlaying:Boolean;
		var prevVolume:Number = 1;
		var percent:Number = 0;
		public function Main()
		{
			ExternalInterface.call("Player.callbacks.flashInit");
			ExternalInterface.addCallback("startPlay",startPlay);
			ExternalInterface.addCallback("stopPlay",stopPlay);
			ExternalInterface.addCallback("resumePlay",resumePlay);
			ExternalInterface.addCallback("togglePause",togglePause);
			ExternalInterface.addCallback("setVolume",setVolume);
			ExternalInterface.addCallback("seekTrack",seekTrack);
			setInterval(function() {
				if(isPlaying) {
					var playProgress:Number = mySoundChannel.position / mySound.length * percent;
					ExternalInterface.call("Player.callbacks.playProgress",playProgress, mySoundChannel.position)
				};
			},100);
		}
		private function startPlay(url):void
		{
			//mySound.close();
			mySound = null;
			mySound = new Sound();
			mySound.load(new URLRequest(url));
			if (mySoundChannel != null)
			{
				mySoundChannel.stop();
				mySoundChannel = null;
			}
			mySoundChannel = new SoundChannel();
			mySoundChannel = mySound.play();
			mySoundChannel.soundTransform = mySoundTransform;

			mySound.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			mySound.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			isPlaying = true;
		}
		private function seekTrack(percents):void
		{
			stopPlay();
			pausePoint = (mySound.length * percent) / 10000 * percents;
			resumePlay();
		}
		private function stopPlay():void
		{
			mySoundChannel.stop();
			pausePoint = 0;
			isPlaying = false;
		}
		private function resumePlay():void
		{
			if (! isPlaying)
			{
				mySoundChannel = mySound.play(pausePoint);
				mySoundChannel.soundTransform = mySoundTransform;
				isPlaying = true;
			}
		}
		private function togglePause():void
		{
			if (isPlaying)
			{
				pausePoint = mySoundChannel.position;
				mySoundChannel.stop();
				isPlaying = false;
			}
			else
			{
				mySoundChannel = mySound.play(pausePoint);
				mySoundChannel.soundTransform = mySoundTransform;
				isPlaying = true;
			}
		}
		private function setVolume(value):void
		{
			mySoundTransform.volume = value;
			mySoundChannel.soundTransform = mySoundTransform;
		}
		private function progressHandler(event:ProgressEvent):void
		{
			percent = Math.round(event.bytesLoaded / event.bytesTotal * 100);
			ExternalInterface.call("Player.callbacks.downloadProgress",percent);
		}

		private function errorHandler(errorEvent:IOErrorEvent):void
		{
			ExternalInterface.call("Player.callbacks.errorHandler",errorEvent.text);
		}
	}
}