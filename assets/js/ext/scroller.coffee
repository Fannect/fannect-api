$ = jQuery

Scroller = 
   _init: () ->
      text = this.element.text()
      this.element.empty().addClass("scrolling-text").append("<div class='cover'></div>")
      textWrap = $("<div class='text-wrap'></div>").appendTo(this.element);
      currentElem = $("<span class='text'>" + text + "</span>").appendTo(textWrap);
      nextElem = $("<span class='text'>" + text + "</span>").appendTo(textWrap);

      currentElem.css { "left": this.options.start_offset}
      nextElem.css "left", this.options.start_offset + currentElem.width() + this.options.space_offset

      this._startScroll currentElem, nextElem
      this._startScroll nextElem, currentElem

   _startScroll: (current, next) ->
      self = this
      width = current.width()
      offset = current.position().left

      current.animate { left: -1*width }, (width+offset)*self.options.rate, "linear", () ->
         current.css("left", next.position().left+next.width()+self.options.space_offset);
         self._startScroll(current, next);
         
   options:
      start_offset: 10
      space_offset: 25
      rate: 30

$.widget "ui.scroller", Scroller