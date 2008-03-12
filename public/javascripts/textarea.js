TextArea = Class.create();
TextArea.prototype = {
  initialize: function(element) {
    this.element = $(element);
    
    if (!this.element.style.width) this.element.style.width = this.element.getDimensions()['width'] + 'px'
    
    this.hidden_sizer = document.createElement('textarea')
    this.hidden_sizer.id = 'hidden_sizer';
    this.hidden_sizer.value = this.element.value;
    
    this.hidden_sizer.style.paddingTop = Element.getStyle(this.element, 'padding-top');
    this.hidden_sizer.style.paddingRight = Element.getStyle(this.element, 'padding-right');
    this.hidden_sizer.style.paddingBottom = Element.getStyle(this.element, 'padding-bottom');
    this.hidden_sizer.style.paddingLeft = Element.getStyle(this.element, 'padding-left');
    
    this.hidden_sizer.style.width = this.element.style.width;
    this.hidden_sizer.style.height = '30px'; // the min height 
    this.hidden_sizer.style.position = 'relative';
    this.hidden_sizer.style.display = 'block';
    this.hidden_sizer.style.marginTop = '-30px';
    this.hidden_sizer.style.zIndex = '-1';
    
    this.element.style.overflow = 'hidden'; //hides scrollbars
    this.hidden_sizer.style.overflow = 'hidden';

    this.element.parentNode.insertBefore(this.hidden_sizer, this.element.nextSibling);

    this.size();
    Event.observe(this.element, 'focus', this.onFocus.bindAsEventListener(this));
  },
  
  size: function() {
    if (this.element.scrollHeight > Element.getDimensions(this.element)['height'] ) {
      this.element.style.height = (this.element.scrollHeight + 10) + 'px';
    }
    else {
      this.hidden_sizer.value = this.element.value;
      this.element.style.height = (this.hidden_sizer.scrollHeight + 10) + 'px';
    }
  },
  
  onFocus: function() {
    new Form.Element.Observer(this.element, 0.1, this.size.bindAsEventListener(this));
  }
}