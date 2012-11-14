$ = jQuery

Scroller = 
   _create: () ->
      text = this.element.text()
      this.element.empty().addClass("scrolling-text").append("<div class='cover'></div>")
      textWrap = $("<div class='text-wrap'></div>").appendTo(this.element)
      this.options._first = $("<span class='text'>" + text + "</span>").appendTo(textWrap)
      this.options._second = $("<span class='text'>" + text + "</span>").appendTo(textWrap)

   start: () ->
      this.options._first.css { "left": this.options.start_offset}
      this.options._second.css "left", this.options.start_offset + this.options._first.width() + this.options.space_offset
      this._resetFirst()
      this._resetSecond()

   stop: () ->
      this.options._first.stop true
      this.options._second.stop true

   _startScroll: (current, next, cb) ->
      self = this
      width = current.width()
      offset = current.position().left

      current.animate { left: -1*width }, (width+offset)*self.options.rate, "linear", () ->
         current.css("left", next.position().left+next.width()+self.options.space_offset)
         cb.call self

   _resetFirst: () ->
      this._startScroll(this.options._first, this.options._second, this._resetFirst)

   _resetSecond: () ->
      this._startScroll(this.options._second, this.options._first, this._resetSecond)

   options:
      _first: null
      _second: null
      _is_stopped: false
      start_offset: 10
      space_offset: 25
      rate: 30

$.widget "ui.scroller", Scroller