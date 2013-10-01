class SoundBox
  @defaults:
    flashOnly     : false
    flashUrl      : "./assets/dist/swf/player.swf"
    flashObjectId : "soundbox-player"
    flashHtml     : "<object id=\"%id%\" width=\"0\" height=\"0\" classid=\"clsid:d27cdb6e-ae6d-11cf-96b8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab\" type=\"application/x-shockwave-flash\" data=\"%url%\">
                      <param name=\"movie\" value=\"%url%\">
                      <param name=\"allowScriptAccess\" value=\"sameDomain\">
                      <embed name=\"%id%\" width=\"0\" height=\"0\" type=\"application/x-shockwave-flash\" src=\"%url%\" allowScriptAccess=\"sameDomain\">
                    </object>"
                    
  @callbacks:
    onProgress: (percents) ->
      return
    onTimeupdate: (sec) ->
      return
    onVolumeChange: (volume) ->
      return
    onPlay: () ->
      return
    onPause: () ->
      return
    onError: (error) ->
      return

  @util:
    toPercent: (value, total, decimal = 0) ->
      r = Math.pow(10, decimal)
      return Math.round(((value * 100) / total) * r) / r

    fromPercent: (percent, total, decimal = 0) ->
      r = Math.pow(10, decimal)
      return  Math.round(((total / 100) * percent) * r) / r

    humanizeTimer: (time, withHours) ->
      h = Math.floor(time / 3600);
      
      if h < 10 then h = "0" + h
      
      if withHours then m = Math.floor(time / 60 % 60) else m = Math.floor(time / 60)
      if m < 10 then m = "0" + m

      s = Math.floor(time % 60)
      if s < 10 then s = "0" + s

      if withHours
        return h + ':' + m + ':' + s
      else
        return m + ':' + s

  class SoundBox.Sound
    constructor: ->

      @playTypes = 
        flash: 0
        audio: 1

      @audio = new SoundBox.Audioz(
        onProgress      : SoundBox.callbacks.onProgress
        onPlay          : SoundBox.callbacks.onPlay
        onPause         : SoundBox.callbacks.onPause
        onTimeupdate    : SoundBox.callbacks.onTimeupdate
        onVolumeChange  : SoundBox.callbacks.onVolumeChange
        onError         : SoundBox.callbacks.onError
      )
     
      if @audio.isMP3Supported() && !SoundBox.defaults.flashOnly
        @playType = @playTypes.audio
      
      else
        @playType = @playTypes.flash
        @appendFlash()

        SoundBox.callbacks.onReady = =>
          @flash = @getFlashObject()
          @flash.set("src", "") # don't know why but if not set some param init is very slowly :)

    appendFlash: ->
      flashHtml = SoundBox.defaults.flashHtml.replace(/("%url%")/g, SoundBox.defaults.flashUrl+"?v="+Math.random()).replace(/("%id%")/g, SoundBox.defaults.flashObjectId)
      container = document.createElement("div");
      container.innerHTML = flashHtml
      document.getElementsByTagName("body")[0].appendChild(container)

    getFlashObject: ->
      if navigator.appName.indexOf("Microsoft") == -1
        return document[SoundBox.defaults.flashObjectId]
      else
        return window[SoundBox.defaults.flashObjectId]

    play: (url) ->
      if url
        if @playType == @playTypes.flash
          # console.log "flash playing"
          @flash.set("src", url)
          @flash.play()
        else
          # console.log "audio playing"
          @audio.set("src", url)
          @audio.play()
      else
        @audio.play()

    stop: ->
      if @playType == @playTypes.flash
        @flash.stop()
      else 
        @audio.stop()

    togglePause: ->
      if @playType == @playTypes.flash
        @flash.pause()
      else 
        @audio.pause()

    toggleMute: ->
      if @playType == @playTypes.flash
        @flash.mute()
      else 
        @audio.mute()

    seek: (sec) ->
      if @get("src")
        @set("currentTime", sec)

    set: (option, value) ->
      if @playType == @playTypes.flash
        @flash.set(option, value)
      else
        @audio.set(option, value)

    get: (option) ->
      if @playType == @playTypes.flash
        return @flash.get(option)
      else
        return @audio.get(option)

  class SoundBox.Audioz
    constructor: (options)->
      @audio = new Audio()
      @options = options
      @events()

    events: ->
      @audio.addEventListener "timeupdate", (ev) =>
        if typeof @options.onTimeupdate == "function"
          @options.onTimeupdate(@get("currentTime"))

      @audio.addEventListener "progress", (ev) =>
        if typeof @options.onProgress == "function"
          buffered = @timerangeToArray(@get("buffered"))
          if buffered.length > 0
            percents = Math.round(buffered[buffered.length-1].end / @get("duration") * 100)
            @options.onProgress(percents)

      @audio.addEventListener "volumechange", (ev) =>
        if typeof @options.onVolumeChange == "function"
          @options.onVolumeChange(@get("volume") )
      
      @audio.addEventListener "error", (ev) =>
        if typeof @options.onError == "function"
          @options.onError(@get("error"))

      @audio.addEventListener "play", (ev) =>
        if typeof @options.onPlay == "function"
          @options.onPlay()

      @audio.addEventListener "pause", (ev) =>
        if typeof @options.onPause == "function"
          @options.onPause()

    play: ->
      @audio.play()

    stop: ->
      @audio.pause()
      @audio.currentTime = 0

    mute: ->
      @audio.muted = !@audio.muted

    pause: ->
      if !@audio.paused
        @audio.pause()
      else 
        @audio.play()

    set: (option, value) ->
      @audio[option] = value
      return @

    get: (option) ->
      return  @audio[option]

    timerangeToArray: (timeRange) ->
      array = []
      length = timeRange.length - 1
      for i in [0..length]
        array.push(
          start: timeRange.start(i),
          end: timeRange.end(i)
        )
      return array

    isSupported: ->
      return !!@audio.canPlayType;

    isOGGSupported: ->
      return !!@audio.canPlayType && !!@audio.canPlayType('audio/ogg; codecs="vorbis"')

    isWAVSupported: ->
      return !!@audio.canPlayType && !!@audio.canPlayType('audio/wav; codecs="1"')

    isMP3Supported: ->
      return !!@audio.canPlayType && !!@audio.canPlayType('audio/mpeg;')

    isAACSupported: ->
      return !!@audio.canPlayType && !!(@audio.canPlayType('audio/x-m4a;') || !!@audio.canPlayType('audio/aac;'))

new SoundBox()

























