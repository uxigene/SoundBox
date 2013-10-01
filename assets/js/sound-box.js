var SoundBox;

SoundBox = (function() {
  function SoundBox() {}

  SoundBox.defaults = {
    flashOnly: false,
    flashUrl: "./assets/dist/swf/player.swf",
    flashObjectId: "soundbox-player",
    flashHtml: "<object id=\"%id%\" width=\"0\" height=\"0\" classid=\"clsid:d27cdb6e-ae6d-11cf-96b8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab\" type=\"application/x-shockwave-flash\" data=\"%url%\">                      <param name=\"movie\" value=\"%url%\">                      <param name=\"allowScriptAccess\" value=\"sameDomain\">                      <embed name=\"%id%\" width=\"0\" height=\"0\" type=\"application/x-shockwave-flash\" src=\"%url%\" allowScriptAccess=\"sameDomain\">                    </object>"
  };

  SoundBox.callbacks = {
    onProgress: function(percents) {},
    onTimeupdate: function(sec) {},
    onVolumeChange: function(volume) {},
    onPlay: function() {},
    onPause: function() {},
    onError: function(error) {}
  };

  SoundBox.util = {
    toPercent: function(value, total, decimal) {
      var r;
      if (decimal == null) {
        decimal = 0;
      }
      r = Math.pow(10, decimal);
      return Math.round(((value * 100) / total) * r) / r;
    },
    fromPercent: function(percent, total, decimal) {
      var r;
      if (decimal == null) {
        decimal = 0;
      }
      r = Math.pow(10, decimal);
      return Math.round(((total / 100) * percent) * r) / r;
    },
    humanizeTimer: function(time, withHours) {
      var h, m, s;
      h = Math.floor(time / 3600);
      if (h < 10) {
        h = "0" + h;
      }
      if (withHours) {
        m = Math.floor(time / 60 % 60);
      } else {
        m = Math.floor(time / 60);
      }
      if (m < 10) {
        m = "0" + m;
      }
      s = Math.floor(time % 60);
      if (s < 10) {
        s = "0" + s;
      }
      if (withHours) {
        return h + ':' + m + ':' + s;
      } else {
        return m + ':' + s;
      }
    }
  };

  SoundBox.Sound = (function() {
    function Sound() {
      var _this = this;
      this.playTypes = {
        flash: 0,
        audio: 1
      };
      this.audio = new SoundBox.Audioz({
        onProgress: SoundBox.callbacks.onProgress,
        onPlay: SoundBox.callbacks.onPlay,
        onPause: SoundBox.callbacks.onPause,
        onTimeupdate: SoundBox.callbacks.onTimeupdate,
        onVolumeChange: SoundBox.callbacks.onVolumeChange,
        onError: SoundBox.callbacks.onError
      });
      if (this.audio.isMP3Supported() && !SoundBox.defaults.flashOnly) {
        this.playType = this.playTypes.audio;
      } else {
        this.playType = this.playTypes.flash;
        this.appendFlash();
        SoundBox.callbacks.onReady = function() {
          _this.flash = _this.getFlashObject();
          return _this.flash.set("src", "");
        };
      }
    }

    Sound.prototype.appendFlash = function() {
      var container, flashHtml;
      flashHtml = SoundBox.defaults.flashHtml.replace(/("%url%")/g, SoundBox.defaults.flashUrl + "?v=" + Math.random()).replace(/("%id%")/g, SoundBox.defaults.flashObjectId);
      container = document.createElement("div");
      container.innerHTML = flashHtml;
      return document.getElementsByTagName("body")[0].appendChild(container);
    };

    Sound.prototype.getFlashObject = function() {
      if (navigator.appName.indexOf("Microsoft") === -1) {
        return document[SoundBox.defaults.flashObjectId];
      } else {
        return window[SoundBox.defaults.flashObjectId];
      }
    };

    Sound.prototype.play = function(url) {
      if (url) {
        if (this.playType === this.playTypes.flash) {
          this.flash.set("src", url);
          return this.flash.play();
        } else {
          this.audio.set("src", url);
          return this.audio.play();
        }
      } else {
        return this.audio.play();
      }
    };

    Sound.prototype.stop = function() {
      if (this.playType === this.playTypes.flash) {
        return this.flash.stop();
      } else {
        return this.audio.stop();
      }
    };

    Sound.prototype.togglePause = function() {
      if (this.playType === this.playTypes.flash) {
        return this.flash.pause();
      } else {
        return this.audio.pause();
      }
    };

    Sound.prototype.toggleMute = function() {
      if (this.playType === this.playTypes.flash) {
        return this.flash.mute();
      } else {
        return this.audio.mute();
      }
    };

    Sound.prototype.seek = function(sec) {
      if (this.get("src")) {
        return this.set("currentTime", sec);
      }
    };

    Sound.prototype.set = function(option, value) {
      if (this.playType === this.playTypes.flash) {
        return this.flash.set(option, value);
      } else {
        return this.audio.set(option, value);
      }
    };

    Sound.prototype.get = function(option) {
      if (this.playType === this.playTypes.flash) {
        return this.flash.get(option);
      } else {
        return this.audio.get(option);
      }
    };

    return Sound;

  })();

  SoundBox.Audioz = (function() {
    function Audioz(options) {
      this.audio = new Audio();
      this.options = options;
      this.events();
    }

    Audioz.prototype.events = function() {
      var _this = this;
      this.audio.addEventListener("timeupdate", function(ev) {
        if (typeof _this.options.onTimeupdate === "function") {
          return _this.options.onTimeupdate(_this.get("currentTime"));
        }
      });
      this.audio.addEventListener("progress", function(ev) {
        var buffered, percents;
        if (typeof _this.options.onProgress === "function") {
          buffered = _this.timerangeToArray(_this.get("buffered"));
          if (buffered.length > 0) {
            percents = Math.round(buffered[buffered.length - 1].end / _this.get("duration") * 100);
            return _this.options.onProgress(percents);
          }
        }
      });
      this.audio.addEventListener("volumechange", function(ev) {
        if (typeof _this.options.onVolumeChange === "function") {
          return _this.options.onVolumeChange(_this.get("volume"));
        }
      });
      this.audio.addEventListener("error", function(ev) {
        if (typeof _this.options.onError === "function") {
          return _this.options.onError(_this.get("error"));
        }
      });
      this.audio.addEventListener("play", function(ev) {
        if (typeof _this.options.onPlay === "function") {
          return _this.options.onPlay();
        }
      });
      return this.audio.addEventListener("pause", function(ev) {
        if (typeof _this.options.onPause === "function") {
          return _this.options.onPause();
        }
      });
    };

    Audioz.prototype.play = function() {
      return this.audio.play();
    };

    Audioz.prototype.stop = function() {
      this.audio.pause();
      return this.audio.currentTime = 0;
    };

    Audioz.prototype.mute = function() {
      return this.audio.muted = !this.audio.muted;
    };

    Audioz.prototype.pause = function() {
      if (!this.audio.paused) {
        return this.audio.pause();
      } else {
        return this.audio.play();
      }
    };

    Audioz.prototype.set = function(option, value) {
      this.audio[option] = value;
      return this;
    };

    Audioz.prototype.get = function(option) {
      return this.audio[option];
    };

    Audioz.prototype.timerangeToArray = function(timeRange) {
      var array, i, length, _i;
      array = [];
      length = timeRange.length - 1;
      for (i = _i = 0; 0 <= length ? _i <= length : _i >= length; i = 0 <= length ? ++_i : --_i) {
        array.push({
          start: timeRange.start(i),
          end: timeRange.end(i)
        });
      }
      return array;
    };

    Audioz.prototype.isSupported = function() {
      return !!this.audio.canPlayType;
    };

    Audioz.prototype.isOGGSupported = function() {
      return !!this.audio.canPlayType && !!this.audio.canPlayType('audio/ogg; codecs="vorbis"');
    };

    Audioz.prototype.isWAVSupported = function() {
      return !!this.audio.canPlayType && !!this.audio.canPlayType('audio/wav; codecs="1"');
    };

    Audioz.prototype.isMP3Supported = function() {
      return !!this.audio.canPlayType && !!this.audio.canPlayType('audio/mpeg;');
    };

    Audioz.prototype.isAACSupported = function() {
      return !!this.audio.canPlayType && !!(this.audio.canPlayType('audio/x-m4a;') || !!this.audio.canPlayType('audio/aac;'));
    };

    return Audioz;

  })();

  return SoundBox;

})();

new SoundBox();

/*
//@ sourceMappingURL=sound-box.js.map
*/