(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
//
// npm dependencies library
//
(function (scope) {
  "use-strict";
  scope.__registry__ = Object.assign({}, scope.__registry__, {
    //
    // list npm modules required in Haxe
    //
    "bootstrap.native": require("bootstrap.native"),
  });

  /*if (process.env.NODE_ENV !== 'production') {
      // enable React hot-reload
      require('haxe-modular');
    }*/
})(typeof $hx_scope != "undefined" ? $hx_scope : ($hx_scope = {}));

},{"bootstrap.native":2}],2:[function(require,module,exports){
(function (global){
// Native Javascript for Bootstrap 3 v2.0.27 | © dnp_theme | MIT-License
(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD support:
    define([], factory);
  } else if (typeof module === 'object' && module.exports) {
    // CommonJS-like:
    module.exports = factory();
  } else {
    // Browser globals (root is window)
    var bsn = factory();
    root.Affix = bsn.Affix;
    root.Alert = bsn.Alert;
    root.Button = bsn.Button;
    root.Carousel = bsn.Carousel;
    root.Collapse = bsn.Collapse;
    root.Dropdown = bsn.Dropdown;
    root.Modal = bsn.Modal;
    root.Popover = bsn.Popover;
    root.ScrollSpy = bsn.ScrollSpy;
    root.Tab = bsn.Tab;
    root.Tooltip = bsn.Tooltip;
  }
}(this, function () {
  
  /* Native Javascript for Bootstrap 3 | Internal Utility Functions
  ----------------------------------------------------------------*/
  "use strict";
  
  // globals
  var globalObject = typeof global !== 'undefined' ? global : this||window,
    DOC = document, HTML = DOC.documentElement, body = 'body', // allow the library to be used in <head>
  
    // Native Javascript for Bootstrap Global Object
    BSN = globalObject.BSN = {},
    supports = BSN.supports = [],
  
    // function toggle attributes
    dataToggle    = 'data-toggle',
    dataDismiss   = 'data-dismiss',
    dataSpy       = 'data-spy',
    dataRide      = 'data-ride',
    
    // components
    stringAffix     = 'Affix',
    stringAlert     = 'Alert',
    stringButton    = 'Button',
    stringCarousel  = 'Carousel',
    stringCollapse  = 'Collapse',
    stringDropdown  = 'Dropdown',
    stringModal     = 'Modal',
    stringPopover   = 'Popover',
    stringScrollSpy = 'ScrollSpy',
    stringTab       = 'Tab',
    stringTooltip   = 'Tooltip',
  
    // options DATA API
    databackdrop      = 'data-backdrop',
    dataKeyboard      = 'data-keyboard',
    dataTarget        = 'data-target',
    dataInterval      = 'data-interval',
    dataHeight        = 'data-height',
    dataPause         = 'data-pause',
    dataTitle         = 'data-title',  
    dataOriginalTitle = 'data-original-title',
    dataOriginalText  = 'data-original-text',
    dataDismissible   = 'data-dismissible',
    dataTrigger       = 'data-trigger',
    dataAnimation     = 'data-animation',
    dataContainer     = 'data-container',
    dataPlacement     = 'data-placement',
    dataDelay         = 'data-delay',
    dataOffsetTop     = 'data-offset-top',
    dataOffsetBottom  = 'data-offset-bottom',
  
    // option keys
    backdrop = 'backdrop', keyboard = 'keyboard', delay = 'delay',
    content = 'content', target = 'target', currentTarget = 'currentTarget',
    interval = 'interval', pause = 'pause', animation = 'animation',
    placement = 'placement', container = 'container', 
  
    // box model
    offsetTop    = 'offsetTop',      offsetBottom   = 'offsetBottom',
    offsetLeft   = 'offsetLeft',
    scrollTop    = 'scrollTop',      scrollLeft     = 'scrollLeft',
    clientWidth  = 'clientWidth',    clientHeight   = 'clientHeight',
    offsetWidth  = 'offsetWidth',    offsetHeight   = 'offsetHeight',
    innerWidth   = 'innerWidth',     innerHeight    = 'innerHeight',
    scrollHeight = 'scrollHeight',   height         = 'height',
  
    // aria
    ariaExpanded = 'aria-expanded',
    ariaHidden   = 'aria-hidden',
  
    // event names
    clickEvent    = 'click',
    focusEvent    = 'focus',
    hoverEvent    = 'hover',
    keydownEvent  = 'keydown',
    keyupEvent    = 'keyup',  
    resizeEvent   = 'resize', // passive
    scrollEvent   = 'scroll', // passive
    mouseHover = ('onmouseleave' in DOC) ? [ 'mouseenter', 'mouseleave'] : [ 'mouseover', 'mouseout' ],
    // touch since 2.0.26
    touchEvents = { start: 'touchstart', end: 'touchend', move:'touchmove' }, // passive
    // originalEvents
    showEvent     = 'show',
    shownEvent    = 'shown',
    hideEvent     = 'hide',
    hiddenEvent   = 'hidden',
    closeEvent    = 'close',
    closedEvent   = 'closed',
    slidEvent     = 'slid',
    slideEvent    = 'slide',
    changeEvent   = 'change',
  
    // other
    getAttribute           = 'getAttribute',
    setAttribute           = 'setAttribute',
    hasAttribute           = 'hasAttribute',
    createElement          = 'createElement',
    appendChild            = 'appendChild',
    innerHTML              = 'innerHTML',
    getElementsByTagName   = 'getElementsByTagName',
    preventDefault         = 'preventDefault',
    getBoundingClientRect  = 'getBoundingClientRect',
    querySelectorAll       = 'querySelectorAll',
    getElementsByCLASSNAME = 'getElementsByClassName',
    getComputedStyle       = 'getComputedStyle',  
  
    indexOf      = 'indexOf',
    parentNode   = 'parentNode',
    length       = 'length',
    toLowerCase  = 'toLowerCase',
    Transition   = 'Transition',
    Duration     = 'Duration',  
    Webkit       = 'Webkit',
    style        = 'style',
    push         = 'push',
    tabindex     = 'tabindex',
    contains     = 'contains',  
    
    active     = 'active',
    inClass    = 'in',
    collapsing = 'collapsing',
    disabled   = 'disabled',
    loading    = 'loading',
    left       = 'left',
    right      = 'right',
    top        = 'top',
    bottom     = 'bottom',
  
    // IE8 browser detect
    isIE8 = !('opacity' in HTML[style]),
  
    // tooltip / popover
    tipPositions = /\b(top|bottom|left|right)+/,
    
    // modal
    modalOverlay = 0,
    fixedTop = 'navbar-fixed-top',
    fixedBottom = 'navbar-fixed-bottom',  
    
    // transitionEnd since 2.0.4
    supportTransitions = Webkit+Transition in HTML[style] || Transition[toLowerCase]() in HTML[style],
    transitionEndEvent = Webkit+Transition in HTML[style] ? Webkit[toLowerCase]()+Transition+'End' : Transition[toLowerCase]()+'end',
    transitionDuration = Webkit+Duration in HTML[style] ? Webkit[toLowerCase]()+Transition+Duration : Transition[toLowerCase]()+Duration,
  
    // set new focus element since 2.0.3
    setFocus = function(element){
      element.focus ? element.focus() : element.setActive();
    },
  
    // class manipulation, since 2.0.0 requires polyfill.js
    addClass = function(element,classNAME) {
      element.classList.add(classNAME);
    },
    removeClass = function(element,classNAME) {
      element.classList.remove(classNAME);
    },
    hasClass = function(element,classNAME){ // since 2.0.0
      return element.classList[contains](classNAME);
    },
  
    // selection methods
    nodeListToArray = function(nodeList){
      var childItems = []; for (var i = 0, nll = nodeList[length]; i<nll; i++) { childItems[push]( nodeList[i] ) }
      return childItems;
    },
    getElementsByClassName = function(element,classNAME) { // getElementsByClassName IE8+
      var selectionMethod = isIE8 ? querySelectorAll : getElementsByCLASSNAME;      
      return nodeListToArray(element[selectionMethod]( isIE8 ? '.' + classNAME.replace(/\s(?=[a-z])/g,'.') : classNAME ));
    },
    queryElement = function (selector, parent) {
      var lookUp = parent ? parent : DOC;
      return typeof selector === 'object' ? selector : lookUp.querySelector(selector);
    },
    getClosest = function (element, selector) { //element is the element and selector is for the closest parent element to find
      // source http://gomakethings.com/climbing-up-and-down-the-dom-tree-with-vanilla-javascript/
      var firstChar = selector.charAt(0), selectorSubstring = selector.substr(1);
      if ( firstChar === '.' ) {// If selector is a class
        for ( ; element && element !== DOC; element = element[parentNode] ) { // Get closest match
          if ( queryElement(selector,element[parentNode]) !== null && hasClass(element,selectorSubstring) ) { return element; }
        }
      } else if ( firstChar === '#' ) { // If selector is an ID
        for ( ; element && element !== DOC; element = element[parentNode] ) { // Get closest match
          if ( element.id === selectorSubstring ) { return element; }
        }
      }
      return false;
    },
  
    // event attach jQuery style / trigger  since 1.2.0
    on = function (element, event, handler, options) {
      options = options || false;
      element.addEventListener(event, handler, options);
    },
    off = function(element, event, handler, options) {
      options = options || false;
      element.removeEventListener(event, handler, options);
    },
    one = function (element, event, handler, options) { // one since 2.0.4
      on(element, event, function handlerWrapper(e){
        handler(e);
        off(element, event, handlerWrapper, options);
      }, options);
    },
    // determine support for passive events
    supportPassive = (function(){
      // Test via a getter in the options object to see if the passive property is accessed
      var result = false;
      try {
        var opts = Object.defineProperty({}, 'passive', {
          get: function() {
            result = true;
          }
        });
        one(globalObject, 'testPassive', null, opts);
      } catch (e) {}
  
      return result;
    }()),
    // event options
    // https://github.com/WICG/EventListenerOptions/blob/gh-pages/explainer.md#feature-detection
    passiveHandler = supportPassive ? { passive: true } : false,
    // transitions
    getTransitionDurationFromElement = function(element) {
      var duration = supportTransitions ? globalObject[getComputedStyle](element)[transitionDuration] : 0;
      duration = parseFloat(duration);
      duration = typeof duration === 'number' && !isNaN(duration) ? duration * 1000 : 0;
      return duration; // we take a short offset to make sure we fire on the next frame after animation
    },
    emulateTransitionEnd = function(element,handler){ // emulateTransitionEnd since 2.0.4
      var called = 0, duration = getTransitionDurationFromElement(element);
      duration ? one(element, transitionEndEvent, function(e){ !called && handler(e), called = 1; })
               : setTimeout(function() { !called && handler(), called = 1; }, 17);
    },
    bootstrapCustomEvent = function (eventName, componentName, related) {
      var OriginalCustomEvent = new CustomEvent( eventName + '.bs.' + componentName);
      OriginalCustomEvent.relatedTarget = related;
      this.dispatchEvent(OriginalCustomEvent);
    },
  
    // tooltip / popover stuff
    getScroll = function() { // also Affix and ScrollSpy uses it
      return {
        y : globalObject.pageYOffset || HTML[scrollTop],
        x : globalObject.pageXOffset || HTML[scrollLeft]
      }
    },
    styleTip = function(link,element,position,parent) { // both popovers and tooltips (target,tooltip/popover,placement,elementToAppendTo)
      var elementDimensions = { w : element[offsetWidth], h: element[offsetHeight] },
          windowWidth = (HTML[clientWidth] || DOC[body][clientWidth]),
          windowHeight = (HTML[clientHeight] || DOC[body][clientHeight]),
          rect = link[getBoundingClientRect](), 
          scroll = parent === DOC[body] ? getScroll() : { x: parent[offsetLeft] + parent[scrollLeft], y: parent[offsetTop] + parent[scrollTop] },
          linkDimensions = { w: rect[right] - rect[left], h: rect[bottom] - rect[top] },
          arrow = queryElement('[class*="arrow"]',element),
          topPosition, leftPosition, arrowTop, arrowLeft,
  
          halfTopExceed = rect[top] + linkDimensions.h/2 - elementDimensions.h/2 < 0,
          halfLeftExceed = rect[left] + linkDimensions.w/2 - elementDimensions.w/2 < 0,
          halfRightExceed = rect[left] + elementDimensions.w/2 + linkDimensions.w/2 >= windowWidth,
          halfBottomExceed = rect[top] + elementDimensions.h/2 + linkDimensions.h/2 >= windowHeight,
          topExceed = rect[top] - elementDimensions.h < 0,
          leftExceed = rect[left] - elementDimensions.w < 0,
          bottomExceed = rect[top] + elementDimensions.h + linkDimensions.h >= windowHeight,
          rightExceed = rect[left] + elementDimensions.w + linkDimensions.w >= windowWidth;
  
      // recompute position
      position = (position === left || position === right) && leftExceed && rightExceed ? top : position; // first, when both left and right limits are exceeded, we fall back to top|bottom
      position = position === top && topExceed ? bottom : position;
      position = position === bottom && bottomExceed ? top : position;
      position = position === left && leftExceed ? right : position;
      position = position === right && rightExceed ? left : position;
      
      // apply styling to tooltip or popover
      if ( position === left || position === right ) { // secondary|side positions
        if ( position === left ) { // LEFT
          leftPosition = rect[left] + scroll.x - elementDimensions.w;
        } else { // RIGHT
          leftPosition = rect[left] + scroll.x + linkDimensions.w;
        }
  
        // adjust top and arrow
        if (halfTopExceed) {
          topPosition = rect[top] + scroll.y;
          arrowTop = linkDimensions.h/2;
        } else if (halfBottomExceed) {
          topPosition = rect[top] + scroll.y - elementDimensions.h + linkDimensions.h;
          arrowTop = elementDimensions.h - linkDimensions.h/2;
        } else {
          topPosition = rect[top] + scroll.y - elementDimensions.h/2 + linkDimensions.h/2;
        }
      } else if ( position === top || position === bottom ) { // primary|vertical positions
        if ( position === top) { // TOP
          topPosition =  rect[top] + scroll.y - elementDimensions.h;
        } else { // BOTTOM
          topPosition = rect[top] + scroll.y + linkDimensions.h;
        }
        // adjust left | right and also the arrow
        if (halfLeftExceed) {
          leftPosition = 0;
          arrowLeft = rect[left] + linkDimensions.w/2;
        } else if (halfRightExceed) {
          leftPosition = windowWidth - elementDimensions.w*1.01;
          arrowLeft = elementDimensions.w - ( windowWidth - rect[left] ) + linkDimensions.w/2;
        } else {
          leftPosition = rect[left] + scroll.x - elementDimensions.w/2 + linkDimensions.w/2;
        }
      }
  
      // apply style to tooltip/popover and it's arrow
      element[style][top] = topPosition + 'px';
      element[style][left] = leftPosition + 'px';
  
      arrowTop && (arrow[style][top] = arrowTop + 'px');
      arrowLeft && (arrow[style][left] = arrowLeft + 'px');
  
      element.className[indexOf](position) === -1 && (element.className = element.className.replace(tipPositions,position));
    };
  
  BSN.version = '2.0.27';
  
  /* Native Javascript for Bootstrap 3 | Affix
  -------------------------------------------*/
  
  // AFFIX DEFINITION
  var Affix = function(element, options) {
  
    // initialization element
    element = queryElement(element);
  
    // set options
    options = options || {};
  
    // read DATA API
    var targetData        = element[getAttribute](dataTarget),
        offsetTopData     = element[getAttribute](dataOffsetTop),
        offsetBottomData  = element[getAttribute](dataOffsetBottom),
        
        // component specific strings
        affix = 'affix', affixed = 'affixed', fn = 'function', update = 'update',
        affixTop = 'affix-top', affixedTop = 'affixed-top',
        affixBottom = 'affix-bottom', affixedBottom = 'affixed-bottom';
  
    this[target] = options[target] ? queryElement(options[target]) : queryElement(targetData) || null; // target is an object
    this[offsetTop] = options[offsetTop] ? options[offsetTop] : parseInt(offsetTopData) || 0; // offset option is an integer number or function to determine that number
    this[offsetBottom] = options[offsetBottom] ? options[offsetBottom]: parseInt(offsetBottomData) || 0;
  
    if ( !this[target] && !( this[offsetTop] || this[offsetBottom] ) ) { return; } // invalidate
  
    // internal bind
    var self = this,
  
      // constants
      pinOffsetTop, pinOffsetBottom, maxScroll, scrollY, pinnedTop, pinnedBottom,
      affixedToTop = false, affixedToBottom = false,
      
      // private methods 
      getMaxScroll = function(){
        return Math.max( DOC[body][scrollHeight], DOC[body][offsetHeight], HTML[clientHeight], HTML[scrollHeight], HTML[offsetHeight] );
      },
      getOffsetTop = function () {
        if ( self[target] !== null ) {
          return self[target][getBoundingClientRect]()[top] + scrollY;
        } else if ( self[offsetTop] ) {
          return parseInt(typeof self[offsetTop] === fn ? self[offsetTop]() : self[offsetTop] || 0);
        }
      },
      getOffsetBottom = function () {
        if ( self[offsetBottom] ) {
          return maxScroll - element[offsetHeight] - parseInt( typeof self[offsetBottom] === fn ? self[offsetBottom]() : self[offsetBottom] || 0 );
        }
      },
      checkPosition = function () {
        maxScroll = getMaxScroll();
        scrollY = parseInt(getScroll().y,0);
        pinOffsetTop = getOffsetTop();
        pinOffsetBottom = getOffsetBottom(); 
        pinnedTop = ( parseInt(pinOffsetTop) - scrollY < 0) && (scrollY > parseInt(pinOffsetTop) );
        pinnedBottom = ( parseInt(pinOffsetBottom) - scrollY < 0) && (scrollY > parseInt(pinOffsetBottom) );
      },
      pinTop = function () {
        if ( !affixedToTop && !hasClass(element,affix) ) { // on loading a page halfway scrolled these events don't trigger in Chrome
          bootstrapCustomEvent.call(element, affix, affix);
          bootstrapCustomEvent.call(element, affixTop, affix);
          addClass(element,affix);
          affixedToTop = true;
          bootstrapCustomEvent.call(element, affixed, affix);
          bootstrapCustomEvent.call(element, affixedTop, affix);
        }
      },
      unPinTop = function () {
        if ( affixedToTop && hasClass(element,affix) ) {
          removeClass(element,affix);
          affixedToTop = false;
        }
      },
      pinBottom = function () {
        if ( !affixedToBottom && !hasClass(element, affixBottom) ) {
          bootstrapCustomEvent.call(element, affix, affix);
          bootstrapCustomEvent.call(element, affixBottom, affix);
          addClass(element,affixBottom);
          affixedToBottom = true;
          bootstrapCustomEvent.call(element, affixed, affix);
          bootstrapCustomEvent.call(element, affixedBottom, affix);
        }
      },
      unPinBottom = function () {
        if ( affixedToBottom && hasClass(element,affixBottom) ) {
          removeClass(element,affixBottom);
          affixedToBottom = false;
        }
      },
      updatePin = function () {
        if ( pinnedBottom ) {
          if ( pinnedTop ) { unPinTop(); }
          pinBottom(); 
        } else {
          unPinBottom();
          if ( pinnedTop ) { pinTop(); } 
          else { unPinTop(); }
        }
      };
  
    // public method
    this[update] = function () {
      checkPosition();
      updatePin(); 
    };
  
    // init
    if ( !(stringAffix in element ) ) { // prevent adding event handlers twice
      on( globalObject, scrollEvent, self[update], passiveHandler );
      !isIE8 && on( globalObject, resizeEvent, self[update], passiveHandler );
  }
    element[stringAffix] = self;
  
    self[update]();
  };
  
  // AFFIX DATA API
  // =================
  supports[push]([stringAffix, Affix, '['+dataSpy+'="affix"]']);
  
  
  
  /* Native Javascript for Bootstrap 3 | Alert
  -------------------------------------------*/
  
  // ALERT DEFINITION
  // ================
  var Alert = function( element ) {
    
    // initialization element
    element = queryElement(element);
  
    // bind, target alert, duration and stuff
    var self = this, component = 'alert',
      alert = getClosest(element,'.'+component),
      triggerHandler = function(){ hasClass(alert,'fade') ? emulateTransitionEnd(alert,transitionEndHandler) : transitionEndHandler(); },
      // handlers
      clickHandler = function(e){
        alert = getClosest(e[target],'.'+component);
        element = queryElement('['+dataDismiss+'="'+component+'"]',alert);
        element && alert && (element === e[target] || element[contains](e[target])) && self.close();
      },
      transitionEndHandler = function(){
        bootstrapCustomEvent.call(alert, closedEvent, component);
        off(element, clickEvent, clickHandler); // detach it's listener
        alert[parentNode].removeChild(alert);
      };
    
    // public method
    this.close = function() {
      if ( alert && element && hasClass(alert,inClass) ) {
        bootstrapCustomEvent.call(alert, closeEvent, component);
        removeClass(alert,inClass);
        alert && triggerHandler();
      }
    };
  
    // init
    if ( !(stringAlert in element ) ) { // prevent adding event handlers twice
      on(element, clickEvent, clickHandler);
    }
    element[stringAlert] = self;
  };
  
  // ALERT DATA API
  // ==============
  supports[push]([stringAlert, Alert, '['+dataDismiss+'="alert"]']);
  
  
  
  /* Native Javascript for Bootstrap 3 | Button
  ---------------------------------------------*/
  
  // BUTTON DEFINITION
  // ===================
  var Button = function( element, option ) {
  
    // initialization element
    element = queryElement(element);
  
    // set option
    option = option || null;
  
    // constant
    var toggled = false, // toggled makes sure to prevent triggering twice the change.bs.button events
  
        // strings
        component = 'button',
        checked = 'checked',
        reset = 'reset',
        LABEL = 'LABEL',
        INPUT = 'INPUT',
  
      // private methods
      setState = function() {
        if ( !! option && option !== reset ) {
          if ( option === loading ) {
            addClass(element,disabled);
            element[setAttribute](disabled,disabled);
            element[setAttribute](dataOriginalText, element[innerHTML].trim()); // trim the text
          }
          element[innerHTML] = element[getAttribute]('data-'+option+'-text');
        }
      },
      resetState = function() {
        if (element[getAttribute](dataOriginalText)) {
          if ( hasClass(element,disabled) || element[getAttribute](disabled) === disabled ) {
            removeClass(element,disabled);
            element.removeAttribute(disabled);
          }
          element[innerHTML] = element[getAttribute](dataOriginalText);
        }
      },
      keyHandler = function(e){ 
        var key = e.which || e.keyCode;
        key === 32 && e[target] === DOC.activeElement && toggle(e);
      },
      preventScroll = function(e){ 
        var key = e.which || e.keyCode;
        key === 32 && e[preventDefault]();
      },    
      toggle = function(e) {
        var label = e[target].tagName === LABEL ? e[target] : e[target][parentNode].tagName === LABEL ? e[target][parentNode] : null; // the .btn label
        
        if ( !label ) return; //react if a label or its immediate child is clicked
  
        var labels = getElementsByClassName(label[parentNode],'btn'), // all the button group buttons
          input = label[getElementsByTagName](INPUT)[0];
  
        if ( !input ) return; // return if no input found
  
        // manage the dom manipulation
        if ( input.type === 'checkbox' ) { //checkboxes
          if ( !input[checked] ) {
            addClass(label,active);
            input[getAttribute](checked);
            input[setAttribute](checked,checked);
            input[checked] = true;
          } else {
            removeClass(label,active);
            input[getAttribute](checked);
            input.removeAttribute(checked);
            input[checked] = false;
          }
  
          if (!toggled) { // prevent triggering the event twice
            toggled = true;
            bootstrapCustomEvent.call(input, changeEvent, component); //trigger the change for the input
            bootstrapCustomEvent.call(element, changeEvent, component); //trigger the change for the btn-group
          }
        }
  
        if ( input.type === 'radio' && !toggled ) { // radio buttons
          // don't trigger if already active (the OR condition is a hack to check if the buttons were selected with key press and NOT mouse click)
          if ( !input[checked] || (e.screenX === 0 && e.screenY == 0) ) {
            addClass(label,active);
            input[setAttribute](checked,checked);
            input[checked] = true;
            bootstrapCustomEvent.call(input, changeEvent, component); //trigger the change for the input
            bootstrapCustomEvent.call(element, changeEvent, component); //trigger the change for the btn-group
  
            toggled = true;
            for (var i = 0, ll = labels[length]; i<ll; i++) {
              var otherLabel = labels[i], otherInput = otherLabel[getElementsByTagName](INPUT)[0];
              if ( otherLabel !== label && hasClass(otherLabel,active) )  {
                removeClass(otherLabel,active);
                otherInput.removeAttribute(checked);
                otherInput[checked] = false;
                bootstrapCustomEvent.call(otherInput, changeEvent, component); // trigger the change
              }
            }
          }
        }
        setTimeout( function() { toggled = false; }, 50 );
      };
  
    // init
    if ( hasClass(element,'btn') ) { // when Button text is used we execute it as an instance method
      if ( option !== null ) {
        if ( option !== reset ) { setState(); } 
        else { resetState(); }
      }
    } else { // if ( hasClass(element,'btn-group') ) // we allow the script to work outside btn-group component
      
      if ( !( stringButton in element ) ) { // prevent adding event handlers twice
        on( element, clickEvent, toggle );
        on( element, keyupEvent, keyHandler ), on( element, keydownEvent, preventScroll );
      }
  
      // activate items on load
      var labelsToACtivate = getElementsByClassName(element, 'btn'), lbll = labelsToACtivate[length];
      for (var i=0; i<lbll; i++) {
        !hasClass(labelsToACtivate[i],active) && queryElement('input',labelsToACtivate[i])[getAttribute](checked)
                                              && addClass(labelsToACtivate[i],active);
      }
      element[stringButton] = this;
    }
  };
  
  // BUTTON DATA API
  // =================
  supports[push]( [ stringButton, Button, '['+dataToggle+'="buttons"]' ] );
  
  
  /* Native Javascript for Bootstrap 3 | Carousel
  ----------------------------------------------*/
  
  // CAROUSEL DEFINITION
  // ===================
  var Carousel = function( element, options ) {
  
    // initialization element
    element = queryElement( element );
  
    // set options
    options = options || {};
  
    // DATA API
    var intervalAttribute = element[getAttribute](dataInterval),
        intervalOption = options[interval],
        intervalData = intervalAttribute === 'false' ? 0 : parseInt(intervalAttribute),  
        pauseData = element[getAttribute](dataPause) === hoverEvent || false,
        keyboardData = element[getAttribute](dataKeyboard) === 'true' || false,
      
        // strings
        component = 'carousel',
        paused = 'paused',
        direction = 'direction',
        dataSlideTo = 'data-slide-to'; 
  
    this[keyboard] = options[keyboard] === true || keyboardData;
    this[pause] = (options[pause] === hoverEvent || pauseData) ? hoverEvent : false; // false / hover
  
    this[interval] = typeof intervalOption === 'number' ? intervalOption
                   : intervalOption === false || intervalData === 0 || intervalData === false ? 0
                   : isNaN(intervalData) ? 5000 // bootstrap carousel default interval
                   : intervalData;
  
    // bind, event targets
    var self = this, index = element.index = 0, timer = element.timer = 0, 
      isSliding = false, // isSliding prevents click event handlers when animation is running
      isTouch = false, startXPosition = null, currentXPosition = null, endXPosition = null, // touch and event coordinates
      slides = getElementsByClassName(element,'item'), total = slides[length],
      slideDirection = this[direction] = left,
      controls = getElementsByClassName(element,component+'-control'),
      leftArrow = controls[0], rightArrow = controls[1],
      indicator = queryElement( '.'+component+'-indicators', element ),
      indicators = indicator && indicator[getElementsByTagName]( "LI" ) || [];
  
    // invalidate when not enough items
    if (total < 2) { return; }
  
    // handlers
    var pauseHandler = function () {
        if ( self[interval] !==false && !hasClass(element,paused) ) {
          addClass(element,paused);
          !isSliding && ( clearInterval(timer), timer = null );
        }
      },
      resumeHandler = function() {
        if ( self[interval] !== false && hasClass(element,paused) ) {
          removeClass(element,paused);
          !isSliding && ( clearInterval(timer), timer = null );
          !isSliding && self.cycle();
        }
      },
      indicatorHandler = function(e) {
        e[preventDefault]();
        if (isSliding) return;
  
        var eventTarget = e[target]; // event target | the current active item
  
        if ( eventTarget && !hasClass(eventTarget,active) && eventTarget[getAttribute](dataSlideTo) ) {
          index = parseInt( eventTarget[getAttribute](dataSlideTo), 10 );
        } else { return false; }
  
        self.slideTo( index ); //Do the slide
      },
      controlsHandler = function (e) {
        e[preventDefault]();
        if (isSliding) return;
  
        var eventTarget = e.currentTarget || e.srcElement;
  
        if ( eventTarget === rightArrow ) {
          index++;
        } else if ( eventTarget === leftArrow ) {
          index--;
        }
  
        self.slideTo( index ); //Do the slide
      },
      keyHandler = function (e) {
        if (isSliding) return;
        switch (e.which) {
          case 39:
            index++;
            break;
          case 37:
            index--;
            break;
          default: return;
        }
        self.slideTo( index ); //Do the slide
      },
      // touch events
      toggleTouchEvents = function(toggle){
        toggle( element, touchEvents.move, touchMoveHandler, passiveHandler );
        toggle( element, touchEvents.end, touchEndHandler, passiveHandler );
    },  
      touchDownHandler = function(e) {
        if ( isTouch ) { return; } 
          
        startXPosition = parseInt(e.touches[0].pageX);
  
        if ( element.contains(e[target]) ) {
          isTouch = true;
          toggleTouchEvents(on);
        }
      },
      touchMoveHandler = function(e) {
        if ( !isTouch ) { e.preventDefault(); return; }
  
        currentXPosition = parseInt(e.touches[0].pageX);
        
        //cancel touch if more than one touches detected
        if ( e.type === 'touchmove' && e.touches[length] > 1 ) {
          e.preventDefault();
          return false;
        }
      },
      touchEndHandler = function(e) {
        if ( !isTouch || isSliding ) { return }
        
        endXPosition = currentXPosition || parseInt( e.touches[0].pageX );
  
        if ( isTouch ) {
          if ( (!element.contains(e[target]) || !element.contains(e.relatedTarget) ) && Math.abs(startXPosition - endXPosition) < 75 ) {
            return false;
          } else {
            if ( currentXPosition < startXPosition ) {
              index++;
            } else if ( currentXPosition > startXPosition ) {
              index--;        
            }
            isTouch = false;
            self.slideTo(index);
          }
          toggleTouchEvents(off);            
        }
      },
  
      // private methods
      isElementInScrollRange = function () {
        var rect = element[getBoundingClientRect](),
          viewportHeight = globalObject[innerHeight] || HTML[clientHeight]
        return rect[top] <= viewportHeight && rect[bottom] >= 0; // bottom && top
      },  
      setActivePage = function( pageIndex ) { //indicators
        for ( var i = 0, icl = indicators[length]; i < icl; i++ ) {
          removeClass(indicators[i],active);
        }
        if (indicators[pageIndex]) addClass(indicators[pageIndex], active);
      };
  
  
    // public methods
    this.cycle = function() {
      if (timer) {
        clearInterval(timer);
        timer = null;
      }
  
      timer = setInterval(function() {
        isElementInScrollRange() && (index++, self.slideTo( index ) );
      }, this[interval]);
    };
    this.slideTo = function( next ) {
      if (isSliding) return; // when controled via methods, make sure to check again
  
      var activeItem = this.getActiveIndex(), // the current active
          orientation;
      
        // first return if we're on the same item #227
        if ( activeItem === next ) {
          return;
        // or determine slideDirection
        } else if  ( (activeItem < next ) || (activeItem === 0 && next === total -1 ) ) {
        slideDirection = self[direction] = left; // next
      } else if  ( (activeItem > next) || (activeItem === total - 1 && next === 0 ) ) {
        slideDirection = self[direction] = right; // prev
      }
  
      // find the right next index 
      if ( next < 0 ) { next = total - 1; } 
      else if ( next >= total ){ next = 0; }
  
      // update index
      index = next;
      
      orientation = slideDirection === left ? 'next' : 'prev'; //determine type
      bootstrapCustomEvent.call(element, slideEvent, component, slides[next]); // here we go with the slide
  
      isSliding = true;
      clearInterval(timer);
      timer = null;
      setActivePage( next );
  
      if ( supportTransitions && hasClass(element,'slide') ) {
  
        addClass(slides[next],orientation);
        slides[next][offsetWidth];
        addClass(slides[next],slideDirection);
        addClass(slides[activeItem],slideDirection);
  
        emulateTransitionEnd(slides[next], function(e) {
          var timeout = e && e[target] !== slides[next] ? e.elapsedTime*1000+100 : 20;
          isSliding && setTimeout(function(){
            isSliding = false;
  
            addClass(slides[next],active);
            removeClass(slides[activeItem],active);
  
            removeClass(slides[next],orientation);
            removeClass(slides[next],slideDirection);
            removeClass(slides[activeItem],slideDirection);
  
            bootstrapCustomEvent.call(element, slidEvent, component, slides[next]);
  
            if ( self[interval] && !hasClass(element,paused) ) {
              self.cycle();
            }
          }, timeout);
        });
  
      } else {
        addClass(slides[next],active);
        slides[next][offsetWidth];
        removeClass(slides[activeItem],active);
        setTimeout(function() {
          isSliding = false;
          if ( self[interval] && !hasClass(element,paused) ) {
            self.cycle();
          }
          bootstrapCustomEvent.call(element, slidEvent, component, slides[next]);
        }, 100 );
      }
    };
    this.getActiveIndex = function () {
      return slides[indexOf](getElementsByClassName(element,'item active')[0]) || 0;
    };
  
    // init
    if ( !(stringCarousel in element ) ) { // prevent adding event handlers twice
  
      if ( self[pause] && self[interval] ) {
        on( element, mouseHover[0], pauseHandler );
        on( element, mouseHover[1], resumeHandler );
        on( element, touchEvents.start, pauseHandler, passiveHandler );
        on( element, touchEvents.end, resumeHandler, passiveHandler );
    }
  
      slides[length] > 1 && on( element, touchEvents.start, touchDownHandler, passiveHandler );
    
      rightArrow && on( rightArrow, clickEvent, controlsHandler );
      leftArrow && on( leftArrow, clickEvent, controlsHandler );
    
      indicator && on( indicator, clickEvent, indicatorHandler );
      self[keyboard] && on( globalObject, keydownEvent, keyHandler );
  
    }
    if (self.getActiveIndex()<0) {
      slides[length] && addClass(slides[0],active);
      indicators[length] && setActivePage(0);
    }
  
    if ( self[interval] ){ self.cycle(); }
    element[stringCarousel] = self;
  };
  
  // CAROUSEL DATA API
  // =================
  supports[push]( [ stringCarousel, Carousel, '['+dataRide+'="carousel"]' ] );
  
  
  /* Native Javascript for Bootstrap 3 | Collapse
  -----------------------------------------------*/
  
  // COLLAPSE DEFINITION
  // ===================
  var Collapse = function( element, options ) {
  
    // initialization element
    element = queryElement(element);
  
    // set options
    options = options || {};
  
    // event targets and constants
    var accordion = null, collapse = null, self = this,
      accordionData = element[getAttribute]('data-parent'),
      activeCollapse, activeElement,
  
      // component strings
      component = 'collapse',
      collapsed = 'collapsed',
      isAnimating = 'isAnimating',
  
      // private methods
      openAction = function(collapseElement,toggle) {
        bootstrapCustomEvent.call(collapseElement, showEvent, component);
        collapseElement[isAnimating] = true;
        addClass(collapseElement,collapsing);
        removeClass(collapseElement,component);
        collapseElement[style][height] = collapseElement[scrollHeight] + 'px';
        
        emulateTransitionEnd(collapseElement, function() {
          collapseElement[isAnimating] = false;
          collapseElement[setAttribute](ariaExpanded,'true');
          toggle[setAttribute](ariaExpanded,'true');          
          removeClass(collapseElement,collapsing);
          addClass(collapseElement, component);
          addClass(collapseElement, inClass);
          collapseElement[style][height] = '';
          bootstrapCustomEvent.call(collapseElement, shownEvent, component);
        });
      },
      closeAction = function(collapseElement,toggle) {
        bootstrapCustomEvent.call(collapseElement, hideEvent, component);
        collapseElement[isAnimating] = true;
        collapseElement[style][height] = collapseElement[scrollHeight] + 'px'; // set height first
        removeClass(collapseElement,component);
        removeClass(collapseElement, inClass);
        addClass(collapseElement, collapsing);
        collapseElement[offsetWidth]; // force reflow to enable transition
        collapseElement[style][height] = '0px';
        
        emulateTransitionEnd(collapseElement, function() {
          collapseElement[isAnimating] = false;
          collapseElement[setAttribute](ariaExpanded,'false');
          toggle[setAttribute](ariaExpanded,'false');
          removeClass(collapseElement,collapsing);
          addClass(collapseElement,component);
          collapseElement[style][height] = '';
          bootstrapCustomEvent.call(collapseElement, hiddenEvent, component);
        });
      },
      getTarget = function() {
        var href = element.href && element[getAttribute]('href'),
          parent = element[getAttribute](dataTarget),
          id = href || ( parent && parent.charAt(0) === '#' ) && parent;
        return id && queryElement(id);
      };
    
    // public methods
    this.toggle = function(e) {
      e[preventDefault]();
      if (!hasClass(collapse,inClass)) { self.show(); } 
      else { self.hide(); }
    };
    this.hide = function() {
      if ( collapse[isAnimating] ) return;
      closeAction(collapse,element);
      addClass(element,collapsed);
    };
    this.show = function() {
      if ( accordion ) {
        activeCollapse = queryElement('.'+component+'.'+inClass,accordion);
        activeElement = activeCollapse && (queryElement('['+dataTarget+'="#'+activeCollapse.id+'"]', accordion)
                      || queryElement('[href="#'+activeCollapse.id+'"]',accordion) );
      }
  
      if ( !collapse[isAnimating] || activeCollapse && !activeCollapse[isAnimating] ) {
        if ( activeElement && activeCollapse !== collapse ) {
          closeAction(activeCollapse,activeElement);
          addClass(activeElement,collapsed); 
        }
        openAction(collapse,element);
        removeClass(element,collapsed);
      }
    };
  
    // init
    if ( !(stringCollapse in element ) ) { // prevent adding event handlers twice
      on(element, clickEvent, self.toggle);
    }
    collapse = getTarget();
    collapse[isAnimating] = false;  // when true it will prevent click handlers  
    accordion = queryElement(options.parent) || accordionData && getClosest(element, accordionData);
    element[stringCollapse] = self;
  };
  
  // COLLAPSE DATA API
  // =================
  supports[push]( [ stringCollapse, Collapse, '['+dataToggle+'="collapse"]' ] );
  
  
  /* Native Javascript for Bootstrap 3 | Dropdown
  ----------------------------------------------*/
  
  // DROPDOWN DEFINITION
  // ===================
  var Dropdown = function( element, option ) {
      
    // initialization element
    element = queryElement(element);
  
    // set option
    this.persist = option === true || element[getAttribute]('data-persist') === 'true' || false;
  
    // constants, event targets, strings
    var self = this, children = 'children',
      parent = element[parentNode],
      component = 'dropdown', open = 'open',
      relatedTarget = null,
      menu = queryElement('.dropdown-menu', parent),
      menuItems = (function(){
        var set = menu[children], newSet = [];
        for ( var i=0; i<set[length]; i++ ){
          set[i][children][length] && (set[i][children][0].tagName === 'A' && newSet[push](set[i]));          
        }
        return newSet;
      })(),
  
      // preventDefault on empty anchor links
      preventEmptyAnchor = function(anchor){
        (anchor.href && anchor.href.slice(-1) === '#' || anchor[parentNode] && anchor[parentNode].href 
          && anchor[parentNode].href.slice(-1) === '#') && this[preventDefault]();      
      },
  
      // toggle dismissible events
      toggleDismiss = function(){
        var type = element[open] ? on : off;
        type(DOC, clickEvent, dismissHandler); 
        type(DOC, keydownEvent, preventScroll);
        type(DOC, keyupEvent, keyHandler);
        type(DOC, focusEvent, dismissHandler, true);
      },
  
      // handlers
      dismissHandler = function(e) {
        var eventTarget = e[target], hasData = eventTarget && (eventTarget[getAttribute](dataToggle) 
                              || eventTarget[parentNode] && getAttribute in eventTarget[parentNode] 
                              && eventTarget[parentNode][getAttribute](dataToggle));
        if ( e.type === focusEvent && (eventTarget === element || eventTarget === menu || menu[contains](eventTarget) ) ) {
          return;
        }
        if ( (eventTarget === menu || menu[contains](eventTarget)) && (self.persist || hasData) ) { return; }
        else {
          relatedTarget = eventTarget === element || element[contains](eventTarget) ? element : null;
          hide();
        }
        preventEmptyAnchor.call(e,eventTarget);
      },
      clickHandler = function(e) {
        relatedTarget = element;
        show();
        preventEmptyAnchor.call(e,e[target]);
      },
      preventScroll = function(e){
        var key = e.which || e.keyCode;
        if( key === 38 || key === 40 ) { e[preventDefault](); }
      },
      keyHandler = function(e){
        var key = e.which || e.keyCode, 
            activeItem = DOC.activeElement,
            idx = menuItems[indexOf](activeItem[parentNode]),
            isSameElement = activeItem === element,
            isInsideMenu = menu[contains](activeItem),
            isMenuItem = activeItem[parentNode][parentNode] === menu;
        
        if ( isMenuItem ) { // navigate up | down
          idx = isSameElement ? 0 
                              : key === 38 ? (idx>1?idx-1:0) 
                              : key === 40 ? (idx<menuItems[length]-1?idx+1:idx) : idx;
          menuItems[idx] && setFocus(menuItems[idx][children][0]);
        }
        if ( (menuItems[length] && isMenuItem // menu has items
          || !menuItems[length] && (isInsideMenu || isSameElement)  // menu might be a form
          || !isInsideMenu ) // or the focused element is not in the menu at all
          && element[open] && key === 27 // menu must be open
        ) {
          self.toggle();
          relatedTarget = null;
        }
      },  
  
      // private methods
      show = function() {
        bootstrapCustomEvent.call(parent, showEvent, component, relatedTarget);
        addClass(parent,open);
        element[setAttribute](ariaExpanded,true);
        bootstrapCustomEvent.call(parent, shownEvent, component, relatedTarget);
        element[open] = true;
        off(element, clickEvent, clickHandler);
        setTimeout(function(){ 
          setFocus( menu[getElementsByTagName]('INPUT')[0] || element ); // focus the first input item | element
          toggleDismiss(); 
        },1);
      },
      hide = function() {
        bootstrapCustomEvent.call(parent, hideEvent, component, relatedTarget);
        removeClass(parent,open);
        element[setAttribute](ariaExpanded,false);
        bootstrapCustomEvent.call(parent, hiddenEvent, component, relatedTarget);
        element[open] = false;
        toggleDismiss();
        setFocus(element);
        setTimeout(function(){ on(element, clickEvent, clickHandler); },1);
      };
  
    // set initial state to closed
    element[open] = false;
  
    // public methods
    this.toggle = function() {
      if (hasClass(parent,open) && element[open]) { hide(); } 
      else { show(); }
    };
  
    // init
    if (!(stringDropdown in element)) { // prevent adding event handlers twice
      !tabindex in menu && menu[setAttribute](tabindex, '0'); // Fix onblur on Chrome | Safari
      on(element, clickEvent, clickHandler);
    }
  
    element[stringDropdown] = self;
  };
  
  // DROPDOWN DATA API
  // =================
  supports[push]( [stringDropdown, Dropdown, '['+dataToggle+'="dropdown"]'] );
  
  
  /* Native Javascript for Bootstrap 3 | Modal
  -------------------------------------------*/
  
  // MODAL DEFINITION
  // ===============
  var Modal = function(element, options) { // element can be the modal/triggering button
  
    // the modal (both JavaScript / DATA API init) / triggering button element (DATA API)
    element = queryElement(element);
  
      // strings
      var component = 'modal',
        staticString = 'static',
        modalTrigger = 'modalTrigger',
        paddingRight = 'paddingRight',
        modalBackdropString = 'modal-backdrop',
        isAnimating = 'isAnimating',
        // determine modal, triggering element
        btnCheck = element[getAttribute](dataTarget)||element[getAttribute]('href'),
        checkModal = queryElement( btnCheck ),
        modal = hasClass(element,component) ? element : checkModal;
  
      if ( hasClass(element, component) ) { element = null; } // modal is now independent of it's triggering element
  
    if ( !modal ) { return; } // invalidate
  
    // set options
    options = options || {};
  
    this[keyboard] = options[keyboard] === false || modal[getAttribute](dataKeyboard) === 'false' ? false : true;
    this[backdrop] = options[backdrop] === staticString || modal[getAttribute](databackdrop) === staticString ? staticString : true;
    this[backdrop] = options[backdrop] === false || modal[getAttribute](databackdrop) === 'false' ? false : this[backdrop];
    this[animation] = hasClass(modal, 'fade') ? true : false;
    this[content]  = options[content]; // JavaScript only
  
    // set an initial state of the modal
    modal[isAnimating] = false;
    
    // bind, constants, event targets and other vars
    var self = this, relatedTarget = null,
      bodyIsOverflowing, scrollBarWidth, overlay, overlayDelay, modalTimer,
  
      // also find fixed-top / fixed-bottom items
      fixedItems = getElementsByClassName(HTML,fixedTop).concat(getElementsByClassName(HTML,fixedBottom)),
  
      // private methods
      getWindowWidth = function() {
        var htmlRect = HTML[getBoundingClientRect]();
        return globalObject[innerWidth] || (htmlRect[right] - Math.abs(htmlRect[left]));
      },
      setScrollbar = function () {
        var bodyStyle = DOC[body].currentStyle || globalObject[getComputedStyle](DOC[body]),
            bodyPad = parseInt((bodyStyle[paddingRight]), 10), itemPad;
        if (bodyIsOverflowing) {
          DOC[body][style][paddingRight] = (bodyPad + scrollBarWidth) + 'px';
          modal[style][paddingRight] = scrollBarWidth+'px';
          if (fixedItems[length]){
            for (var i = 0; i < fixedItems[length]; i++) {
              itemPad = (fixedItems[i].currentStyle || globalObject[getComputedStyle](fixedItems[i]))[paddingRight];
              fixedItems[i][style][paddingRight] = ( parseInt(itemPad) + scrollBarWidth) + 'px';
            }
          }
        }
      },
      resetScrollbar = function () {
        DOC[body][style][paddingRight] = '';
        modal[style][paddingRight] = '';
        if (fixedItems[length]){
          for (var i = 0; i < fixedItems[length]; i++) {
            fixedItems[i][style][paddingRight] = '';
          }
        }
      },
      measureScrollbar = function () { // thx walsh
        var scrollDiv = DOC[createElement]('div'), widthValue;
        scrollDiv.className = component+'-scrollbar-measure'; // this is here to stay
        DOC[body][appendChild](scrollDiv);
        widthValue = scrollDiv[offsetWidth] - scrollDiv[clientWidth];
        DOC[body].removeChild(scrollDiv);
        return widthValue;
      },
      checkScrollbar = function () {
        bodyIsOverflowing = DOC[body][clientWidth] < getWindowWidth();
        scrollBarWidth = measureScrollbar();
      },
      createOverlay = function() {
        var newOverlay = DOC[createElement]('div');
        overlay = queryElement('.'+modalBackdropString);
  
        if ( overlay === null ) {
          newOverlay[setAttribute]('class', modalBackdropString + (self[animation] ? ' fade' : ''));
          overlay = newOverlay;
          DOC[body][appendChild](overlay);
        }
        modalOverlay = 1;
      },
      removeOverlay = function() {
        overlay = queryElement('.'+modalBackdropString);
        if ( overlay && overlay !== null && typeof overlay === 'object' ) {
          modalOverlay = 0;
          DOC[body].removeChild(overlay); overlay = null;
        }    
      },
      // triggers
      triggerShow = function() {
        setFocus(modal);
        modal[isAnimating] = false;
        bootstrapCustomEvent.call(modal, shownEvent, component, relatedTarget);
  
        on(globalObject, resizeEvent, self.update, passiveHandler);
        on(modal, clickEvent, dismissHandler);
        on(DOC, keydownEvent, keyHandler);      
      },
      triggerHide = function() {
        modal[style].display = '';
        element && (setFocus(element));
        bootstrapCustomEvent.call(modal, hiddenEvent, component);
  
        (function(){
          if (!getElementsByClassName(DOC,component+' '+inClass)[0]) {
            resetScrollbar();
            removeClass(DOC[body],component+'-open');
            overlay && hasClass(overlay,'fade') ? (removeClass(overlay,inClass), emulateTransitionEnd(overlay,removeOverlay))
            : removeOverlay();
  
            off(globalObject, resizeEvent, self.update, passiveHandler);
            off(modal, clickEvent, dismissHandler);
            off(DOC, keydownEvent, keyHandler);    
          }
        }());
        modal[isAnimating] = false;
      },
      // handlers
      clickHandler = function(e) {
        if ( modal[isAnimating] ) return;
  
        var clickTarget = e[target];
        clickTarget = clickTarget[hasAttribute](dataTarget) || clickTarget[hasAttribute]('href') ? clickTarget : clickTarget[parentNode];
        if ( clickTarget === element && !hasClass(modal,inClass) ) {
          modal[modalTrigger] = element;
          relatedTarget = element;
          self.show();
          e[preventDefault]();
        }
      },
      keyHandler = function(e) {
        if ( modal[isAnimating] ) return;
  
        var key = e.which || e.keyCode; // keyCode for IE8
        if (self[keyboard] && key == 27 && hasClass(modal,inClass)) {
          self.hide();
        }
      },
      dismissHandler = function(e) {
        if ( modal[isAnimating] ) return;
  
        var clickTarget = e[target];
        if ( hasClass(modal,inClass) && (clickTarget[parentNode][getAttribute](dataDismiss) === component
            || clickTarget[getAttribute](dataDismiss) === component
            || clickTarget === modal && self[backdrop] !== staticString) ) {
          self.hide(); relatedTarget = null;
          e[preventDefault]();
        }
      };
  
    // public methods
    this.toggle = function() {
      if ( hasClass(modal,inClass) ) {this.hide();} else {this.show();}
    };
    this.show = function() {
      if ( hasClass(modal,inClass) || modal[isAnimating] ) {return}
  
      clearTimeout(modalTimer);
      modalTimer = setTimeout(function(){
        modal[isAnimating] = true;    
        bootstrapCustomEvent.call(modal, showEvent, component, relatedTarget);
  
        // we elegantly hide any opened modal
        var currentOpen = getElementsByClassName(DOC,component+' in')[0];
        if (currentOpen && currentOpen !== modal) {
          modalTrigger in currentOpen && currentOpen[modalTrigger][stringModal].hide();
          stringModal in currentOpen && currentOpen[stringModal].hide();
        }
  
        if ( self[backdrop] ) {
          !modalOverlay && !overlay && createOverlay();
        }
  
        if ( overlay && !hasClass(overlay,inClass)) {
          overlay[offsetWidth]; // force reflow to enable trasition
          overlayDelay = getTransitionDurationFromElement(overlay);
          addClass(overlay,inClass);
        }
  
        setTimeout( function() {
          modal[style].display = 'block';
  
          checkScrollbar();
          setScrollbar();
  
          addClass(DOC[body],component+'-open');
          addClass(modal,inClass);
          modal[setAttribute](ariaHidden, false);
  
          hasClass(modal,'fade') ? emulateTransitionEnd(modal, triggerShow) : triggerShow();
        }, supportTransitions && overlay && overlayDelay ? overlayDelay : 1);
      },1);
    };
    this.hide = function() {
      if ( modal[isAnimating] || !hasClass(modal,inClass) ) {return}
  
      clearTimeout(modalTimer);
      modalTimer = setTimeout(function(){
        modal[isAnimating] = true;
        bootstrapCustomEvent.call(modal, hideEvent, component);
        overlay = queryElement('.'+modalBackdropString);
        overlayDelay = overlay && getTransitionDurationFromElement(overlay);
  
        removeClass(modal,inClass);
        modal[setAttribute](ariaHidden, true);
  
        setTimeout(function(){
          hasClass(modal,'fade') ? emulateTransitionEnd(modal, triggerHide) : triggerHide();
        }, supportTransitions && overlay && overlayDelay ? overlayDelay : 2);
      },2)
    };
    this.setContent = function( content ) {
      queryElement('.'+component+'-content',modal)[innerHTML] = content;
    };
    this.update = function() {
      if (hasClass(modal,inClass)) {
        checkScrollbar();
        setScrollbar();
      }
    };
  
    // init
    // prevent adding event handlers over and over
    // modal is independent of a triggering element
    if ( !!element && !(stringModal in element) ) {
      on(element, clickEvent, clickHandler);
    }
    if ( !!self[content] ) { self.setContent( self[content] ); }
    if (element) { element[stringModal] = self; modal[modalTrigger] = element; }
    else { modal[stringModal] = self; }
  };
  
  // DATA API
  supports[push]( [ stringModal, Modal, '['+dataToggle+'="modal"]' ] );
  
  /* Native Javascript for Bootstrap 3 | Popover
  ----------------------------------------------*/
  
  // POPOVER DEFINITION
  // ==================
  var Popover = function( element, options ) {
  
    // initialization element
    element = queryElement(element);
  
    // set options
    options = options || {};
  
    // DATA API
    var triggerData = element[getAttribute](dataTrigger), // click / hover / focus
        animationData = element[getAttribute](dataAnimation), // true / false
        placementData = element[getAttribute](dataPlacement),
        dismissibleData = element[getAttribute](dataDismissible),
        delayData = element[getAttribute](dataDelay),
        containerData = element[getAttribute](dataContainer),
  
        // internal strings
        component = 'popover',
        template = 'template',
        trigger = 'trigger',
        classString = 'class',
        div = 'div',
        fade = 'fade',
        dataContent = 'data-content',
        dismissible = 'dismissible',
        closeBtn = '<button type="button" class="close">×</button>',
  
        // check container
        containerElement = queryElement(options[container]),
        containerDataElement = queryElement(containerData),      
        
        // maybe the element is inside a modal
        modal = getClosest(element,'.modal'),
        
        // maybe the element is inside a fixed navbar
        navbarFixedTop = getClosest(element,'.'+fixedTop),
        navbarFixedBottom = getClosest(element,'.'+fixedBottom);
  
    // set instance options
    this[template] = options[template] ? options[template] : null; // JavaScript only
    this[trigger] = options[trigger] ? options[trigger] : triggerData || hoverEvent;
    this[animation] = options[animation] && options[animation] !== fade ? options[animation] : animationData || fade;
    this[placement] = options[placement] ? options[placement] : placementData || top;
    this[delay] = parseInt(options[delay] || delayData) || 200;
    this[dismissible] = options[dismissible] || dismissibleData === 'true' ? true : false;
    this[container] = containerElement ? containerElement 
                    : containerDataElement ? containerDataElement 
                    : navbarFixedTop ? navbarFixedTop
                    : navbarFixedBottom ? navbarFixedBottom
                    : modal ? modal : DOC[body];
  
    // bind, content
    var self = this, 
      titleString = options.title || element[getAttribute](dataTitle) || null,
      contentString = options.content || element[getAttribute](dataContent) || null;
  
    if ( !contentString && !this[template] ) return; // invalidate
  
    // constants, vars
    var popover = null, timer = 0, placementSetting = this[placement],
      
      // handlers
      dismissibleHandler = function(e) {
        if (popover !== null && e[target] === queryElement('.close',popover)) {
          self.hide();
        }
      },
  
      // private methods
      removePopover = function() {
        self[container].removeChild(popover);
        timer = null; popover = null; 
      },
      createPopover = function() {
        titleString = options.title || element[getAttribute](dataTitle);
        contentString = options.content || element[getAttribute](dataContent);
        // fixing https://github.com/thednp/bootstrap.native/issues/233
        contentString = !!contentString ? contentString.replace(/^\s+|\s+$/g, '') : null;
  
        popover = DOC[createElement](div);
  
        if ( contentString !== null && self[template] === null ) { //create the popover from data attributes
  
          popover[setAttribute]('role','tooltip');
  
          if (titleString !== null) {
            var popoverTitle = DOC[createElement]('h3');
            popoverTitle[setAttribute](classString,component+'-title');
  
            popoverTitle[innerHTML] = self[dismissible] ? titleString + closeBtn : titleString;
            popover[appendChild](popoverTitle);
          }
  
          var popoverArrow = DOC[createElement](div), popoverContent = DOC[createElement](div);
          popoverArrow[setAttribute](classString,'arrow'); popoverContent[setAttribute](classString,component+'-content');
          popover[appendChild](popoverArrow); popover[appendChild](popoverContent);
  
          //set popover content
          popoverContent[innerHTML] = self[dismissible] && titleString === null ? contentString + closeBtn : contentString;
  
        } else {  // or create the popover from template
          var popoverTemplate = DOC[createElement](div);
          self[template] = self[template].replace(/^\s+|\s+$/g, '');
          popoverTemplate[innerHTML] = self[template];
          popover[innerHTML] = popoverTemplate.firstChild[innerHTML];
        }
  
        //append to the container
        self[container][appendChild](popover);
        popover[style].display = 'block';
        popover[setAttribute](classString, component+ ' ' + placementSetting + ' ' + self[animation]);
      },
      showPopover = function () {
        !hasClass(popover,inClass) && ( addClass(popover,inClass) );
      },
      updatePopover = function() {
        styleTip(element,popover,placementSetting,self[container]);
      },
      
      // event toggle
      dismissHandlerToggle = function(type){
        if (clickEvent == self[trigger] || 'focus' == self[trigger]) {
          !self[dismissible] && type( element, 'blur', self.hide );
        }
        self[dismissible] && type( DOC, clickEvent, dismissibleHandler );
        !isIE8 && type( globalObject, resizeEvent, self.hide, passiveHandler );
      },
  
      // triggers
      showTrigger = function() {
        dismissHandlerToggle(on);
        bootstrapCustomEvent.call(element, shownEvent, component);
      },
      hideTrigger = function() {
        dismissHandlerToggle(off);
        removePopover();
        bootstrapCustomEvent.call(element, hiddenEvent, component);
      };
  
    // public methods / handlers
    this.toggle = function() {
      if (popover === null) { self.show(); } 
      else { self.hide(); }
    };
    this.show = function() {
      clearTimeout(timer);
      timer = setTimeout( function() {
        if (popover === null) {
          placementSetting = self[placement]; // we reset placement in all cases
          createPopover();
          updatePopover();
          showPopover();
          bootstrapCustomEvent.call(element, showEvent, component);
          !!self[animation] ? emulateTransitionEnd(popover, showTrigger) : showTrigger();
        }
      }, 20 );
    };
    this.hide = function() {
      clearTimeout(timer);
      timer = setTimeout( function() {
        if (popover && popover !== null && hasClass(popover,inClass)) {
          bootstrapCustomEvent.call(element, hideEvent, component);
          removeClass(popover,inClass);
          !!self[animation] ? emulateTransitionEnd(popover, hideTrigger) : hideTrigger();
        }
      }, self[delay] );
    };
  
    // init
    if ( !(stringPopover in element) ) { // prevent adding event handlers twice
      if (self[trigger] === hoverEvent) {
        on( element, mouseHover[0], self.show );
        if (!self[dismissible]) { on( element, mouseHover[1], self.hide ); }
      } else if (clickEvent == self[trigger] || 'focus' == self[trigger]) {
        on( element, self[trigger], self.toggle );
      }    
    }
    element[stringPopover] = self;
  };
  
  // POPOVER DATA API
  // ================
  supports[push]( [ stringPopover, Popover, '['+dataToggle+'="popover"]' ] );
  
  
  /* Native Javascript for Bootstrap 3 | ScrollSpy
  -----------------------------------------------*/
  
  // SCROLLSPY DEFINITION
  // ====================
  var ScrollSpy = function(element, options) {
  
    // initialization element, the element we spy on
    element = queryElement(element); 
  
    // DATA API
    var targetData = queryElement(element[getAttribute](dataTarget)),
        offsetData = element[getAttribute]('data-offset');
  
    // set options
    options = options || {};
  
    // invalidate
    if ( !options[target] && !targetData ) { return; } 
  
    // event targets, constants
    var self = this, spyTarget = options[target] && queryElement(options[target]) || targetData,
        links = spyTarget && spyTarget[getElementsByTagName]('A'),
        offset = parseInt(options['offset'] || offsetData) || 10,      
        items = [], targetItems = [], scrollOffset,
        scrollTarget = element[offsetHeight] < element[scrollHeight] ? element : globalObject, // determine which is the real scrollTarget
        isWindow = scrollTarget === globalObject;  
  
    // populate items and targets
    for (var i=0, il=links[length]; i<il; i++) {
      var href = links[i][getAttribute]('href'), 
          targetItem = href && href.charAt(0) === '#' && href.slice(-1) !== '#' && queryElement(href);
      if ( !!targetItem ) {
        items[push](links[i]);
        targetItems[push](targetItem);
      }
    }
  
    // private methods
    var updateItem = function(index) {
      var parent = items[index][parentNode], // item's parent LI element
          targetItem = targetItems[index], // the menu item targets this element
          dropdown = getClosest(parent,'.dropdown'),
          targetRect = isWindow && targetItem[getBoundingClientRect](),
  
          isActive = hasClass(parent,active) || false,
  
          topEdge = (isWindow ? targetRect[top] + scrollOffset : targetItem[offsetTop]) - offset,
          bottomEdge = isWindow ? targetRect[bottom] + scrollOffset - offset : targetItems[index+1] ? targetItems[index+1][offsetTop] - offset : element[scrollHeight],
  
          inside = scrollOffset >= topEdge && bottomEdge > scrollOffset;
  
        if ( !isActive && inside ) {
          if ( parent.tagName === 'LI' && !hasClass(parent,active) ) {
            addClass(parent,active);
            if (dropdown && !hasClass(dropdown,active) ) {
              addClass(dropdown,active);
            }
            bootstrapCustomEvent.call(element, 'activate', 'scrollspy', items[index]);
          }
        } else if ( !inside ) {
          if ( parent.tagName === 'LI' && hasClass(parent,active) ) {
            removeClass(parent,active);
            if (dropdown && hasClass(dropdown,active) && !getElementsByClassName(parent[parentNode],active).length ) {
              removeClass(dropdown,active);
            }
          }
        } else if ( !inside && !isActive || isActive && inside ) {
          return;
        }
      },
      updateItems = function(){
        scrollOffset = isWindow ? getScroll().y : element[scrollTop];
        for (var index=0, itl=items[length]; index<itl; index++) {
          updateItem(index)
        }
      };
  
    // public method
    this.refresh = function () {
      updateItems();
    }
  
    // init
    if ( !(stringScrollSpy in element) ) { // prevent adding event handlers twice
      on( scrollTarget, scrollEvent, self.refresh, passiveHandler );
      !isIE8 && on( globalObject, resizeEvent, self.refresh, passiveHandler ); 
  }
    self.refresh();
    element[stringScrollSpy] = self;
  };
  
  // SCROLLSPY DATA API
  // ==================
  supports[push]( [ stringScrollSpy, ScrollSpy, '['+dataSpy+'="scroll"]' ] );
  
  
  /* Native Javascript for Bootstrap 3 | Tab
  -----------------------------------------*/
  
  // TAB DEFINITION
  // ==============
  var Tab = function( element, options ) {
  
    // initialization element
    element = queryElement(element);
  
    // DATA API
    var heightData = element[getAttribute](dataHeight),
      
        // strings
        component = 'tab', height = 'height', float = 'float', isAnimating = 'isAnimating';
  
    // set options
    options = options || {};
    this[height] = supportTransitions ? (options[height] || heightData === 'true') : false; // filter legacy browsers
  
    // bind, event targets
    var self = this, next,
      tabs = getClosest(element,'.nav'),
      tabsContentContainer = false,
      dropdown = tabs && queryElement('.dropdown',tabs),
      activeTab, activeContent, nextContent, containerHeight, equalContents, nextHeight,
  
      // trigger
      triggerEnd = function(){
        tabsContentContainer[style][height] = '';
        removeClass(tabsContentContainer,collapsing);
        tabs[isAnimating] = false;
      },
      triggerShow = function() {
        if (tabsContentContainer) { // height animation
          if ( equalContents ) {
            triggerEnd();
          } else {
            setTimeout(function(){ // enables height animation
              tabsContentContainer[style][height] = nextHeight + 'px'; // height animation
              tabsContentContainer[offsetWidth];
              emulateTransitionEnd(tabsContentContainer, triggerEnd);
            },50);
          }
        } else {
          tabs[isAnimating] = false; 
        }
        bootstrapCustomEvent.call(next, shownEvent, component, activeTab);
      },
      triggerHide = function() {
        if (tabsContentContainer) {
          activeContent[style][float] = left;
          nextContent[style][float] = left;        
          containerHeight = activeContent[scrollHeight];
        }
        
        addClass(nextContent,active);
        bootstrapCustomEvent.call(next, showEvent, component, activeTab);
        
        removeClass(activeContent,active);
        bootstrapCustomEvent.call(activeTab, hiddenEvent, component, next);
        
        if (tabsContentContainer) {
          nextHeight = nextContent[scrollHeight];
          equalContents = nextHeight === containerHeight;
          addClass(tabsContentContainer,collapsing);
          tabsContentContainer[style][height] = containerHeight + 'px'; // height animation
          tabsContentContainer[offsetHeight];
          activeContent[style][float] = '';
          nextContent[style][float] = '';
        }
  
        if ( hasClass(nextContent, 'fade') ) {
          setTimeout(function(){
            addClass(nextContent,inClass);
            emulateTransitionEnd(nextContent,triggerShow);
          },20);
        } else { triggerShow(); }        
      };
  
    if (!tabs) return; // invalidate 
  
    // set default animation state
    tabs[isAnimating] = false;
      
    // private methods
    var getActiveTab = function() {
        var activeTabs = getElementsByClassName(tabs,active), activeTab;
        if ( activeTabs[length] === 1 && !hasClass(activeTabs[0],'dropdown') ) {
          activeTab = activeTabs[0];
        } else if ( activeTabs[length] > 1 ) {
          activeTab = activeTabs[activeTabs[length]-1];
        }
        return activeTab[getElementsByTagName]('A')[0];
      },
      getActiveContent = function() {
        return queryElement(getActiveTab()[getAttribute]('href'));
      },
      // handler
      clickHandler = function(e) {
        e[preventDefault]();
        next = e[currentTarget] || this; // IE8 needs to know who really currentTarget is
        !tabs[isAnimating] && !hasClass(next[parentNode],active) && self.show();
      };
  
    // public method
    this.show = function() { // the tab we clicked is now the next tab
      next = next || element;
      nextContent = queryElement(next[getAttribute]('href')); //this is the actual object, the next tab content to activate
      activeTab = getActiveTab(); 
      activeContent = getActiveContent();
  
      tabs[isAnimating] = true;
      removeClass(activeTab[parentNode],active);
      activeTab[setAttribute](ariaExpanded,'false');
      addClass(next[parentNode],active);
      next[setAttribute](ariaExpanded,'true');
  
      if ( dropdown ) {
        if ( !hasClass(element[parentNode][parentNode],'dropdown-menu') ) {
          if (hasClass(dropdown,active)) removeClass(dropdown,active);
        } else {
          if (!hasClass(dropdown,active)) addClass(dropdown,active);
        }
      }
      
      bootstrapCustomEvent.call(activeTab, hideEvent, component, next);
      
      if (hasClass(activeContent, 'fade')) {
        removeClass(activeContent,inClass);
        emulateTransitionEnd(activeContent, triggerHide);
      } else { triggerHide(); }
    };
  
    // init
    if ( !(stringTab in element) ) { // prevent adding event handlers twice
      on(element, clickEvent, clickHandler);
    }
    if (self[height]) { tabsContentContainer = getActiveContent()[parentNode]; }
    element[stringTab] = self;
  };
  
  // TAB DATA API
  // ============
  supports[push]( [ stringTab, Tab, '['+dataToggle+'="tab"]' ] );
  
  
  /* Native Javascript for Bootstrap 3 | Tooltip
  ---------------------------------------------*/
  
  // TOOLTIP DEFINITION
  // ==================
  var Tooltip = function( element,options ) {
  
    // initialization element
    element = queryElement(element);
  
    // set options
    options = options || {};
  
    // DATA API
    var animationData = element[getAttribute](dataAnimation),
        placementData = element[getAttribute](dataPlacement),
        delayData = element[getAttribute](dataDelay),
        containerData = element[getAttribute](dataContainer),
        
        // strings
        component = 'tooltip',
        classString = 'class',
        title = 'title',
        fade = 'fade',
        div = 'div',
  
        // check container
        containerElement = queryElement(options[container]),
        containerDataElement = queryElement(containerData),        
  
        // maybe the element is inside a modal
        modal = getClosest(element,'.modal'),
        
        // maybe the element is inside a fixed navbar
        navbarFixedTop = getClosest(element,'.'+fixedTop),
        navbarFixedBottom = getClosest(element,'.'+fixedBottom);
  
    // set instance options
    this[animation] = options[animation] && options[animation] !== fade ? options[animation] : animationData || fade;
    this[placement] = options[placement] ? options[placement] : placementData || top;
    this[delay] = parseInt(options[delay] || delayData) || 200;
    this[container] = containerElement ? containerElement 
                    : containerDataElement ? containerDataElement 
                    : navbarFixedTop ? navbarFixedTop
                    : navbarFixedBottom ? navbarFixedBottom
                    : modal ? modal : DOC[body];
  
    // bind, event targets, title and constants
    var self = this, timer = 0, placementSetting = this[placement], tooltip = null,
      titleString = element[getAttribute](title) || element[getAttribute](dataTitle) || element[getAttribute](dataOriginalTitle);
  
    if ( !titleString || titleString == "" ) return; // invalidate
  
    // private methods
    var removeToolTip = function() {
        self[container].removeChild(tooltip);
        tooltip = null; timer = null;
      },
      createToolTip = function() {
        titleString = element[getAttribute](title) || element[getAttribute](dataTitle) || element[getAttribute](dataOriginalTitle); // read the title again
        if ( !titleString || titleString == "" ) return false; // invalidate
        
        tooltip = DOC[createElement](div);
        tooltip[setAttribute]('role',component);
  
        var tooltipArrow = DOC[createElement](div), tooltipInner = DOC[createElement](div);
        tooltipArrow[setAttribute](classString, component+'-arrow'); tooltipInner[setAttribute](classString,component+'-inner');
  
        tooltip[appendChild](tooltipArrow); tooltip[appendChild](tooltipInner);
  
        tooltipInner[innerHTML] = titleString;
  
        self[container][appendChild](tooltip);
        tooltip[setAttribute](classString, component + ' ' + placementSetting + ' ' + self[animation]);
      },
      updateTooltip = function () {
        styleTip(element,tooltip,placementSetting,self[container]);
      },
      showTooltip = function () {
        !hasClass(tooltip,inClass) && ( addClass(tooltip,inClass) );
      },
      // triggers
      showTrigger = function() {
        bootstrapCustomEvent.call(element, shownEvent, component);
        !isIE8 && on( globalObject, resizeEvent, self.hide, passiveHandler );      
      },
      hideTrigger = function() {
        !isIE8 && off( globalObject, resizeEvent, self.hide, passiveHandler );      
        removeToolTip();
        bootstrapCustomEvent.call(element, hiddenEvent, component);
      };
  
    // public methods
    this.show = function() {
      clearTimeout(timer);
      timer = setTimeout( function() {
        if (tooltip === null) {
          placementSetting = self[placement]; // we reset placement in all cases
          if(createToolTip() == false) return;
          updateTooltip();
          showTooltip();
          bootstrapCustomEvent.call(element, showEvent, component);
          !!self[animation] ? emulateTransitionEnd(tooltip, showTrigger) : showTrigger();
        }
      }, 20 );
    };
    this.hide = function() {
      clearTimeout(timer);
      timer = setTimeout( function() {
        if (tooltip && hasClass(tooltip,inClass)) {
          bootstrapCustomEvent.call(element, hideEvent, component);
          removeClass(tooltip,inClass);
          !!self[animation] ? emulateTransitionEnd(tooltip, hideTrigger) : hideTrigger();
        }
      }, self[delay]);
    };
    this.toggle = function() {
      if (!tooltip) { self.show(); } 
      else { self.hide(); }
    };
  
    // init
    if ( !(stringTooltip in element) ) { // prevent adding event handlers twice
      element[setAttribute](dataOriginalTitle,titleString);
      element.removeAttribute(title);
      on(element, mouseHover[0], self.show);
      on(element, mouseHover[1], self.hide);
    }
    element[stringTooltip] = self;
  };
  
  // TOOLTIP DATA API
  // =================
  supports[push]( [ stringTooltip, Tooltip, '['+dataToggle+'="tooltip"]' ] );
  
  
  
  /* Native Javascript for Bootstrap | Initialize Data API
  --------------------------------------------------------*/
  var initializeDataAPI = function( constructor, collection ){
      for (var i=0, l=collection[length]; i<l; i++) {
        new constructor(collection[i]);
      }
    },
    initCallback = BSN.initCallback = function(lookUp){
      lookUp = lookUp || DOC;
      for (var i=0, l=supports[length]; i<l; i++) {
        initializeDataAPI( supports[i][1], lookUp[querySelectorAll] (supports[i][2]) );
      }
    };
  
  // bulk initialize all components
  DOC[body] ? initCallback() : on( DOC, 'DOMContentLoaded', function(){ initCallback(); } );
  
  return {
    Affix: Affix,
    Alert: Alert,
    Button: Button,
    Carousel: Carousel,
    Collapse: Collapse,
    Dropdown: Dropdown,
    Modal: Modal,
    Popover: Popover,
    ScrollSpy: ScrollSpy,
    Tab: Tab,
    Tooltip: Tooltip
  };
}));

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})

},{}]},{},[1])
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIm5vZGVfbW9kdWxlcy9icm93c2VyLXBhY2svX3ByZWx1ZGUuanMiLCJsaWJzL2xpYnMuanMiLCJub2RlX21vZHVsZXMvYm9vdHN0cmFwLm5hdGl2ZS9kaXN0L2Jvb3RzdHJhcC1uYXRpdmUuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQUE7QUNBQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7OztBQ2pCQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBIiwiZmlsZSI6ImdlbmVyYXRlZC5qcyIsInNvdXJjZVJvb3QiOiIiLCJzb3VyY2VzQ29udGVudCI6WyIoZnVuY3Rpb24oKXtmdW5jdGlvbiByKGUsbix0KXtmdW5jdGlvbiBvKGksZil7aWYoIW5baV0pe2lmKCFlW2ldKXt2YXIgYz1cImZ1bmN0aW9uXCI9PXR5cGVvZiByZXF1aXJlJiZyZXF1aXJlO2lmKCFmJiZjKXJldHVybiBjKGksITApO2lmKHUpcmV0dXJuIHUoaSwhMCk7dmFyIGE9bmV3IEVycm9yKFwiQ2Fubm90IGZpbmQgbW9kdWxlICdcIitpK1wiJ1wiKTt0aHJvdyBhLmNvZGU9XCJNT0RVTEVfTk9UX0ZPVU5EXCIsYX12YXIgcD1uW2ldPXtleHBvcnRzOnt9fTtlW2ldWzBdLmNhbGwocC5leHBvcnRzLGZ1bmN0aW9uKHIpe3ZhciBuPWVbaV1bMV1bcl07cmV0dXJuIG8obnx8cil9LHAscC5leHBvcnRzLHIsZSxuLHQpfXJldHVybiBuW2ldLmV4cG9ydHN9Zm9yKHZhciB1PVwiZnVuY3Rpb25cIj09dHlwZW9mIHJlcXVpcmUmJnJlcXVpcmUsaT0wO2k8dC5sZW5ndGg7aSsrKW8odFtpXSk7cmV0dXJuIG99cmV0dXJuIHJ9KSgpIiwiLy9cbi8vIG5wbSBkZXBlbmRlbmNpZXMgbGlicmFyeVxuLy9cbihmdW5jdGlvbiAoc2NvcGUpIHtcbiAgXCJ1c2Utc3RyaWN0XCI7XG4gIHNjb3BlLl9fcmVnaXN0cnlfXyA9IE9iamVjdC5hc3NpZ24oe30sIHNjb3BlLl9fcmVnaXN0cnlfXywge1xuICAgIC8vXG4gICAgLy8gbGlzdCBucG0gbW9kdWxlcyByZXF1aXJlZCBpbiBIYXhlXG4gICAgLy9cbiAgICBcImJvb3RzdHJhcC5uYXRpdmVcIjogcmVxdWlyZShcImJvb3RzdHJhcC5uYXRpdmVcIiksXG4gIH0pO1xuXG4gIC8qaWYgKHByb2Nlc3MuZW52Lk5PREVfRU5WICE9PSAncHJvZHVjdGlvbicpIHtcbiAgICAgIC8vIGVuYWJsZSBSZWFjdCBob3QtcmVsb2FkXG4gICAgICByZXF1aXJlKCdoYXhlLW1vZHVsYXInKTtcbiAgICB9Ki9cbn0pKHR5cGVvZiAkaHhfc2NvcGUgIT0gXCJ1bmRlZmluZWRcIiA/ICRoeF9zY29wZSA6ICgkaHhfc2NvcGUgPSB7fSkpO1xuIiwiLy8gTmF0aXZlIEphdmFzY3JpcHQgZm9yIEJvb3RzdHJhcCAzIHYyLjAuMjcgfCDCqSBkbnBfdGhlbWUgfCBNSVQtTGljZW5zZVxuKGZ1bmN0aW9uIChyb290LCBmYWN0b3J5KSB7XG4gIGlmICh0eXBlb2YgZGVmaW5lID09PSAnZnVuY3Rpb24nICYmIGRlZmluZS5hbWQpIHtcbiAgICAvLyBBTUQgc3VwcG9ydDpcbiAgICBkZWZpbmUoW10sIGZhY3RvcnkpO1xuICB9IGVsc2UgaWYgKHR5cGVvZiBtb2R1bGUgPT09ICdvYmplY3QnICYmIG1vZHVsZS5leHBvcnRzKSB7XG4gICAgLy8gQ29tbW9uSlMtbGlrZTpcbiAgICBtb2R1bGUuZXhwb3J0cyA9IGZhY3RvcnkoKTtcbiAgfSBlbHNlIHtcbiAgICAvLyBCcm93c2VyIGdsb2JhbHMgKHJvb3QgaXMgd2luZG93KVxuICAgIHZhciBic24gPSBmYWN0b3J5KCk7XG4gICAgcm9vdC5BZmZpeCA9IGJzbi5BZmZpeDtcbiAgICByb290LkFsZXJ0ID0gYnNuLkFsZXJ0O1xuICAgIHJvb3QuQnV0dG9uID0gYnNuLkJ1dHRvbjtcbiAgICByb290LkNhcm91c2VsID0gYnNuLkNhcm91c2VsO1xuICAgIHJvb3QuQ29sbGFwc2UgPSBic24uQ29sbGFwc2U7XG4gICAgcm9vdC5Ecm9wZG93biA9IGJzbi5Ecm9wZG93bjtcbiAgICByb290Lk1vZGFsID0gYnNuLk1vZGFsO1xuICAgIHJvb3QuUG9wb3ZlciA9IGJzbi5Qb3BvdmVyO1xuICAgIHJvb3QuU2Nyb2xsU3B5ID0gYnNuLlNjcm9sbFNweTtcbiAgICByb290LlRhYiA9IGJzbi5UYWI7XG4gICAgcm9vdC5Ub29sdGlwID0gYnNuLlRvb2x0aXA7XG4gIH1cbn0odGhpcywgZnVuY3Rpb24gKCkge1xuICBcbiAgLyogTmF0aXZlIEphdmFzY3JpcHQgZm9yIEJvb3RzdHJhcCAzIHwgSW50ZXJuYWwgVXRpbGl0eSBGdW5jdGlvbnNcbiAgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSovXG4gIFwidXNlIHN0cmljdFwiO1xuICBcbiAgLy8gZ2xvYmFsc1xuICB2YXIgZ2xvYmFsT2JqZWN0ID0gdHlwZW9mIGdsb2JhbCAhPT0gJ3VuZGVmaW5lZCcgPyBnbG9iYWwgOiB0aGlzfHx3aW5kb3csXG4gICAgRE9DID0gZG9jdW1lbnQsIEhUTUwgPSBET0MuZG9jdW1lbnRFbGVtZW50LCBib2R5ID0gJ2JvZHknLCAvLyBhbGxvdyB0aGUgbGlicmFyeSB0byBiZSB1c2VkIGluIDxoZWFkPlxuICBcbiAgICAvLyBOYXRpdmUgSmF2YXNjcmlwdCBmb3IgQm9vdHN0cmFwIEdsb2JhbCBPYmplY3RcbiAgICBCU04gPSBnbG9iYWxPYmplY3QuQlNOID0ge30sXG4gICAgc3VwcG9ydHMgPSBCU04uc3VwcG9ydHMgPSBbXSxcbiAgXG4gICAgLy8gZnVuY3Rpb24gdG9nZ2xlIGF0dHJpYnV0ZXNcbiAgICBkYXRhVG9nZ2xlICAgID0gJ2RhdGEtdG9nZ2xlJyxcbiAgICBkYXRhRGlzbWlzcyAgID0gJ2RhdGEtZGlzbWlzcycsXG4gICAgZGF0YVNweSAgICAgICA9ICdkYXRhLXNweScsXG4gICAgZGF0YVJpZGUgICAgICA9ICdkYXRhLXJpZGUnLFxuICAgIFxuICAgIC8vIGNvbXBvbmVudHNcbiAgICBzdHJpbmdBZmZpeCAgICAgPSAnQWZmaXgnLFxuICAgIHN0cmluZ0FsZXJ0ICAgICA9ICdBbGVydCcsXG4gICAgc3RyaW5nQnV0dG9uICAgID0gJ0J1dHRvbicsXG4gICAgc3RyaW5nQ2Fyb3VzZWwgID0gJ0Nhcm91c2VsJyxcbiAgICBzdHJpbmdDb2xsYXBzZSAgPSAnQ29sbGFwc2UnLFxuICAgIHN0cmluZ0Ryb3Bkb3duICA9ICdEcm9wZG93bicsXG4gICAgc3RyaW5nTW9kYWwgICAgID0gJ01vZGFsJyxcbiAgICBzdHJpbmdQb3BvdmVyICAgPSAnUG9wb3ZlcicsXG4gICAgc3RyaW5nU2Nyb2xsU3B5ID0gJ1Njcm9sbFNweScsXG4gICAgc3RyaW5nVGFiICAgICAgID0gJ1RhYicsXG4gICAgc3RyaW5nVG9vbHRpcCAgID0gJ1Rvb2x0aXAnLFxuICBcbiAgICAvLyBvcHRpb25zIERBVEEgQVBJXG4gICAgZGF0YWJhY2tkcm9wICAgICAgPSAnZGF0YS1iYWNrZHJvcCcsXG4gICAgZGF0YUtleWJvYXJkICAgICAgPSAnZGF0YS1rZXlib2FyZCcsXG4gICAgZGF0YVRhcmdldCAgICAgICAgPSAnZGF0YS10YXJnZXQnLFxuICAgIGRhdGFJbnRlcnZhbCAgICAgID0gJ2RhdGEtaW50ZXJ2YWwnLFxuICAgIGRhdGFIZWlnaHQgICAgICAgID0gJ2RhdGEtaGVpZ2h0JyxcbiAgICBkYXRhUGF1c2UgICAgICAgICA9ICdkYXRhLXBhdXNlJyxcbiAgICBkYXRhVGl0bGUgICAgICAgICA9ICdkYXRhLXRpdGxlJywgIFxuICAgIGRhdGFPcmlnaW5hbFRpdGxlID0gJ2RhdGEtb3JpZ2luYWwtdGl0bGUnLFxuICAgIGRhdGFPcmlnaW5hbFRleHQgID0gJ2RhdGEtb3JpZ2luYWwtdGV4dCcsXG4gICAgZGF0YURpc21pc3NpYmxlICAgPSAnZGF0YS1kaXNtaXNzaWJsZScsXG4gICAgZGF0YVRyaWdnZXIgICAgICAgPSAnZGF0YS10cmlnZ2VyJyxcbiAgICBkYXRhQW5pbWF0aW9uICAgICA9ICdkYXRhLWFuaW1hdGlvbicsXG4gICAgZGF0YUNvbnRhaW5lciAgICAgPSAnZGF0YS1jb250YWluZXInLFxuICAgIGRhdGFQbGFjZW1lbnQgICAgID0gJ2RhdGEtcGxhY2VtZW50JyxcbiAgICBkYXRhRGVsYXkgICAgICAgICA9ICdkYXRhLWRlbGF5JyxcbiAgICBkYXRhT2Zmc2V0VG9wICAgICA9ICdkYXRhLW9mZnNldC10b3AnLFxuICAgIGRhdGFPZmZzZXRCb3R0b20gID0gJ2RhdGEtb2Zmc2V0LWJvdHRvbScsXG4gIFxuICAgIC8vIG9wdGlvbiBrZXlzXG4gICAgYmFja2Ryb3AgPSAnYmFja2Ryb3AnLCBrZXlib2FyZCA9ICdrZXlib2FyZCcsIGRlbGF5ID0gJ2RlbGF5JyxcbiAgICBjb250ZW50ID0gJ2NvbnRlbnQnLCB0YXJnZXQgPSAndGFyZ2V0JywgY3VycmVudFRhcmdldCA9ICdjdXJyZW50VGFyZ2V0JyxcbiAgICBpbnRlcnZhbCA9ICdpbnRlcnZhbCcsIHBhdXNlID0gJ3BhdXNlJywgYW5pbWF0aW9uID0gJ2FuaW1hdGlvbicsXG4gICAgcGxhY2VtZW50ID0gJ3BsYWNlbWVudCcsIGNvbnRhaW5lciA9ICdjb250YWluZXInLCBcbiAgXG4gICAgLy8gYm94IG1vZGVsXG4gICAgb2Zmc2V0VG9wICAgID0gJ29mZnNldFRvcCcsICAgICAgb2Zmc2V0Qm90dG9tICAgPSAnb2Zmc2V0Qm90dG9tJyxcbiAgICBvZmZzZXRMZWZ0ICAgPSAnb2Zmc2V0TGVmdCcsXG4gICAgc2Nyb2xsVG9wICAgID0gJ3Njcm9sbFRvcCcsICAgICAgc2Nyb2xsTGVmdCAgICAgPSAnc2Nyb2xsTGVmdCcsXG4gICAgY2xpZW50V2lkdGggID0gJ2NsaWVudFdpZHRoJywgICAgY2xpZW50SGVpZ2h0ICAgPSAnY2xpZW50SGVpZ2h0JyxcbiAgICBvZmZzZXRXaWR0aCAgPSAnb2Zmc2V0V2lkdGgnLCAgICBvZmZzZXRIZWlnaHQgICA9ICdvZmZzZXRIZWlnaHQnLFxuICAgIGlubmVyV2lkdGggICA9ICdpbm5lcldpZHRoJywgICAgIGlubmVySGVpZ2h0ICAgID0gJ2lubmVySGVpZ2h0JyxcbiAgICBzY3JvbGxIZWlnaHQgPSAnc2Nyb2xsSGVpZ2h0JywgICBoZWlnaHQgICAgICAgICA9ICdoZWlnaHQnLFxuICBcbiAgICAvLyBhcmlhXG4gICAgYXJpYUV4cGFuZGVkID0gJ2FyaWEtZXhwYW5kZWQnLFxuICAgIGFyaWFIaWRkZW4gICA9ICdhcmlhLWhpZGRlbicsXG4gIFxuICAgIC8vIGV2ZW50IG5hbWVzXG4gICAgY2xpY2tFdmVudCAgICA9ICdjbGljaycsXG4gICAgZm9jdXNFdmVudCAgICA9ICdmb2N1cycsXG4gICAgaG92ZXJFdmVudCAgICA9ICdob3ZlcicsXG4gICAga2V5ZG93bkV2ZW50ICA9ICdrZXlkb3duJyxcbiAgICBrZXl1cEV2ZW50ICAgID0gJ2tleXVwJywgIFxuICAgIHJlc2l6ZUV2ZW50ICAgPSAncmVzaXplJywgLy8gcGFzc2l2ZVxuICAgIHNjcm9sbEV2ZW50ICAgPSAnc2Nyb2xsJywgLy8gcGFzc2l2ZVxuICAgIG1vdXNlSG92ZXIgPSAoJ29ubW91c2VsZWF2ZScgaW4gRE9DKSA/IFsgJ21vdXNlZW50ZXInLCAnbW91c2VsZWF2ZSddIDogWyAnbW91c2VvdmVyJywgJ21vdXNlb3V0JyBdLFxuICAgIC8vIHRvdWNoIHNpbmNlIDIuMC4yNlxuICAgIHRvdWNoRXZlbnRzID0geyBzdGFydDogJ3RvdWNoc3RhcnQnLCBlbmQ6ICd0b3VjaGVuZCcsIG1vdmU6J3RvdWNobW92ZScgfSwgLy8gcGFzc2l2ZVxuICAgIC8vIG9yaWdpbmFsRXZlbnRzXG4gICAgc2hvd0V2ZW50ICAgICA9ICdzaG93JyxcbiAgICBzaG93bkV2ZW50ICAgID0gJ3Nob3duJyxcbiAgICBoaWRlRXZlbnQgICAgID0gJ2hpZGUnLFxuICAgIGhpZGRlbkV2ZW50ICAgPSAnaGlkZGVuJyxcbiAgICBjbG9zZUV2ZW50ICAgID0gJ2Nsb3NlJyxcbiAgICBjbG9zZWRFdmVudCAgID0gJ2Nsb3NlZCcsXG4gICAgc2xpZEV2ZW50ICAgICA9ICdzbGlkJyxcbiAgICBzbGlkZUV2ZW50ICAgID0gJ3NsaWRlJyxcbiAgICBjaGFuZ2VFdmVudCAgID0gJ2NoYW5nZScsXG4gIFxuICAgIC8vIG90aGVyXG4gICAgZ2V0QXR0cmlidXRlICAgICAgICAgICA9ICdnZXRBdHRyaWJ1dGUnLFxuICAgIHNldEF0dHJpYnV0ZSAgICAgICAgICAgPSAnc2V0QXR0cmlidXRlJyxcbiAgICBoYXNBdHRyaWJ1dGUgICAgICAgICAgID0gJ2hhc0F0dHJpYnV0ZScsXG4gICAgY3JlYXRlRWxlbWVudCAgICAgICAgICA9ICdjcmVhdGVFbGVtZW50JyxcbiAgICBhcHBlbmRDaGlsZCAgICAgICAgICAgID0gJ2FwcGVuZENoaWxkJyxcbiAgICBpbm5lckhUTUwgICAgICAgICAgICAgID0gJ2lubmVySFRNTCcsXG4gICAgZ2V0RWxlbWVudHNCeVRhZ05hbWUgICA9ICdnZXRFbGVtZW50c0J5VGFnTmFtZScsXG4gICAgcHJldmVudERlZmF1bHQgICAgICAgICA9ICdwcmV2ZW50RGVmYXVsdCcsXG4gICAgZ2V0Qm91bmRpbmdDbGllbnRSZWN0ICA9ICdnZXRCb3VuZGluZ0NsaWVudFJlY3QnLFxuICAgIHF1ZXJ5U2VsZWN0b3JBbGwgICAgICAgPSAncXVlcnlTZWxlY3RvckFsbCcsXG4gICAgZ2V0RWxlbWVudHNCeUNMQVNTTkFNRSA9ICdnZXRFbGVtZW50c0J5Q2xhc3NOYW1lJyxcbiAgICBnZXRDb21wdXRlZFN0eWxlICAgICAgID0gJ2dldENvbXB1dGVkU3R5bGUnLCAgXG4gIFxuICAgIGluZGV4T2YgICAgICA9ICdpbmRleE9mJyxcbiAgICBwYXJlbnROb2RlICAgPSAncGFyZW50Tm9kZScsXG4gICAgbGVuZ3RoICAgICAgID0gJ2xlbmd0aCcsXG4gICAgdG9Mb3dlckNhc2UgID0gJ3RvTG93ZXJDYXNlJyxcbiAgICBUcmFuc2l0aW9uICAgPSAnVHJhbnNpdGlvbicsXG4gICAgRHVyYXRpb24gICAgID0gJ0R1cmF0aW9uJywgIFxuICAgIFdlYmtpdCAgICAgICA9ICdXZWJraXQnLFxuICAgIHN0eWxlICAgICAgICA9ICdzdHlsZScsXG4gICAgcHVzaCAgICAgICAgID0gJ3B1c2gnLFxuICAgIHRhYmluZGV4ICAgICA9ICd0YWJpbmRleCcsXG4gICAgY29udGFpbnMgICAgID0gJ2NvbnRhaW5zJywgIFxuICAgIFxuICAgIGFjdGl2ZSAgICAgPSAnYWN0aXZlJyxcbiAgICBpbkNsYXNzICAgID0gJ2luJyxcbiAgICBjb2xsYXBzaW5nID0gJ2NvbGxhcHNpbmcnLFxuICAgIGRpc2FibGVkICAgPSAnZGlzYWJsZWQnLFxuICAgIGxvYWRpbmcgICAgPSAnbG9hZGluZycsXG4gICAgbGVmdCAgICAgICA9ICdsZWZ0JyxcbiAgICByaWdodCAgICAgID0gJ3JpZ2h0JyxcbiAgICB0b3AgICAgICAgID0gJ3RvcCcsXG4gICAgYm90dG9tICAgICA9ICdib3R0b20nLFxuICBcbiAgICAvLyBJRTggYnJvd3NlciBkZXRlY3RcbiAgICBpc0lFOCA9ICEoJ29wYWNpdHknIGluIEhUTUxbc3R5bGVdKSxcbiAgXG4gICAgLy8gdG9vbHRpcCAvIHBvcG92ZXJcbiAgICB0aXBQb3NpdGlvbnMgPSAvXFxiKHRvcHxib3R0b218bGVmdHxyaWdodCkrLyxcbiAgICBcbiAgICAvLyBtb2RhbFxuICAgIG1vZGFsT3ZlcmxheSA9IDAsXG4gICAgZml4ZWRUb3AgPSAnbmF2YmFyLWZpeGVkLXRvcCcsXG4gICAgZml4ZWRCb3R0b20gPSAnbmF2YmFyLWZpeGVkLWJvdHRvbScsICBcbiAgICBcbiAgICAvLyB0cmFuc2l0aW9uRW5kIHNpbmNlIDIuMC40XG4gICAgc3VwcG9ydFRyYW5zaXRpb25zID0gV2Via2l0K1RyYW5zaXRpb24gaW4gSFRNTFtzdHlsZV0gfHwgVHJhbnNpdGlvblt0b0xvd2VyQ2FzZV0oKSBpbiBIVE1MW3N0eWxlXSxcbiAgICB0cmFuc2l0aW9uRW5kRXZlbnQgPSBXZWJraXQrVHJhbnNpdGlvbiBpbiBIVE1MW3N0eWxlXSA/IFdlYmtpdFt0b0xvd2VyQ2FzZV0oKStUcmFuc2l0aW9uKydFbmQnIDogVHJhbnNpdGlvblt0b0xvd2VyQ2FzZV0oKSsnZW5kJyxcbiAgICB0cmFuc2l0aW9uRHVyYXRpb24gPSBXZWJraXQrRHVyYXRpb24gaW4gSFRNTFtzdHlsZV0gPyBXZWJraXRbdG9Mb3dlckNhc2VdKCkrVHJhbnNpdGlvbitEdXJhdGlvbiA6IFRyYW5zaXRpb25bdG9Mb3dlckNhc2VdKCkrRHVyYXRpb24sXG4gIFxuICAgIC8vIHNldCBuZXcgZm9jdXMgZWxlbWVudCBzaW5jZSAyLjAuM1xuICAgIHNldEZvY3VzID0gZnVuY3Rpb24oZWxlbWVudCl7XG4gICAgICBlbGVtZW50LmZvY3VzID8gZWxlbWVudC5mb2N1cygpIDogZWxlbWVudC5zZXRBY3RpdmUoKTtcbiAgICB9LFxuICBcbiAgICAvLyBjbGFzcyBtYW5pcHVsYXRpb24sIHNpbmNlIDIuMC4wIHJlcXVpcmVzIHBvbHlmaWxsLmpzXG4gICAgYWRkQ2xhc3MgPSBmdW5jdGlvbihlbGVtZW50LGNsYXNzTkFNRSkge1xuICAgICAgZWxlbWVudC5jbGFzc0xpc3QuYWRkKGNsYXNzTkFNRSk7XG4gICAgfSxcbiAgICByZW1vdmVDbGFzcyA9IGZ1bmN0aW9uKGVsZW1lbnQsY2xhc3NOQU1FKSB7XG4gICAgICBlbGVtZW50LmNsYXNzTGlzdC5yZW1vdmUoY2xhc3NOQU1FKTtcbiAgICB9LFxuICAgIGhhc0NsYXNzID0gZnVuY3Rpb24oZWxlbWVudCxjbGFzc05BTUUpeyAvLyBzaW5jZSAyLjAuMFxuICAgICAgcmV0dXJuIGVsZW1lbnQuY2xhc3NMaXN0W2NvbnRhaW5zXShjbGFzc05BTUUpO1xuICAgIH0sXG4gIFxuICAgIC8vIHNlbGVjdGlvbiBtZXRob2RzXG4gICAgbm9kZUxpc3RUb0FycmF5ID0gZnVuY3Rpb24obm9kZUxpc3Qpe1xuICAgICAgdmFyIGNoaWxkSXRlbXMgPSBbXTsgZm9yICh2YXIgaSA9IDAsIG5sbCA9IG5vZGVMaXN0W2xlbmd0aF07IGk8bmxsOyBpKyspIHsgY2hpbGRJdGVtc1twdXNoXSggbm9kZUxpc3RbaV0gKSB9XG4gICAgICByZXR1cm4gY2hpbGRJdGVtcztcbiAgICB9LFxuICAgIGdldEVsZW1lbnRzQnlDbGFzc05hbWUgPSBmdW5jdGlvbihlbGVtZW50LGNsYXNzTkFNRSkgeyAvLyBnZXRFbGVtZW50c0J5Q2xhc3NOYW1lIElFOCtcbiAgICAgIHZhciBzZWxlY3Rpb25NZXRob2QgPSBpc0lFOCA/IHF1ZXJ5U2VsZWN0b3JBbGwgOiBnZXRFbGVtZW50c0J5Q0xBU1NOQU1FOyAgICAgIFxuICAgICAgcmV0dXJuIG5vZGVMaXN0VG9BcnJheShlbGVtZW50W3NlbGVjdGlvbk1ldGhvZF0oIGlzSUU4ID8gJy4nICsgY2xhc3NOQU1FLnJlcGxhY2UoL1xccyg/PVthLXpdKS9nLCcuJykgOiBjbGFzc05BTUUgKSk7XG4gICAgfSxcbiAgICBxdWVyeUVsZW1lbnQgPSBmdW5jdGlvbiAoc2VsZWN0b3IsIHBhcmVudCkge1xuICAgICAgdmFyIGxvb2tVcCA9IHBhcmVudCA/IHBhcmVudCA6IERPQztcbiAgICAgIHJldHVybiB0eXBlb2Ygc2VsZWN0b3IgPT09ICdvYmplY3QnID8gc2VsZWN0b3IgOiBsb29rVXAucXVlcnlTZWxlY3RvcihzZWxlY3Rvcik7XG4gICAgfSxcbiAgICBnZXRDbG9zZXN0ID0gZnVuY3Rpb24gKGVsZW1lbnQsIHNlbGVjdG9yKSB7IC8vZWxlbWVudCBpcyB0aGUgZWxlbWVudCBhbmQgc2VsZWN0b3IgaXMgZm9yIHRoZSBjbG9zZXN0IHBhcmVudCBlbGVtZW50IHRvIGZpbmRcbiAgICAgIC8vIHNvdXJjZSBodHRwOi8vZ29tYWtldGhpbmdzLmNvbS9jbGltYmluZy11cC1hbmQtZG93bi10aGUtZG9tLXRyZWUtd2l0aC12YW5pbGxhLWphdmFzY3JpcHQvXG4gICAgICB2YXIgZmlyc3RDaGFyID0gc2VsZWN0b3IuY2hhckF0KDApLCBzZWxlY3RvclN1YnN0cmluZyA9IHNlbGVjdG9yLnN1YnN0cigxKTtcbiAgICAgIGlmICggZmlyc3RDaGFyID09PSAnLicgKSB7Ly8gSWYgc2VsZWN0b3IgaXMgYSBjbGFzc1xuICAgICAgICBmb3IgKCA7IGVsZW1lbnQgJiYgZWxlbWVudCAhPT0gRE9DOyBlbGVtZW50ID0gZWxlbWVudFtwYXJlbnROb2RlXSApIHsgLy8gR2V0IGNsb3Nlc3QgbWF0Y2hcbiAgICAgICAgICBpZiAoIHF1ZXJ5RWxlbWVudChzZWxlY3RvcixlbGVtZW50W3BhcmVudE5vZGVdKSAhPT0gbnVsbCAmJiBoYXNDbGFzcyhlbGVtZW50LHNlbGVjdG9yU3Vic3RyaW5nKSApIHsgcmV0dXJuIGVsZW1lbnQ7IH1cbiAgICAgICAgfVxuICAgICAgfSBlbHNlIGlmICggZmlyc3RDaGFyID09PSAnIycgKSB7IC8vIElmIHNlbGVjdG9yIGlzIGFuIElEXG4gICAgICAgIGZvciAoIDsgZWxlbWVudCAmJiBlbGVtZW50ICE9PSBET0M7IGVsZW1lbnQgPSBlbGVtZW50W3BhcmVudE5vZGVdICkgeyAvLyBHZXQgY2xvc2VzdCBtYXRjaFxuICAgICAgICAgIGlmICggZWxlbWVudC5pZCA9PT0gc2VsZWN0b3JTdWJzdHJpbmcgKSB7IHJldHVybiBlbGVtZW50OyB9XG4gICAgICAgIH1cbiAgICAgIH1cbiAgICAgIHJldHVybiBmYWxzZTtcbiAgICB9LFxuICBcbiAgICAvLyBldmVudCBhdHRhY2ggalF1ZXJ5IHN0eWxlIC8gdHJpZ2dlciAgc2luY2UgMS4yLjBcbiAgICBvbiA9IGZ1bmN0aW9uIChlbGVtZW50LCBldmVudCwgaGFuZGxlciwgb3B0aW9ucykge1xuICAgICAgb3B0aW9ucyA9IG9wdGlvbnMgfHwgZmFsc2U7XG4gICAgICBlbGVtZW50LmFkZEV2ZW50TGlzdGVuZXIoZXZlbnQsIGhhbmRsZXIsIG9wdGlvbnMpO1xuICAgIH0sXG4gICAgb2ZmID0gZnVuY3Rpb24oZWxlbWVudCwgZXZlbnQsIGhhbmRsZXIsIG9wdGlvbnMpIHtcbiAgICAgIG9wdGlvbnMgPSBvcHRpb25zIHx8IGZhbHNlO1xuICAgICAgZWxlbWVudC5yZW1vdmVFdmVudExpc3RlbmVyKGV2ZW50LCBoYW5kbGVyLCBvcHRpb25zKTtcbiAgICB9LFxuICAgIG9uZSA9IGZ1bmN0aW9uIChlbGVtZW50LCBldmVudCwgaGFuZGxlciwgb3B0aW9ucykgeyAvLyBvbmUgc2luY2UgMi4wLjRcbiAgICAgIG9uKGVsZW1lbnQsIGV2ZW50LCBmdW5jdGlvbiBoYW5kbGVyV3JhcHBlcihlKXtcbiAgICAgICAgaGFuZGxlcihlKTtcbiAgICAgICAgb2ZmKGVsZW1lbnQsIGV2ZW50LCBoYW5kbGVyV3JhcHBlciwgb3B0aW9ucyk7XG4gICAgICB9LCBvcHRpb25zKTtcbiAgICB9LFxuICAgIC8vIGRldGVybWluZSBzdXBwb3J0IGZvciBwYXNzaXZlIGV2ZW50c1xuICAgIHN1cHBvcnRQYXNzaXZlID0gKGZ1bmN0aW9uKCl7XG4gICAgICAvLyBUZXN0IHZpYSBhIGdldHRlciBpbiB0aGUgb3B0aW9ucyBvYmplY3QgdG8gc2VlIGlmIHRoZSBwYXNzaXZlIHByb3BlcnR5IGlzIGFjY2Vzc2VkXG4gICAgICB2YXIgcmVzdWx0ID0gZmFsc2U7XG4gICAgICB0cnkge1xuICAgICAgICB2YXIgb3B0cyA9IE9iamVjdC5kZWZpbmVQcm9wZXJ0eSh7fSwgJ3Bhc3NpdmUnLCB7XG4gICAgICAgICAgZ2V0OiBmdW5jdGlvbigpIHtcbiAgICAgICAgICAgIHJlc3VsdCA9IHRydWU7XG4gICAgICAgICAgfVxuICAgICAgICB9KTtcbiAgICAgICAgb25lKGdsb2JhbE9iamVjdCwgJ3Rlc3RQYXNzaXZlJywgbnVsbCwgb3B0cyk7XG4gICAgICB9IGNhdGNoIChlKSB7fVxuICBcbiAgICAgIHJldHVybiByZXN1bHQ7XG4gICAgfSgpKSxcbiAgICAvLyBldmVudCBvcHRpb25zXG4gICAgLy8gaHR0cHM6Ly9naXRodWIuY29tL1dJQ0cvRXZlbnRMaXN0ZW5lck9wdGlvbnMvYmxvYi9naC1wYWdlcy9leHBsYWluZXIubWQjZmVhdHVyZS1kZXRlY3Rpb25cbiAgICBwYXNzaXZlSGFuZGxlciA9IHN1cHBvcnRQYXNzaXZlID8geyBwYXNzaXZlOiB0cnVlIH0gOiBmYWxzZSxcbiAgICAvLyB0cmFuc2l0aW9uc1xuICAgIGdldFRyYW5zaXRpb25EdXJhdGlvbkZyb21FbGVtZW50ID0gZnVuY3Rpb24oZWxlbWVudCkge1xuICAgICAgdmFyIGR1cmF0aW9uID0gc3VwcG9ydFRyYW5zaXRpb25zID8gZ2xvYmFsT2JqZWN0W2dldENvbXB1dGVkU3R5bGVdKGVsZW1lbnQpW3RyYW5zaXRpb25EdXJhdGlvbl0gOiAwO1xuICAgICAgZHVyYXRpb24gPSBwYXJzZUZsb2F0KGR1cmF0aW9uKTtcbiAgICAgIGR1cmF0aW9uID0gdHlwZW9mIGR1cmF0aW9uID09PSAnbnVtYmVyJyAmJiAhaXNOYU4oZHVyYXRpb24pID8gZHVyYXRpb24gKiAxMDAwIDogMDtcbiAgICAgIHJldHVybiBkdXJhdGlvbjsgLy8gd2UgdGFrZSBhIHNob3J0IG9mZnNldCB0byBtYWtlIHN1cmUgd2UgZmlyZSBvbiB0aGUgbmV4dCBmcmFtZSBhZnRlciBhbmltYXRpb25cbiAgICB9LFxuICAgIGVtdWxhdGVUcmFuc2l0aW9uRW5kID0gZnVuY3Rpb24oZWxlbWVudCxoYW5kbGVyKXsgLy8gZW11bGF0ZVRyYW5zaXRpb25FbmQgc2luY2UgMi4wLjRcbiAgICAgIHZhciBjYWxsZWQgPSAwLCBkdXJhdGlvbiA9IGdldFRyYW5zaXRpb25EdXJhdGlvbkZyb21FbGVtZW50KGVsZW1lbnQpO1xuICAgICAgZHVyYXRpb24gPyBvbmUoZWxlbWVudCwgdHJhbnNpdGlvbkVuZEV2ZW50LCBmdW5jdGlvbihlKXsgIWNhbGxlZCAmJiBoYW5kbGVyKGUpLCBjYWxsZWQgPSAxOyB9KVxuICAgICAgICAgICAgICAgOiBzZXRUaW1lb3V0KGZ1bmN0aW9uKCkgeyAhY2FsbGVkICYmIGhhbmRsZXIoKSwgY2FsbGVkID0gMTsgfSwgMTcpO1xuICAgIH0sXG4gICAgYm9vdHN0cmFwQ3VzdG9tRXZlbnQgPSBmdW5jdGlvbiAoZXZlbnROYW1lLCBjb21wb25lbnROYW1lLCByZWxhdGVkKSB7XG4gICAgICB2YXIgT3JpZ2luYWxDdXN0b21FdmVudCA9IG5ldyBDdXN0b21FdmVudCggZXZlbnROYW1lICsgJy5icy4nICsgY29tcG9uZW50TmFtZSk7XG4gICAgICBPcmlnaW5hbEN1c3RvbUV2ZW50LnJlbGF0ZWRUYXJnZXQgPSByZWxhdGVkO1xuICAgICAgdGhpcy5kaXNwYXRjaEV2ZW50KE9yaWdpbmFsQ3VzdG9tRXZlbnQpO1xuICAgIH0sXG4gIFxuICAgIC8vIHRvb2x0aXAgLyBwb3BvdmVyIHN0dWZmXG4gICAgZ2V0U2Nyb2xsID0gZnVuY3Rpb24oKSB7IC8vIGFsc28gQWZmaXggYW5kIFNjcm9sbFNweSB1c2VzIGl0XG4gICAgICByZXR1cm4ge1xuICAgICAgICB5IDogZ2xvYmFsT2JqZWN0LnBhZ2VZT2Zmc2V0IHx8IEhUTUxbc2Nyb2xsVG9wXSxcbiAgICAgICAgeCA6IGdsb2JhbE9iamVjdC5wYWdlWE9mZnNldCB8fCBIVE1MW3Njcm9sbExlZnRdXG4gICAgICB9XG4gICAgfSxcbiAgICBzdHlsZVRpcCA9IGZ1bmN0aW9uKGxpbmssZWxlbWVudCxwb3NpdGlvbixwYXJlbnQpIHsgLy8gYm90aCBwb3BvdmVycyBhbmQgdG9vbHRpcHMgKHRhcmdldCx0b29sdGlwL3BvcG92ZXIscGxhY2VtZW50LGVsZW1lbnRUb0FwcGVuZFRvKVxuICAgICAgdmFyIGVsZW1lbnREaW1lbnNpb25zID0geyB3IDogZWxlbWVudFtvZmZzZXRXaWR0aF0sIGg6IGVsZW1lbnRbb2Zmc2V0SGVpZ2h0XSB9LFxuICAgICAgICAgIHdpbmRvd1dpZHRoID0gKEhUTUxbY2xpZW50V2lkdGhdIHx8IERPQ1tib2R5XVtjbGllbnRXaWR0aF0pLFxuICAgICAgICAgIHdpbmRvd0hlaWdodCA9IChIVE1MW2NsaWVudEhlaWdodF0gfHwgRE9DW2JvZHldW2NsaWVudEhlaWdodF0pLFxuICAgICAgICAgIHJlY3QgPSBsaW5rW2dldEJvdW5kaW5nQ2xpZW50UmVjdF0oKSwgXG4gICAgICAgICAgc2Nyb2xsID0gcGFyZW50ID09PSBET0NbYm9keV0gPyBnZXRTY3JvbGwoKSA6IHsgeDogcGFyZW50W29mZnNldExlZnRdICsgcGFyZW50W3Njcm9sbExlZnRdLCB5OiBwYXJlbnRbb2Zmc2V0VG9wXSArIHBhcmVudFtzY3JvbGxUb3BdIH0sXG4gICAgICAgICAgbGlua0RpbWVuc2lvbnMgPSB7IHc6IHJlY3RbcmlnaHRdIC0gcmVjdFtsZWZ0XSwgaDogcmVjdFtib3R0b21dIC0gcmVjdFt0b3BdIH0sXG4gICAgICAgICAgYXJyb3cgPSBxdWVyeUVsZW1lbnQoJ1tjbGFzcyo9XCJhcnJvd1wiXScsZWxlbWVudCksXG4gICAgICAgICAgdG9wUG9zaXRpb24sIGxlZnRQb3NpdGlvbiwgYXJyb3dUb3AsIGFycm93TGVmdCxcbiAgXG4gICAgICAgICAgaGFsZlRvcEV4Y2VlZCA9IHJlY3RbdG9wXSArIGxpbmtEaW1lbnNpb25zLmgvMiAtIGVsZW1lbnREaW1lbnNpb25zLmgvMiA8IDAsXG4gICAgICAgICAgaGFsZkxlZnRFeGNlZWQgPSByZWN0W2xlZnRdICsgbGlua0RpbWVuc2lvbnMudy8yIC0gZWxlbWVudERpbWVuc2lvbnMudy8yIDwgMCxcbiAgICAgICAgICBoYWxmUmlnaHRFeGNlZWQgPSByZWN0W2xlZnRdICsgZWxlbWVudERpbWVuc2lvbnMudy8yICsgbGlua0RpbWVuc2lvbnMudy8yID49IHdpbmRvd1dpZHRoLFxuICAgICAgICAgIGhhbGZCb3R0b21FeGNlZWQgPSByZWN0W3RvcF0gKyBlbGVtZW50RGltZW5zaW9ucy5oLzIgKyBsaW5rRGltZW5zaW9ucy5oLzIgPj0gd2luZG93SGVpZ2h0LFxuICAgICAgICAgIHRvcEV4Y2VlZCA9IHJlY3RbdG9wXSAtIGVsZW1lbnREaW1lbnNpb25zLmggPCAwLFxuICAgICAgICAgIGxlZnRFeGNlZWQgPSByZWN0W2xlZnRdIC0gZWxlbWVudERpbWVuc2lvbnMudyA8IDAsXG4gICAgICAgICAgYm90dG9tRXhjZWVkID0gcmVjdFt0b3BdICsgZWxlbWVudERpbWVuc2lvbnMuaCArIGxpbmtEaW1lbnNpb25zLmggPj0gd2luZG93SGVpZ2h0LFxuICAgICAgICAgIHJpZ2h0RXhjZWVkID0gcmVjdFtsZWZ0XSArIGVsZW1lbnREaW1lbnNpb25zLncgKyBsaW5rRGltZW5zaW9ucy53ID49IHdpbmRvd1dpZHRoO1xuICBcbiAgICAgIC8vIHJlY29tcHV0ZSBwb3NpdGlvblxuICAgICAgcG9zaXRpb24gPSAocG9zaXRpb24gPT09IGxlZnQgfHwgcG9zaXRpb24gPT09IHJpZ2h0KSAmJiBsZWZ0RXhjZWVkICYmIHJpZ2h0RXhjZWVkID8gdG9wIDogcG9zaXRpb247IC8vIGZpcnN0LCB3aGVuIGJvdGggbGVmdCBhbmQgcmlnaHQgbGltaXRzIGFyZSBleGNlZWRlZCwgd2UgZmFsbCBiYWNrIHRvIHRvcHxib3R0b21cbiAgICAgIHBvc2l0aW9uID0gcG9zaXRpb24gPT09IHRvcCAmJiB0b3BFeGNlZWQgPyBib3R0b20gOiBwb3NpdGlvbjtcbiAgICAgIHBvc2l0aW9uID0gcG9zaXRpb24gPT09IGJvdHRvbSAmJiBib3R0b21FeGNlZWQgPyB0b3AgOiBwb3NpdGlvbjtcbiAgICAgIHBvc2l0aW9uID0gcG9zaXRpb24gPT09IGxlZnQgJiYgbGVmdEV4Y2VlZCA/IHJpZ2h0IDogcG9zaXRpb247XG4gICAgICBwb3NpdGlvbiA9IHBvc2l0aW9uID09PSByaWdodCAmJiByaWdodEV4Y2VlZCA/IGxlZnQgOiBwb3NpdGlvbjtcbiAgICAgIFxuICAgICAgLy8gYXBwbHkgc3R5bGluZyB0byB0b29sdGlwIG9yIHBvcG92ZXJcbiAgICAgIGlmICggcG9zaXRpb24gPT09IGxlZnQgfHwgcG9zaXRpb24gPT09IHJpZ2h0ICkgeyAvLyBzZWNvbmRhcnl8c2lkZSBwb3NpdGlvbnNcbiAgICAgICAgaWYgKCBwb3NpdGlvbiA9PT0gbGVmdCApIHsgLy8gTEVGVFxuICAgICAgICAgIGxlZnRQb3NpdGlvbiA9IHJlY3RbbGVmdF0gKyBzY3JvbGwueCAtIGVsZW1lbnREaW1lbnNpb25zLnc7XG4gICAgICAgIH0gZWxzZSB7IC8vIFJJR0hUXG4gICAgICAgICAgbGVmdFBvc2l0aW9uID0gcmVjdFtsZWZ0XSArIHNjcm9sbC54ICsgbGlua0RpbWVuc2lvbnMudztcbiAgICAgICAgfVxuICBcbiAgICAgICAgLy8gYWRqdXN0IHRvcCBhbmQgYXJyb3dcbiAgICAgICAgaWYgKGhhbGZUb3BFeGNlZWQpIHtcbiAgICAgICAgICB0b3BQb3NpdGlvbiA9IHJlY3RbdG9wXSArIHNjcm9sbC55O1xuICAgICAgICAgIGFycm93VG9wID0gbGlua0RpbWVuc2lvbnMuaC8yO1xuICAgICAgICB9IGVsc2UgaWYgKGhhbGZCb3R0b21FeGNlZWQpIHtcbiAgICAgICAgICB0b3BQb3NpdGlvbiA9IHJlY3RbdG9wXSArIHNjcm9sbC55IC0gZWxlbWVudERpbWVuc2lvbnMuaCArIGxpbmtEaW1lbnNpb25zLmg7XG4gICAgICAgICAgYXJyb3dUb3AgPSBlbGVtZW50RGltZW5zaW9ucy5oIC0gbGlua0RpbWVuc2lvbnMuaC8yO1xuICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgIHRvcFBvc2l0aW9uID0gcmVjdFt0b3BdICsgc2Nyb2xsLnkgLSBlbGVtZW50RGltZW5zaW9ucy5oLzIgKyBsaW5rRGltZW5zaW9ucy5oLzI7XG4gICAgICAgIH1cbiAgICAgIH0gZWxzZSBpZiAoIHBvc2l0aW9uID09PSB0b3AgfHwgcG9zaXRpb24gPT09IGJvdHRvbSApIHsgLy8gcHJpbWFyeXx2ZXJ0aWNhbCBwb3NpdGlvbnNcbiAgICAgICAgaWYgKCBwb3NpdGlvbiA9PT0gdG9wKSB7IC8vIFRPUFxuICAgICAgICAgIHRvcFBvc2l0aW9uID0gIHJlY3RbdG9wXSArIHNjcm9sbC55IC0gZWxlbWVudERpbWVuc2lvbnMuaDtcbiAgICAgICAgfSBlbHNlIHsgLy8gQk9UVE9NXG4gICAgICAgICAgdG9wUG9zaXRpb24gPSByZWN0W3RvcF0gKyBzY3JvbGwueSArIGxpbmtEaW1lbnNpb25zLmg7XG4gICAgICAgIH1cbiAgICAgICAgLy8gYWRqdXN0IGxlZnQgfCByaWdodCBhbmQgYWxzbyB0aGUgYXJyb3dcbiAgICAgICAgaWYgKGhhbGZMZWZ0RXhjZWVkKSB7XG4gICAgICAgICAgbGVmdFBvc2l0aW9uID0gMDtcbiAgICAgICAgICBhcnJvd0xlZnQgPSByZWN0W2xlZnRdICsgbGlua0RpbWVuc2lvbnMudy8yO1xuICAgICAgICB9IGVsc2UgaWYgKGhhbGZSaWdodEV4Y2VlZCkge1xuICAgICAgICAgIGxlZnRQb3NpdGlvbiA9IHdpbmRvd1dpZHRoIC0gZWxlbWVudERpbWVuc2lvbnMudyoxLjAxO1xuICAgICAgICAgIGFycm93TGVmdCA9IGVsZW1lbnREaW1lbnNpb25zLncgLSAoIHdpbmRvd1dpZHRoIC0gcmVjdFtsZWZ0XSApICsgbGlua0RpbWVuc2lvbnMudy8yO1xuICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgIGxlZnRQb3NpdGlvbiA9IHJlY3RbbGVmdF0gKyBzY3JvbGwueCAtIGVsZW1lbnREaW1lbnNpb25zLncvMiArIGxpbmtEaW1lbnNpb25zLncvMjtcbiAgICAgICAgfVxuICAgICAgfVxuICBcbiAgICAgIC8vIGFwcGx5IHN0eWxlIHRvIHRvb2x0aXAvcG9wb3ZlciBhbmQgaXQncyBhcnJvd1xuICAgICAgZWxlbWVudFtzdHlsZV1bdG9wXSA9IHRvcFBvc2l0aW9uICsgJ3B4JztcbiAgICAgIGVsZW1lbnRbc3R5bGVdW2xlZnRdID0gbGVmdFBvc2l0aW9uICsgJ3B4JztcbiAgXG4gICAgICBhcnJvd1RvcCAmJiAoYXJyb3dbc3R5bGVdW3RvcF0gPSBhcnJvd1RvcCArICdweCcpO1xuICAgICAgYXJyb3dMZWZ0ICYmIChhcnJvd1tzdHlsZV1bbGVmdF0gPSBhcnJvd0xlZnQgKyAncHgnKTtcbiAgXG4gICAgICBlbGVtZW50LmNsYXNzTmFtZVtpbmRleE9mXShwb3NpdGlvbikgPT09IC0xICYmIChlbGVtZW50LmNsYXNzTmFtZSA9IGVsZW1lbnQuY2xhc3NOYW1lLnJlcGxhY2UodGlwUG9zaXRpb25zLHBvc2l0aW9uKSk7XG4gICAgfTtcbiAgXG4gIEJTTi52ZXJzaW9uID0gJzIuMC4yNyc7XG4gIFxuICAvKiBOYXRpdmUgSmF2YXNjcmlwdCBmb3IgQm9vdHN0cmFwIDMgfCBBZmZpeFxuICAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tKi9cbiAgXG4gIC8vIEFGRklYIERFRklOSVRJT05cbiAgdmFyIEFmZml4ID0gZnVuY3Rpb24oZWxlbWVudCwgb3B0aW9ucykge1xuICBcbiAgICAvLyBpbml0aWFsaXphdGlvbiBlbGVtZW50XG4gICAgZWxlbWVudCA9IHF1ZXJ5RWxlbWVudChlbGVtZW50KTtcbiAgXG4gICAgLy8gc2V0IG9wdGlvbnNcbiAgICBvcHRpb25zID0gb3B0aW9ucyB8fCB7fTtcbiAgXG4gICAgLy8gcmVhZCBEQVRBIEFQSVxuICAgIHZhciB0YXJnZXREYXRhICAgICAgICA9IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhVGFyZ2V0KSxcbiAgICAgICAgb2Zmc2V0VG9wRGF0YSAgICAgPSBlbGVtZW50W2dldEF0dHJpYnV0ZV0oZGF0YU9mZnNldFRvcCksXG4gICAgICAgIG9mZnNldEJvdHRvbURhdGEgID0gZWxlbWVudFtnZXRBdHRyaWJ1dGVdKGRhdGFPZmZzZXRCb3R0b20pLFxuICAgICAgICBcbiAgICAgICAgLy8gY29tcG9uZW50IHNwZWNpZmljIHN0cmluZ3NcbiAgICAgICAgYWZmaXggPSAnYWZmaXgnLCBhZmZpeGVkID0gJ2FmZml4ZWQnLCBmbiA9ICdmdW5jdGlvbicsIHVwZGF0ZSA9ICd1cGRhdGUnLFxuICAgICAgICBhZmZpeFRvcCA9ICdhZmZpeC10b3AnLCBhZmZpeGVkVG9wID0gJ2FmZml4ZWQtdG9wJyxcbiAgICAgICAgYWZmaXhCb3R0b20gPSAnYWZmaXgtYm90dG9tJywgYWZmaXhlZEJvdHRvbSA9ICdhZmZpeGVkLWJvdHRvbSc7XG4gIFxuICAgIHRoaXNbdGFyZ2V0XSA9IG9wdGlvbnNbdGFyZ2V0XSA/IHF1ZXJ5RWxlbWVudChvcHRpb25zW3RhcmdldF0pIDogcXVlcnlFbGVtZW50KHRhcmdldERhdGEpIHx8IG51bGw7IC8vIHRhcmdldCBpcyBhbiBvYmplY3RcbiAgICB0aGlzW29mZnNldFRvcF0gPSBvcHRpb25zW29mZnNldFRvcF0gPyBvcHRpb25zW29mZnNldFRvcF0gOiBwYXJzZUludChvZmZzZXRUb3BEYXRhKSB8fCAwOyAvLyBvZmZzZXQgb3B0aW9uIGlzIGFuIGludGVnZXIgbnVtYmVyIG9yIGZ1bmN0aW9uIHRvIGRldGVybWluZSB0aGF0IG51bWJlclxuICAgIHRoaXNbb2Zmc2V0Qm90dG9tXSA9IG9wdGlvbnNbb2Zmc2V0Qm90dG9tXSA/IG9wdGlvbnNbb2Zmc2V0Qm90dG9tXTogcGFyc2VJbnQob2Zmc2V0Qm90dG9tRGF0YSkgfHwgMDtcbiAgXG4gICAgaWYgKCAhdGhpc1t0YXJnZXRdICYmICEoIHRoaXNbb2Zmc2V0VG9wXSB8fCB0aGlzW29mZnNldEJvdHRvbV0gKSApIHsgcmV0dXJuOyB9IC8vIGludmFsaWRhdGVcbiAgXG4gICAgLy8gaW50ZXJuYWwgYmluZFxuICAgIHZhciBzZWxmID0gdGhpcyxcbiAgXG4gICAgICAvLyBjb25zdGFudHNcbiAgICAgIHBpbk9mZnNldFRvcCwgcGluT2Zmc2V0Qm90dG9tLCBtYXhTY3JvbGwsIHNjcm9sbFksIHBpbm5lZFRvcCwgcGlubmVkQm90dG9tLFxuICAgICAgYWZmaXhlZFRvVG9wID0gZmFsc2UsIGFmZml4ZWRUb0JvdHRvbSA9IGZhbHNlLFxuICAgICAgXG4gICAgICAvLyBwcml2YXRlIG1ldGhvZHMgXG4gICAgICBnZXRNYXhTY3JvbGwgPSBmdW5jdGlvbigpe1xuICAgICAgICByZXR1cm4gTWF0aC5tYXgoIERPQ1tib2R5XVtzY3JvbGxIZWlnaHRdLCBET0NbYm9keV1bb2Zmc2V0SGVpZ2h0XSwgSFRNTFtjbGllbnRIZWlnaHRdLCBIVE1MW3Njcm9sbEhlaWdodF0sIEhUTUxbb2Zmc2V0SGVpZ2h0XSApO1xuICAgICAgfSxcbiAgICAgIGdldE9mZnNldFRvcCA9IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgaWYgKCBzZWxmW3RhcmdldF0gIT09IG51bGwgKSB7XG4gICAgICAgICAgcmV0dXJuIHNlbGZbdGFyZ2V0XVtnZXRCb3VuZGluZ0NsaWVudFJlY3RdKClbdG9wXSArIHNjcm9sbFk7XG4gICAgICAgIH0gZWxzZSBpZiAoIHNlbGZbb2Zmc2V0VG9wXSApIHtcbiAgICAgICAgICByZXR1cm4gcGFyc2VJbnQodHlwZW9mIHNlbGZbb2Zmc2V0VG9wXSA9PT0gZm4gPyBzZWxmW29mZnNldFRvcF0oKSA6IHNlbGZbb2Zmc2V0VG9wXSB8fCAwKTtcbiAgICAgICAgfVxuICAgICAgfSxcbiAgICAgIGdldE9mZnNldEJvdHRvbSA9IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgaWYgKCBzZWxmW29mZnNldEJvdHRvbV0gKSB7XG4gICAgICAgICAgcmV0dXJuIG1heFNjcm9sbCAtIGVsZW1lbnRbb2Zmc2V0SGVpZ2h0XSAtIHBhcnNlSW50KCB0eXBlb2Ygc2VsZltvZmZzZXRCb3R0b21dID09PSBmbiA/IHNlbGZbb2Zmc2V0Qm90dG9tXSgpIDogc2VsZltvZmZzZXRCb3R0b21dIHx8IDAgKTtcbiAgICAgICAgfVxuICAgICAgfSxcbiAgICAgIGNoZWNrUG9zaXRpb24gPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgIG1heFNjcm9sbCA9IGdldE1heFNjcm9sbCgpO1xuICAgICAgICBzY3JvbGxZID0gcGFyc2VJbnQoZ2V0U2Nyb2xsKCkueSwwKTtcbiAgICAgICAgcGluT2Zmc2V0VG9wID0gZ2V0T2Zmc2V0VG9wKCk7XG4gICAgICAgIHBpbk9mZnNldEJvdHRvbSA9IGdldE9mZnNldEJvdHRvbSgpOyBcbiAgICAgICAgcGlubmVkVG9wID0gKCBwYXJzZUludChwaW5PZmZzZXRUb3ApIC0gc2Nyb2xsWSA8IDApICYmIChzY3JvbGxZID4gcGFyc2VJbnQocGluT2Zmc2V0VG9wKSApO1xuICAgICAgICBwaW5uZWRCb3R0b20gPSAoIHBhcnNlSW50KHBpbk9mZnNldEJvdHRvbSkgLSBzY3JvbGxZIDwgMCkgJiYgKHNjcm9sbFkgPiBwYXJzZUludChwaW5PZmZzZXRCb3R0b20pICk7XG4gICAgICB9LFxuICAgICAgcGluVG9wID0gZnVuY3Rpb24gKCkge1xuICAgICAgICBpZiAoICFhZmZpeGVkVG9Ub3AgJiYgIWhhc0NsYXNzKGVsZW1lbnQsYWZmaXgpICkgeyAvLyBvbiBsb2FkaW5nIGEgcGFnZSBoYWxmd2F5IHNjcm9sbGVkIHRoZXNlIGV2ZW50cyBkb24ndCB0cmlnZ2VyIGluIENocm9tZVxuICAgICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoZWxlbWVudCwgYWZmaXgsIGFmZml4KTtcbiAgICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKGVsZW1lbnQsIGFmZml4VG9wLCBhZmZpeCk7XG4gICAgICAgICAgYWRkQ2xhc3MoZWxlbWVudCxhZmZpeCk7XG4gICAgICAgICAgYWZmaXhlZFRvVG9wID0gdHJ1ZTtcbiAgICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKGVsZW1lbnQsIGFmZml4ZWQsIGFmZml4KTtcbiAgICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKGVsZW1lbnQsIGFmZml4ZWRUb3AsIGFmZml4KTtcbiAgICAgICAgfVxuICAgICAgfSxcbiAgICAgIHVuUGluVG9wID0gZnVuY3Rpb24gKCkge1xuICAgICAgICBpZiAoIGFmZml4ZWRUb1RvcCAmJiBoYXNDbGFzcyhlbGVtZW50LGFmZml4KSApIHtcbiAgICAgICAgICByZW1vdmVDbGFzcyhlbGVtZW50LGFmZml4KTtcbiAgICAgICAgICBhZmZpeGVkVG9Ub3AgPSBmYWxzZTtcbiAgICAgICAgfVxuICAgICAgfSxcbiAgICAgIHBpbkJvdHRvbSA9IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgaWYgKCAhYWZmaXhlZFRvQm90dG9tICYmICFoYXNDbGFzcyhlbGVtZW50LCBhZmZpeEJvdHRvbSkgKSB7XG4gICAgICAgICAgYm9vdHN0cmFwQ3VzdG9tRXZlbnQuY2FsbChlbGVtZW50LCBhZmZpeCwgYWZmaXgpO1xuICAgICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoZWxlbWVudCwgYWZmaXhCb3R0b20sIGFmZml4KTtcbiAgICAgICAgICBhZGRDbGFzcyhlbGVtZW50LGFmZml4Qm90dG9tKTtcbiAgICAgICAgICBhZmZpeGVkVG9Cb3R0b20gPSB0cnVlO1xuICAgICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoZWxlbWVudCwgYWZmaXhlZCwgYWZmaXgpO1xuICAgICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoZWxlbWVudCwgYWZmaXhlZEJvdHRvbSwgYWZmaXgpO1xuICAgICAgICB9XG4gICAgICB9LFxuICAgICAgdW5QaW5Cb3R0b20gPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgIGlmICggYWZmaXhlZFRvQm90dG9tICYmIGhhc0NsYXNzKGVsZW1lbnQsYWZmaXhCb3R0b20pICkge1xuICAgICAgICAgIHJlbW92ZUNsYXNzKGVsZW1lbnQsYWZmaXhCb3R0b20pO1xuICAgICAgICAgIGFmZml4ZWRUb0JvdHRvbSA9IGZhbHNlO1xuICAgICAgICB9XG4gICAgICB9LFxuICAgICAgdXBkYXRlUGluID0gZnVuY3Rpb24gKCkge1xuICAgICAgICBpZiAoIHBpbm5lZEJvdHRvbSApIHtcbiAgICAgICAgICBpZiAoIHBpbm5lZFRvcCApIHsgdW5QaW5Ub3AoKTsgfVxuICAgICAgICAgIHBpbkJvdHRvbSgpOyBcbiAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICB1blBpbkJvdHRvbSgpO1xuICAgICAgICAgIGlmICggcGlubmVkVG9wICkgeyBwaW5Ub3AoKTsgfSBcbiAgICAgICAgICBlbHNlIHsgdW5QaW5Ub3AoKTsgfVxuICAgICAgICB9XG4gICAgICB9O1xuICBcbiAgICAvLyBwdWJsaWMgbWV0aG9kXG4gICAgdGhpc1t1cGRhdGVdID0gZnVuY3Rpb24gKCkge1xuICAgICAgY2hlY2tQb3NpdGlvbigpO1xuICAgICAgdXBkYXRlUGluKCk7IFxuICAgIH07XG4gIFxuICAgIC8vIGluaXRcbiAgICBpZiAoICEoc3RyaW5nQWZmaXggaW4gZWxlbWVudCApICkgeyAvLyBwcmV2ZW50IGFkZGluZyBldmVudCBoYW5kbGVycyB0d2ljZVxuICAgICAgb24oIGdsb2JhbE9iamVjdCwgc2Nyb2xsRXZlbnQsIHNlbGZbdXBkYXRlXSwgcGFzc2l2ZUhhbmRsZXIgKTtcbiAgICAgICFpc0lFOCAmJiBvbiggZ2xvYmFsT2JqZWN0LCByZXNpemVFdmVudCwgc2VsZlt1cGRhdGVdLCBwYXNzaXZlSGFuZGxlciApO1xuICB9XG4gICAgZWxlbWVudFtzdHJpbmdBZmZpeF0gPSBzZWxmO1xuICBcbiAgICBzZWxmW3VwZGF0ZV0oKTtcbiAgfTtcbiAgXG4gIC8vIEFGRklYIERBVEEgQVBJXG4gIC8vID09PT09PT09PT09PT09PT09XG4gIHN1cHBvcnRzW3B1c2hdKFtzdHJpbmdBZmZpeCwgQWZmaXgsICdbJytkYXRhU3B5Kyc9XCJhZmZpeFwiXSddKTtcbiAgXG4gIFxuICBcbiAgLyogTmF0aXZlIEphdmFzY3JpcHQgZm9yIEJvb3RzdHJhcCAzIHwgQWxlcnRcbiAgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSovXG4gIFxuICAvLyBBTEVSVCBERUZJTklUSU9OXG4gIC8vID09PT09PT09PT09PT09PT1cbiAgdmFyIEFsZXJ0ID0gZnVuY3Rpb24oIGVsZW1lbnQgKSB7XG4gICAgXG4gICAgLy8gaW5pdGlhbGl6YXRpb24gZWxlbWVudFxuICAgIGVsZW1lbnQgPSBxdWVyeUVsZW1lbnQoZWxlbWVudCk7XG4gIFxuICAgIC8vIGJpbmQsIHRhcmdldCBhbGVydCwgZHVyYXRpb24gYW5kIHN0dWZmXG4gICAgdmFyIHNlbGYgPSB0aGlzLCBjb21wb25lbnQgPSAnYWxlcnQnLFxuICAgICAgYWxlcnQgPSBnZXRDbG9zZXN0KGVsZW1lbnQsJy4nK2NvbXBvbmVudCksXG4gICAgICB0cmlnZ2VySGFuZGxlciA9IGZ1bmN0aW9uKCl7IGhhc0NsYXNzKGFsZXJ0LCdmYWRlJykgPyBlbXVsYXRlVHJhbnNpdGlvbkVuZChhbGVydCx0cmFuc2l0aW9uRW5kSGFuZGxlcikgOiB0cmFuc2l0aW9uRW5kSGFuZGxlcigpOyB9LFxuICAgICAgLy8gaGFuZGxlcnNcbiAgICAgIGNsaWNrSGFuZGxlciA9IGZ1bmN0aW9uKGUpe1xuICAgICAgICBhbGVydCA9IGdldENsb3Nlc3QoZVt0YXJnZXRdLCcuJytjb21wb25lbnQpO1xuICAgICAgICBlbGVtZW50ID0gcXVlcnlFbGVtZW50KCdbJytkYXRhRGlzbWlzcysnPVwiJytjb21wb25lbnQrJ1wiXScsYWxlcnQpO1xuICAgICAgICBlbGVtZW50ICYmIGFsZXJ0ICYmIChlbGVtZW50ID09PSBlW3RhcmdldF0gfHwgZWxlbWVudFtjb250YWluc10oZVt0YXJnZXRdKSkgJiYgc2VsZi5jbG9zZSgpO1xuICAgICAgfSxcbiAgICAgIHRyYW5zaXRpb25FbmRIYW5kbGVyID0gZnVuY3Rpb24oKXtcbiAgICAgICAgYm9vdHN0cmFwQ3VzdG9tRXZlbnQuY2FsbChhbGVydCwgY2xvc2VkRXZlbnQsIGNvbXBvbmVudCk7XG4gICAgICAgIG9mZihlbGVtZW50LCBjbGlja0V2ZW50LCBjbGlja0hhbmRsZXIpOyAvLyBkZXRhY2ggaXQncyBsaXN0ZW5lclxuICAgICAgICBhbGVydFtwYXJlbnROb2RlXS5yZW1vdmVDaGlsZChhbGVydCk7XG4gICAgICB9O1xuICAgIFxuICAgIC8vIHB1YmxpYyBtZXRob2RcbiAgICB0aGlzLmNsb3NlID0gZnVuY3Rpb24oKSB7XG4gICAgICBpZiAoIGFsZXJ0ICYmIGVsZW1lbnQgJiYgaGFzQ2xhc3MoYWxlcnQsaW5DbGFzcykgKSB7XG4gICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoYWxlcnQsIGNsb3NlRXZlbnQsIGNvbXBvbmVudCk7XG4gICAgICAgIHJlbW92ZUNsYXNzKGFsZXJ0LGluQ2xhc3MpO1xuICAgICAgICBhbGVydCAmJiB0cmlnZ2VySGFuZGxlcigpO1xuICAgICAgfVxuICAgIH07XG4gIFxuICAgIC8vIGluaXRcbiAgICBpZiAoICEoc3RyaW5nQWxlcnQgaW4gZWxlbWVudCApICkgeyAvLyBwcmV2ZW50IGFkZGluZyBldmVudCBoYW5kbGVycyB0d2ljZVxuICAgICAgb24oZWxlbWVudCwgY2xpY2tFdmVudCwgY2xpY2tIYW5kbGVyKTtcbiAgICB9XG4gICAgZWxlbWVudFtzdHJpbmdBbGVydF0gPSBzZWxmO1xuICB9O1xuICBcbiAgLy8gQUxFUlQgREFUQSBBUElcbiAgLy8gPT09PT09PT09PT09PT1cbiAgc3VwcG9ydHNbcHVzaF0oW3N0cmluZ0FsZXJ0LCBBbGVydCwgJ1snK2RhdGFEaXNtaXNzKyc9XCJhbGVydFwiXSddKTtcbiAgXG4gIFxuICBcbiAgLyogTmF0aXZlIEphdmFzY3JpcHQgZm9yIEJvb3RzdHJhcCAzIHwgQnV0dG9uXG4gIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSovXG4gIFxuICAvLyBCVVRUT04gREVGSU5JVElPTlxuICAvLyA9PT09PT09PT09PT09PT09PT09XG4gIHZhciBCdXR0b24gPSBmdW5jdGlvbiggZWxlbWVudCwgb3B0aW9uICkge1xuICBcbiAgICAvLyBpbml0aWFsaXphdGlvbiBlbGVtZW50XG4gICAgZWxlbWVudCA9IHF1ZXJ5RWxlbWVudChlbGVtZW50KTtcbiAgXG4gICAgLy8gc2V0IG9wdGlvblxuICAgIG9wdGlvbiA9IG9wdGlvbiB8fCBudWxsO1xuICBcbiAgICAvLyBjb25zdGFudFxuICAgIHZhciB0b2dnbGVkID0gZmFsc2UsIC8vIHRvZ2dsZWQgbWFrZXMgc3VyZSB0byBwcmV2ZW50IHRyaWdnZXJpbmcgdHdpY2UgdGhlIGNoYW5nZS5icy5idXR0b24gZXZlbnRzXG4gIFxuICAgICAgICAvLyBzdHJpbmdzXG4gICAgICAgIGNvbXBvbmVudCA9ICdidXR0b24nLFxuICAgICAgICBjaGVja2VkID0gJ2NoZWNrZWQnLFxuICAgICAgICByZXNldCA9ICdyZXNldCcsXG4gICAgICAgIExBQkVMID0gJ0xBQkVMJyxcbiAgICAgICAgSU5QVVQgPSAnSU5QVVQnLFxuICBcbiAgICAgIC8vIHByaXZhdGUgbWV0aG9kc1xuICAgICAgc2V0U3RhdGUgPSBmdW5jdGlvbigpIHtcbiAgICAgICAgaWYgKCAhISBvcHRpb24gJiYgb3B0aW9uICE9PSByZXNldCApIHtcbiAgICAgICAgICBpZiAoIG9wdGlvbiA9PT0gbG9hZGluZyApIHtcbiAgICAgICAgICAgIGFkZENsYXNzKGVsZW1lbnQsZGlzYWJsZWQpO1xuICAgICAgICAgICAgZWxlbWVudFtzZXRBdHRyaWJ1dGVdKGRpc2FibGVkLGRpc2FibGVkKTtcbiAgICAgICAgICAgIGVsZW1lbnRbc2V0QXR0cmlidXRlXShkYXRhT3JpZ2luYWxUZXh0LCBlbGVtZW50W2lubmVySFRNTF0udHJpbSgpKTsgLy8gdHJpbSB0aGUgdGV4dFxuICAgICAgICAgIH1cbiAgICAgICAgICBlbGVtZW50W2lubmVySFRNTF0gPSBlbGVtZW50W2dldEF0dHJpYnV0ZV0oJ2RhdGEtJytvcHRpb24rJy10ZXh0Jyk7XG4gICAgICAgIH1cbiAgICAgIH0sXG4gICAgICByZXNldFN0YXRlID0gZnVuY3Rpb24oKSB7XG4gICAgICAgIGlmIChlbGVtZW50W2dldEF0dHJpYnV0ZV0oZGF0YU9yaWdpbmFsVGV4dCkpIHtcbiAgICAgICAgICBpZiAoIGhhc0NsYXNzKGVsZW1lbnQsZGlzYWJsZWQpIHx8IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkaXNhYmxlZCkgPT09IGRpc2FibGVkICkge1xuICAgICAgICAgICAgcmVtb3ZlQ2xhc3MoZWxlbWVudCxkaXNhYmxlZCk7XG4gICAgICAgICAgICBlbGVtZW50LnJlbW92ZUF0dHJpYnV0ZShkaXNhYmxlZCk7XG4gICAgICAgICAgfVxuICAgICAgICAgIGVsZW1lbnRbaW5uZXJIVE1MXSA9IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhT3JpZ2luYWxUZXh0KTtcbiAgICAgICAgfVxuICAgICAgfSxcbiAgICAgIGtleUhhbmRsZXIgPSBmdW5jdGlvbihlKXsgXG4gICAgICAgIHZhciBrZXkgPSBlLndoaWNoIHx8IGUua2V5Q29kZTtcbiAgICAgICAga2V5ID09PSAzMiAmJiBlW3RhcmdldF0gPT09IERPQy5hY3RpdmVFbGVtZW50ICYmIHRvZ2dsZShlKTtcbiAgICAgIH0sXG4gICAgICBwcmV2ZW50U2Nyb2xsID0gZnVuY3Rpb24oZSl7IFxuICAgICAgICB2YXIga2V5ID0gZS53aGljaCB8fCBlLmtleUNvZGU7XG4gICAgICAgIGtleSA9PT0gMzIgJiYgZVtwcmV2ZW50RGVmYXVsdF0oKTtcbiAgICAgIH0sICAgIFxuICAgICAgdG9nZ2xlID0gZnVuY3Rpb24oZSkge1xuICAgICAgICB2YXIgbGFiZWwgPSBlW3RhcmdldF0udGFnTmFtZSA9PT0gTEFCRUwgPyBlW3RhcmdldF0gOiBlW3RhcmdldF1bcGFyZW50Tm9kZV0udGFnTmFtZSA9PT0gTEFCRUwgPyBlW3RhcmdldF1bcGFyZW50Tm9kZV0gOiBudWxsOyAvLyB0aGUgLmJ0biBsYWJlbFxuICAgICAgICBcbiAgICAgICAgaWYgKCAhbGFiZWwgKSByZXR1cm47IC8vcmVhY3QgaWYgYSBsYWJlbCBvciBpdHMgaW1tZWRpYXRlIGNoaWxkIGlzIGNsaWNrZWRcbiAgXG4gICAgICAgIHZhciBsYWJlbHMgPSBnZXRFbGVtZW50c0J5Q2xhc3NOYW1lKGxhYmVsW3BhcmVudE5vZGVdLCdidG4nKSwgLy8gYWxsIHRoZSBidXR0b24gZ3JvdXAgYnV0dG9uc1xuICAgICAgICAgIGlucHV0ID0gbGFiZWxbZ2V0RWxlbWVudHNCeVRhZ05hbWVdKElOUFVUKVswXTtcbiAgXG4gICAgICAgIGlmICggIWlucHV0ICkgcmV0dXJuOyAvLyByZXR1cm4gaWYgbm8gaW5wdXQgZm91bmRcbiAgXG4gICAgICAgIC8vIG1hbmFnZSB0aGUgZG9tIG1hbmlwdWxhdGlvblxuICAgICAgICBpZiAoIGlucHV0LnR5cGUgPT09ICdjaGVja2JveCcgKSB7IC8vY2hlY2tib3hlc1xuICAgICAgICAgIGlmICggIWlucHV0W2NoZWNrZWRdICkge1xuICAgICAgICAgICAgYWRkQ2xhc3MobGFiZWwsYWN0aXZlKTtcbiAgICAgICAgICAgIGlucHV0W2dldEF0dHJpYnV0ZV0oY2hlY2tlZCk7XG4gICAgICAgICAgICBpbnB1dFtzZXRBdHRyaWJ1dGVdKGNoZWNrZWQsY2hlY2tlZCk7XG4gICAgICAgICAgICBpbnB1dFtjaGVja2VkXSA9IHRydWU7XG4gICAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAgIHJlbW92ZUNsYXNzKGxhYmVsLGFjdGl2ZSk7XG4gICAgICAgICAgICBpbnB1dFtnZXRBdHRyaWJ1dGVdKGNoZWNrZWQpO1xuICAgICAgICAgICAgaW5wdXQucmVtb3ZlQXR0cmlidXRlKGNoZWNrZWQpO1xuICAgICAgICAgICAgaW5wdXRbY2hlY2tlZF0gPSBmYWxzZTtcbiAgICAgICAgICB9XG4gIFxuICAgICAgICAgIGlmICghdG9nZ2xlZCkgeyAvLyBwcmV2ZW50IHRyaWdnZXJpbmcgdGhlIGV2ZW50IHR3aWNlXG4gICAgICAgICAgICB0b2dnbGVkID0gdHJ1ZTtcbiAgICAgICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoaW5wdXQsIGNoYW5nZUV2ZW50LCBjb21wb25lbnQpOyAvL3RyaWdnZXIgdGhlIGNoYW5nZSBmb3IgdGhlIGlucHV0XG4gICAgICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKGVsZW1lbnQsIGNoYW5nZUV2ZW50LCBjb21wb25lbnQpOyAvL3RyaWdnZXIgdGhlIGNoYW5nZSBmb3IgdGhlIGJ0bi1ncm91cFxuICAgICAgICAgIH1cbiAgICAgICAgfVxuICBcbiAgICAgICAgaWYgKCBpbnB1dC50eXBlID09PSAncmFkaW8nICYmICF0b2dnbGVkICkgeyAvLyByYWRpbyBidXR0b25zXG4gICAgICAgICAgLy8gZG9uJ3QgdHJpZ2dlciBpZiBhbHJlYWR5IGFjdGl2ZSAodGhlIE9SIGNvbmRpdGlvbiBpcyBhIGhhY2sgdG8gY2hlY2sgaWYgdGhlIGJ1dHRvbnMgd2VyZSBzZWxlY3RlZCB3aXRoIGtleSBwcmVzcyBhbmQgTk9UIG1vdXNlIGNsaWNrKVxuICAgICAgICAgIGlmICggIWlucHV0W2NoZWNrZWRdIHx8IChlLnNjcmVlblggPT09IDAgJiYgZS5zY3JlZW5ZID09IDApICkge1xuICAgICAgICAgICAgYWRkQ2xhc3MobGFiZWwsYWN0aXZlKTtcbiAgICAgICAgICAgIGlucHV0W3NldEF0dHJpYnV0ZV0oY2hlY2tlZCxjaGVja2VkKTtcbiAgICAgICAgICAgIGlucHV0W2NoZWNrZWRdID0gdHJ1ZTtcbiAgICAgICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoaW5wdXQsIGNoYW5nZUV2ZW50LCBjb21wb25lbnQpOyAvL3RyaWdnZXIgdGhlIGNoYW5nZSBmb3IgdGhlIGlucHV0XG4gICAgICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKGVsZW1lbnQsIGNoYW5nZUV2ZW50LCBjb21wb25lbnQpOyAvL3RyaWdnZXIgdGhlIGNoYW5nZSBmb3IgdGhlIGJ0bi1ncm91cFxuICBcbiAgICAgICAgICAgIHRvZ2dsZWQgPSB0cnVlO1xuICAgICAgICAgICAgZm9yICh2YXIgaSA9IDAsIGxsID0gbGFiZWxzW2xlbmd0aF07IGk8bGw7IGkrKykge1xuICAgICAgICAgICAgICB2YXIgb3RoZXJMYWJlbCA9IGxhYmVsc1tpXSwgb3RoZXJJbnB1dCA9IG90aGVyTGFiZWxbZ2V0RWxlbWVudHNCeVRhZ05hbWVdKElOUFVUKVswXTtcbiAgICAgICAgICAgICAgaWYgKCBvdGhlckxhYmVsICE9PSBsYWJlbCAmJiBoYXNDbGFzcyhvdGhlckxhYmVsLGFjdGl2ZSkgKSAge1xuICAgICAgICAgICAgICAgIHJlbW92ZUNsYXNzKG90aGVyTGFiZWwsYWN0aXZlKTtcbiAgICAgICAgICAgICAgICBvdGhlcklucHV0LnJlbW92ZUF0dHJpYnV0ZShjaGVja2VkKTtcbiAgICAgICAgICAgICAgICBvdGhlcklucHV0W2NoZWNrZWRdID0gZmFsc2U7XG4gICAgICAgICAgICAgICAgYm9vdHN0cmFwQ3VzdG9tRXZlbnQuY2FsbChvdGhlcklucHV0LCBjaGFuZ2VFdmVudCwgY29tcG9uZW50KTsgLy8gdHJpZ2dlciB0aGUgY2hhbmdlXG4gICAgICAgICAgICAgIH1cbiAgICAgICAgICAgIH1cbiAgICAgICAgICB9XG4gICAgICAgIH1cbiAgICAgICAgc2V0VGltZW91dCggZnVuY3Rpb24oKSB7IHRvZ2dsZWQgPSBmYWxzZTsgfSwgNTAgKTtcbiAgICAgIH07XG4gIFxuICAgIC8vIGluaXRcbiAgICBpZiAoIGhhc0NsYXNzKGVsZW1lbnQsJ2J0bicpICkgeyAvLyB3aGVuIEJ1dHRvbiB0ZXh0IGlzIHVzZWQgd2UgZXhlY3V0ZSBpdCBhcyBhbiBpbnN0YW5jZSBtZXRob2RcbiAgICAgIGlmICggb3B0aW9uICE9PSBudWxsICkge1xuICAgICAgICBpZiAoIG9wdGlvbiAhPT0gcmVzZXQgKSB7IHNldFN0YXRlKCk7IH0gXG4gICAgICAgIGVsc2UgeyByZXNldFN0YXRlKCk7IH1cbiAgICAgIH1cbiAgICB9IGVsc2UgeyAvLyBpZiAoIGhhc0NsYXNzKGVsZW1lbnQsJ2J0bi1ncm91cCcpICkgLy8gd2UgYWxsb3cgdGhlIHNjcmlwdCB0byB3b3JrIG91dHNpZGUgYnRuLWdyb3VwIGNvbXBvbmVudFxuICAgICAgXG4gICAgICBpZiAoICEoIHN0cmluZ0J1dHRvbiBpbiBlbGVtZW50ICkgKSB7IC8vIHByZXZlbnQgYWRkaW5nIGV2ZW50IGhhbmRsZXJzIHR3aWNlXG4gICAgICAgIG9uKCBlbGVtZW50LCBjbGlja0V2ZW50LCB0b2dnbGUgKTtcbiAgICAgICAgb24oIGVsZW1lbnQsIGtleXVwRXZlbnQsIGtleUhhbmRsZXIgKSwgb24oIGVsZW1lbnQsIGtleWRvd25FdmVudCwgcHJldmVudFNjcm9sbCApO1xuICAgICAgfVxuICBcbiAgICAgIC8vIGFjdGl2YXRlIGl0ZW1zIG9uIGxvYWRcbiAgICAgIHZhciBsYWJlbHNUb0FDdGl2YXRlID0gZ2V0RWxlbWVudHNCeUNsYXNzTmFtZShlbGVtZW50LCAnYnRuJyksIGxibGwgPSBsYWJlbHNUb0FDdGl2YXRlW2xlbmd0aF07XG4gICAgICBmb3IgKHZhciBpPTA7IGk8bGJsbDsgaSsrKSB7XG4gICAgICAgICFoYXNDbGFzcyhsYWJlbHNUb0FDdGl2YXRlW2ldLGFjdGl2ZSkgJiYgcXVlcnlFbGVtZW50KCdpbnB1dCcsbGFiZWxzVG9BQ3RpdmF0ZVtpXSlbZ2V0QXR0cmlidXRlXShjaGVja2VkKVxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICYmIGFkZENsYXNzKGxhYmVsc1RvQUN0aXZhdGVbaV0sYWN0aXZlKTtcbiAgICAgIH1cbiAgICAgIGVsZW1lbnRbc3RyaW5nQnV0dG9uXSA9IHRoaXM7XG4gICAgfVxuICB9O1xuICBcbiAgLy8gQlVUVE9OIERBVEEgQVBJXG4gIC8vID09PT09PT09PT09PT09PT09XG4gIHN1cHBvcnRzW3B1c2hdKCBbIHN0cmluZ0J1dHRvbiwgQnV0dG9uLCAnWycrZGF0YVRvZ2dsZSsnPVwiYnV0dG9uc1wiXScgXSApO1xuICBcbiAgXG4gIC8qIE5hdGl2ZSBKYXZhc2NyaXB0IGZvciBCb290c3RyYXAgMyB8IENhcm91c2VsXG4gIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0qL1xuICBcbiAgLy8gQ0FST1VTRUwgREVGSU5JVElPTlxuICAvLyA9PT09PT09PT09PT09PT09PT09XG4gIHZhciBDYXJvdXNlbCA9IGZ1bmN0aW9uKCBlbGVtZW50LCBvcHRpb25zICkge1xuICBcbiAgICAvLyBpbml0aWFsaXphdGlvbiBlbGVtZW50XG4gICAgZWxlbWVudCA9IHF1ZXJ5RWxlbWVudCggZWxlbWVudCApO1xuICBcbiAgICAvLyBzZXQgb3B0aW9uc1xuICAgIG9wdGlvbnMgPSBvcHRpb25zIHx8IHt9O1xuICBcbiAgICAvLyBEQVRBIEFQSVxuICAgIHZhciBpbnRlcnZhbEF0dHJpYnV0ZSA9IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhSW50ZXJ2YWwpLFxuICAgICAgICBpbnRlcnZhbE9wdGlvbiA9IG9wdGlvbnNbaW50ZXJ2YWxdLFxuICAgICAgICBpbnRlcnZhbERhdGEgPSBpbnRlcnZhbEF0dHJpYnV0ZSA9PT0gJ2ZhbHNlJyA/IDAgOiBwYXJzZUludChpbnRlcnZhbEF0dHJpYnV0ZSksICBcbiAgICAgICAgcGF1c2VEYXRhID0gZWxlbWVudFtnZXRBdHRyaWJ1dGVdKGRhdGFQYXVzZSkgPT09IGhvdmVyRXZlbnQgfHwgZmFsc2UsXG4gICAgICAgIGtleWJvYXJkRGF0YSA9IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhS2V5Ym9hcmQpID09PSAndHJ1ZScgfHwgZmFsc2UsXG4gICAgICBcbiAgICAgICAgLy8gc3RyaW5nc1xuICAgICAgICBjb21wb25lbnQgPSAnY2Fyb3VzZWwnLFxuICAgICAgICBwYXVzZWQgPSAncGF1c2VkJyxcbiAgICAgICAgZGlyZWN0aW9uID0gJ2RpcmVjdGlvbicsXG4gICAgICAgIGRhdGFTbGlkZVRvID0gJ2RhdGEtc2xpZGUtdG8nOyBcbiAgXG4gICAgdGhpc1trZXlib2FyZF0gPSBvcHRpb25zW2tleWJvYXJkXSA9PT0gdHJ1ZSB8fCBrZXlib2FyZERhdGE7XG4gICAgdGhpc1twYXVzZV0gPSAob3B0aW9uc1twYXVzZV0gPT09IGhvdmVyRXZlbnQgfHwgcGF1c2VEYXRhKSA/IGhvdmVyRXZlbnQgOiBmYWxzZTsgLy8gZmFsc2UgLyBob3ZlclxuICBcbiAgICB0aGlzW2ludGVydmFsXSA9IHR5cGVvZiBpbnRlcnZhbE9wdGlvbiA9PT0gJ251bWJlcicgPyBpbnRlcnZhbE9wdGlvblxuICAgICAgICAgICAgICAgICAgIDogaW50ZXJ2YWxPcHRpb24gPT09IGZhbHNlIHx8IGludGVydmFsRGF0YSA9PT0gMCB8fCBpbnRlcnZhbERhdGEgPT09IGZhbHNlID8gMFxuICAgICAgICAgICAgICAgICAgIDogaXNOYU4oaW50ZXJ2YWxEYXRhKSA/IDUwMDAgLy8gYm9vdHN0cmFwIGNhcm91c2VsIGRlZmF1bHQgaW50ZXJ2YWxcbiAgICAgICAgICAgICAgICAgICA6IGludGVydmFsRGF0YTtcbiAgXG4gICAgLy8gYmluZCwgZXZlbnQgdGFyZ2V0c1xuICAgIHZhciBzZWxmID0gdGhpcywgaW5kZXggPSBlbGVtZW50LmluZGV4ID0gMCwgdGltZXIgPSBlbGVtZW50LnRpbWVyID0gMCwgXG4gICAgICBpc1NsaWRpbmcgPSBmYWxzZSwgLy8gaXNTbGlkaW5nIHByZXZlbnRzIGNsaWNrIGV2ZW50IGhhbmRsZXJzIHdoZW4gYW5pbWF0aW9uIGlzIHJ1bm5pbmdcbiAgICAgIGlzVG91Y2ggPSBmYWxzZSwgc3RhcnRYUG9zaXRpb24gPSBudWxsLCBjdXJyZW50WFBvc2l0aW9uID0gbnVsbCwgZW5kWFBvc2l0aW9uID0gbnVsbCwgLy8gdG91Y2ggYW5kIGV2ZW50IGNvb3JkaW5hdGVzXG4gICAgICBzbGlkZXMgPSBnZXRFbGVtZW50c0J5Q2xhc3NOYW1lKGVsZW1lbnQsJ2l0ZW0nKSwgdG90YWwgPSBzbGlkZXNbbGVuZ3RoXSxcbiAgICAgIHNsaWRlRGlyZWN0aW9uID0gdGhpc1tkaXJlY3Rpb25dID0gbGVmdCxcbiAgICAgIGNvbnRyb2xzID0gZ2V0RWxlbWVudHNCeUNsYXNzTmFtZShlbGVtZW50LGNvbXBvbmVudCsnLWNvbnRyb2wnKSxcbiAgICAgIGxlZnRBcnJvdyA9IGNvbnRyb2xzWzBdLCByaWdodEFycm93ID0gY29udHJvbHNbMV0sXG4gICAgICBpbmRpY2F0b3IgPSBxdWVyeUVsZW1lbnQoICcuJytjb21wb25lbnQrJy1pbmRpY2F0b3JzJywgZWxlbWVudCApLFxuICAgICAgaW5kaWNhdG9ycyA9IGluZGljYXRvciAmJiBpbmRpY2F0b3JbZ2V0RWxlbWVudHNCeVRhZ05hbWVdKCBcIkxJXCIgKSB8fCBbXTtcbiAgXG4gICAgLy8gaW52YWxpZGF0ZSB3aGVuIG5vdCBlbm91Z2ggaXRlbXNcbiAgICBpZiAodG90YWwgPCAyKSB7IHJldHVybjsgfVxuICBcbiAgICAvLyBoYW5kbGVyc1xuICAgIHZhciBwYXVzZUhhbmRsZXIgPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgIGlmICggc2VsZltpbnRlcnZhbF0gIT09ZmFsc2UgJiYgIWhhc0NsYXNzKGVsZW1lbnQscGF1c2VkKSApIHtcbiAgICAgICAgICBhZGRDbGFzcyhlbGVtZW50LHBhdXNlZCk7XG4gICAgICAgICAgIWlzU2xpZGluZyAmJiAoIGNsZWFySW50ZXJ2YWwodGltZXIpLCB0aW1lciA9IG51bGwgKTtcbiAgICAgICAgfVxuICAgICAgfSxcbiAgICAgIHJlc3VtZUhhbmRsZXIgPSBmdW5jdGlvbigpIHtcbiAgICAgICAgaWYgKCBzZWxmW2ludGVydmFsXSAhPT0gZmFsc2UgJiYgaGFzQ2xhc3MoZWxlbWVudCxwYXVzZWQpICkge1xuICAgICAgICAgIHJlbW92ZUNsYXNzKGVsZW1lbnQscGF1c2VkKTtcbiAgICAgICAgICAhaXNTbGlkaW5nICYmICggY2xlYXJJbnRlcnZhbCh0aW1lciksIHRpbWVyID0gbnVsbCApO1xuICAgICAgICAgICFpc1NsaWRpbmcgJiYgc2VsZi5jeWNsZSgpO1xuICAgICAgICB9XG4gICAgICB9LFxuICAgICAgaW5kaWNhdG9ySGFuZGxlciA9IGZ1bmN0aW9uKGUpIHtcbiAgICAgICAgZVtwcmV2ZW50RGVmYXVsdF0oKTtcbiAgICAgICAgaWYgKGlzU2xpZGluZykgcmV0dXJuO1xuICBcbiAgICAgICAgdmFyIGV2ZW50VGFyZ2V0ID0gZVt0YXJnZXRdOyAvLyBldmVudCB0YXJnZXQgfCB0aGUgY3VycmVudCBhY3RpdmUgaXRlbVxuICBcbiAgICAgICAgaWYgKCBldmVudFRhcmdldCAmJiAhaGFzQ2xhc3MoZXZlbnRUYXJnZXQsYWN0aXZlKSAmJiBldmVudFRhcmdldFtnZXRBdHRyaWJ1dGVdKGRhdGFTbGlkZVRvKSApIHtcbiAgICAgICAgICBpbmRleCA9IHBhcnNlSW50KCBldmVudFRhcmdldFtnZXRBdHRyaWJ1dGVdKGRhdGFTbGlkZVRvKSwgMTAgKTtcbiAgICAgICAgfSBlbHNlIHsgcmV0dXJuIGZhbHNlOyB9XG4gIFxuICAgICAgICBzZWxmLnNsaWRlVG8oIGluZGV4ICk7IC8vRG8gdGhlIHNsaWRlXG4gICAgICB9LFxuICAgICAgY29udHJvbHNIYW5kbGVyID0gZnVuY3Rpb24gKGUpIHtcbiAgICAgICAgZVtwcmV2ZW50RGVmYXVsdF0oKTtcbiAgICAgICAgaWYgKGlzU2xpZGluZykgcmV0dXJuO1xuICBcbiAgICAgICAgdmFyIGV2ZW50VGFyZ2V0ID0gZS5jdXJyZW50VGFyZ2V0IHx8IGUuc3JjRWxlbWVudDtcbiAgXG4gICAgICAgIGlmICggZXZlbnRUYXJnZXQgPT09IHJpZ2h0QXJyb3cgKSB7XG4gICAgICAgICAgaW5kZXgrKztcbiAgICAgICAgfSBlbHNlIGlmICggZXZlbnRUYXJnZXQgPT09IGxlZnRBcnJvdyApIHtcbiAgICAgICAgICBpbmRleC0tO1xuICAgICAgICB9XG4gIFxuICAgICAgICBzZWxmLnNsaWRlVG8oIGluZGV4ICk7IC8vRG8gdGhlIHNsaWRlXG4gICAgICB9LFxuICAgICAga2V5SGFuZGxlciA9IGZ1bmN0aW9uIChlKSB7XG4gICAgICAgIGlmIChpc1NsaWRpbmcpIHJldHVybjtcbiAgICAgICAgc3dpdGNoIChlLndoaWNoKSB7XG4gICAgICAgICAgY2FzZSAzOTpcbiAgICAgICAgICAgIGluZGV4Kys7XG4gICAgICAgICAgICBicmVhaztcbiAgICAgICAgICBjYXNlIDM3OlxuICAgICAgICAgICAgaW5kZXgtLTtcbiAgICAgICAgICAgIGJyZWFrO1xuICAgICAgICAgIGRlZmF1bHQ6IHJldHVybjtcbiAgICAgICAgfVxuICAgICAgICBzZWxmLnNsaWRlVG8oIGluZGV4ICk7IC8vRG8gdGhlIHNsaWRlXG4gICAgICB9LFxuICAgICAgLy8gdG91Y2ggZXZlbnRzXG4gICAgICB0b2dnbGVUb3VjaEV2ZW50cyA9IGZ1bmN0aW9uKHRvZ2dsZSl7XG4gICAgICAgIHRvZ2dsZSggZWxlbWVudCwgdG91Y2hFdmVudHMubW92ZSwgdG91Y2hNb3ZlSGFuZGxlciwgcGFzc2l2ZUhhbmRsZXIgKTtcbiAgICAgICAgdG9nZ2xlKCBlbGVtZW50LCB0b3VjaEV2ZW50cy5lbmQsIHRvdWNoRW5kSGFuZGxlciwgcGFzc2l2ZUhhbmRsZXIgKTtcbiAgICB9LCAgXG4gICAgICB0b3VjaERvd25IYW5kbGVyID0gZnVuY3Rpb24oZSkge1xuICAgICAgICBpZiAoIGlzVG91Y2ggKSB7IHJldHVybjsgfSBcbiAgICAgICAgICBcbiAgICAgICAgc3RhcnRYUG9zaXRpb24gPSBwYXJzZUludChlLnRvdWNoZXNbMF0ucGFnZVgpO1xuICBcbiAgICAgICAgaWYgKCBlbGVtZW50LmNvbnRhaW5zKGVbdGFyZ2V0XSkgKSB7XG4gICAgICAgICAgaXNUb3VjaCA9IHRydWU7XG4gICAgICAgICAgdG9nZ2xlVG91Y2hFdmVudHMob24pO1xuICAgICAgICB9XG4gICAgICB9LFxuICAgICAgdG91Y2hNb3ZlSGFuZGxlciA9IGZ1bmN0aW9uKGUpIHtcbiAgICAgICAgaWYgKCAhaXNUb3VjaCApIHsgZS5wcmV2ZW50RGVmYXVsdCgpOyByZXR1cm47IH1cbiAgXG4gICAgICAgIGN1cnJlbnRYUG9zaXRpb24gPSBwYXJzZUludChlLnRvdWNoZXNbMF0ucGFnZVgpO1xuICAgICAgICBcbiAgICAgICAgLy9jYW5jZWwgdG91Y2ggaWYgbW9yZSB0aGFuIG9uZSB0b3VjaGVzIGRldGVjdGVkXG4gICAgICAgIGlmICggZS50eXBlID09PSAndG91Y2htb3ZlJyAmJiBlLnRvdWNoZXNbbGVuZ3RoXSA+IDEgKSB7XG4gICAgICAgICAgZS5wcmV2ZW50RGVmYXVsdCgpO1xuICAgICAgICAgIHJldHVybiBmYWxzZTtcbiAgICAgICAgfVxuICAgICAgfSxcbiAgICAgIHRvdWNoRW5kSGFuZGxlciA9IGZ1bmN0aW9uKGUpIHtcbiAgICAgICAgaWYgKCAhaXNUb3VjaCB8fCBpc1NsaWRpbmcgKSB7IHJldHVybiB9XG4gICAgICAgIFxuICAgICAgICBlbmRYUG9zaXRpb24gPSBjdXJyZW50WFBvc2l0aW9uIHx8IHBhcnNlSW50KCBlLnRvdWNoZXNbMF0ucGFnZVggKTtcbiAgXG4gICAgICAgIGlmICggaXNUb3VjaCApIHtcbiAgICAgICAgICBpZiAoICghZWxlbWVudC5jb250YWlucyhlW3RhcmdldF0pIHx8ICFlbGVtZW50LmNvbnRhaW5zKGUucmVsYXRlZFRhcmdldCkgKSAmJiBNYXRoLmFicyhzdGFydFhQb3NpdGlvbiAtIGVuZFhQb3NpdGlvbikgPCA3NSApIHtcbiAgICAgICAgICAgIHJldHVybiBmYWxzZTtcbiAgICAgICAgICB9IGVsc2Uge1xuICAgICAgICAgICAgaWYgKCBjdXJyZW50WFBvc2l0aW9uIDwgc3RhcnRYUG9zaXRpb24gKSB7XG4gICAgICAgICAgICAgIGluZGV4Kys7XG4gICAgICAgICAgICB9IGVsc2UgaWYgKCBjdXJyZW50WFBvc2l0aW9uID4gc3RhcnRYUG9zaXRpb24gKSB7XG4gICAgICAgICAgICAgIGluZGV4LS07ICAgICAgICBcbiAgICAgICAgICAgIH1cbiAgICAgICAgICAgIGlzVG91Y2ggPSBmYWxzZTtcbiAgICAgICAgICAgIHNlbGYuc2xpZGVUbyhpbmRleCk7XG4gICAgICAgICAgfVxuICAgICAgICAgIHRvZ2dsZVRvdWNoRXZlbnRzKG9mZik7ICAgICAgICAgICAgXG4gICAgICAgIH1cbiAgICAgIH0sXG4gIFxuICAgICAgLy8gcHJpdmF0ZSBtZXRob2RzXG4gICAgICBpc0VsZW1lbnRJblNjcm9sbFJhbmdlID0gZnVuY3Rpb24gKCkge1xuICAgICAgICB2YXIgcmVjdCA9IGVsZW1lbnRbZ2V0Qm91bmRpbmdDbGllbnRSZWN0XSgpLFxuICAgICAgICAgIHZpZXdwb3J0SGVpZ2h0ID0gZ2xvYmFsT2JqZWN0W2lubmVySGVpZ2h0XSB8fCBIVE1MW2NsaWVudEhlaWdodF1cbiAgICAgICAgcmV0dXJuIHJlY3RbdG9wXSA8PSB2aWV3cG9ydEhlaWdodCAmJiByZWN0W2JvdHRvbV0gPj0gMDsgLy8gYm90dG9tICYmIHRvcFxuICAgICAgfSwgIFxuICAgICAgc2V0QWN0aXZlUGFnZSA9IGZ1bmN0aW9uKCBwYWdlSW5kZXggKSB7IC8vaW5kaWNhdG9yc1xuICAgICAgICBmb3IgKCB2YXIgaSA9IDAsIGljbCA9IGluZGljYXRvcnNbbGVuZ3RoXTsgaSA8IGljbDsgaSsrICkge1xuICAgICAgICAgIHJlbW92ZUNsYXNzKGluZGljYXRvcnNbaV0sYWN0aXZlKTtcbiAgICAgICAgfVxuICAgICAgICBpZiAoaW5kaWNhdG9yc1twYWdlSW5kZXhdKSBhZGRDbGFzcyhpbmRpY2F0b3JzW3BhZ2VJbmRleF0sIGFjdGl2ZSk7XG4gICAgICB9O1xuICBcbiAgXG4gICAgLy8gcHVibGljIG1ldGhvZHNcbiAgICB0aGlzLmN5Y2xlID0gZnVuY3Rpb24oKSB7XG4gICAgICBpZiAodGltZXIpIHtcbiAgICAgICAgY2xlYXJJbnRlcnZhbCh0aW1lcik7XG4gICAgICAgIHRpbWVyID0gbnVsbDtcbiAgICAgIH1cbiAgXG4gICAgICB0aW1lciA9IHNldEludGVydmFsKGZ1bmN0aW9uKCkge1xuICAgICAgICBpc0VsZW1lbnRJblNjcm9sbFJhbmdlKCkgJiYgKGluZGV4KyssIHNlbGYuc2xpZGVUbyggaW5kZXggKSApO1xuICAgICAgfSwgdGhpc1tpbnRlcnZhbF0pO1xuICAgIH07XG4gICAgdGhpcy5zbGlkZVRvID0gZnVuY3Rpb24oIG5leHQgKSB7XG4gICAgICBpZiAoaXNTbGlkaW5nKSByZXR1cm47IC8vIHdoZW4gY29udHJvbGVkIHZpYSBtZXRob2RzLCBtYWtlIHN1cmUgdG8gY2hlY2sgYWdhaW5cbiAgXG4gICAgICB2YXIgYWN0aXZlSXRlbSA9IHRoaXMuZ2V0QWN0aXZlSW5kZXgoKSwgLy8gdGhlIGN1cnJlbnQgYWN0aXZlXG4gICAgICAgICAgb3JpZW50YXRpb247XG4gICAgICBcbiAgICAgICAgLy8gZmlyc3QgcmV0dXJuIGlmIHdlJ3JlIG9uIHRoZSBzYW1lIGl0ZW0gIzIyN1xuICAgICAgICBpZiAoIGFjdGl2ZUl0ZW0gPT09IG5leHQgKSB7XG4gICAgICAgICAgcmV0dXJuO1xuICAgICAgICAvLyBvciBkZXRlcm1pbmUgc2xpZGVEaXJlY3Rpb25cbiAgICAgICAgfSBlbHNlIGlmICAoIChhY3RpdmVJdGVtIDwgbmV4dCApIHx8IChhY3RpdmVJdGVtID09PSAwICYmIG5leHQgPT09IHRvdGFsIC0xICkgKSB7XG4gICAgICAgIHNsaWRlRGlyZWN0aW9uID0gc2VsZltkaXJlY3Rpb25dID0gbGVmdDsgLy8gbmV4dFxuICAgICAgfSBlbHNlIGlmICAoIChhY3RpdmVJdGVtID4gbmV4dCkgfHwgKGFjdGl2ZUl0ZW0gPT09IHRvdGFsIC0gMSAmJiBuZXh0ID09PSAwICkgKSB7XG4gICAgICAgIHNsaWRlRGlyZWN0aW9uID0gc2VsZltkaXJlY3Rpb25dID0gcmlnaHQ7IC8vIHByZXZcbiAgICAgIH1cbiAgXG4gICAgICAvLyBmaW5kIHRoZSByaWdodCBuZXh0IGluZGV4IFxuICAgICAgaWYgKCBuZXh0IDwgMCApIHsgbmV4dCA9IHRvdGFsIC0gMTsgfSBcbiAgICAgIGVsc2UgaWYgKCBuZXh0ID49IHRvdGFsICl7IG5leHQgPSAwOyB9XG4gIFxuICAgICAgLy8gdXBkYXRlIGluZGV4XG4gICAgICBpbmRleCA9IG5leHQ7XG4gICAgICBcbiAgICAgIG9yaWVudGF0aW9uID0gc2xpZGVEaXJlY3Rpb24gPT09IGxlZnQgPyAnbmV4dCcgOiAncHJldic7IC8vZGV0ZXJtaW5lIHR5cGVcbiAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoZWxlbWVudCwgc2xpZGVFdmVudCwgY29tcG9uZW50LCBzbGlkZXNbbmV4dF0pOyAvLyBoZXJlIHdlIGdvIHdpdGggdGhlIHNsaWRlXG4gIFxuICAgICAgaXNTbGlkaW5nID0gdHJ1ZTtcbiAgICAgIGNsZWFySW50ZXJ2YWwodGltZXIpO1xuICAgICAgdGltZXIgPSBudWxsO1xuICAgICAgc2V0QWN0aXZlUGFnZSggbmV4dCApO1xuICBcbiAgICAgIGlmICggc3VwcG9ydFRyYW5zaXRpb25zICYmIGhhc0NsYXNzKGVsZW1lbnQsJ3NsaWRlJykgKSB7XG4gIFxuICAgICAgICBhZGRDbGFzcyhzbGlkZXNbbmV4dF0sb3JpZW50YXRpb24pO1xuICAgICAgICBzbGlkZXNbbmV4dF1bb2Zmc2V0V2lkdGhdO1xuICAgICAgICBhZGRDbGFzcyhzbGlkZXNbbmV4dF0sc2xpZGVEaXJlY3Rpb24pO1xuICAgICAgICBhZGRDbGFzcyhzbGlkZXNbYWN0aXZlSXRlbV0sc2xpZGVEaXJlY3Rpb24pO1xuICBcbiAgICAgICAgZW11bGF0ZVRyYW5zaXRpb25FbmQoc2xpZGVzW25leHRdLCBmdW5jdGlvbihlKSB7XG4gICAgICAgICAgdmFyIHRpbWVvdXQgPSBlICYmIGVbdGFyZ2V0XSAhPT0gc2xpZGVzW25leHRdID8gZS5lbGFwc2VkVGltZSoxMDAwKzEwMCA6IDIwO1xuICAgICAgICAgIGlzU2xpZGluZyAmJiBzZXRUaW1lb3V0KGZ1bmN0aW9uKCl7XG4gICAgICAgICAgICBpc1NsaWRpbmcgPSBmYWxzZTtcbiAgXG4gICAgICAgICAgICBhZGRDbGFzcyhzbGlkZXNbbmV4dF0sYWN0aXZlKTtcbiAgICAgICAgICAgIHJlbW92ZUNsYXNzKHNsaWRlc1thY3RpdmVJdGVtXSxhY3RpdmUpO1xuICBcbiAgICAgICAgICAgIHJlbW92ZUNsYXNzKHNsaWRlc1tuZXh0XSxvcmllbnRhdGlvbik7XG4gICAgICAgICAgICByZW1vdmVDbGFzcyhzbGlkZXNbbmV4dF0sc2xpZGVEaXJlY3Rpb24pO1xuICAgICAgICAgICAgcmVtb3ZlQ2xhc3Moc2xpZGVzW2FjdGl2ZUl0ZW1dLHNsaWRlRGlyZWN0aW9uKTtcbiAgXG4gICAgICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKGVsZW1lbnQsIHNsaWRFdmVudCwgY29tcG9uZW50LCBzbGlkZXNbbmV4dF0pO1xuICBcbiAgICAgICAgICAgIGlmICggc2VsZltpbnRlcnZhbF0gJiYgIWhhc0NsYXNzKGVsZW1lbnQscGF1c2VkKSApIHtcbiAgICAgICAgICAgICAgc2VsZi5jeWNsZSgpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgIH0sIHRpbWVvdXQpO1xuICAgICAgICB9KTtcbiAgXG4gICAgICB9IGVsc2Uge1xuICAgICAgICBhZGRDbGFzcyhzbGlkZXNbbmV4dF0sYWN0aXZlKTtcbiAgICAgICAgc2xpZGVzW25leHRdW29mZnNldFdpZHRoXTtcbiAgICAgICAgcmVtb3ZlQ2xhc3Moc2xpZGVzW2FjdGl2ZUl0ZW1dLGFjdGl2ZSk7XG4gICAgICAgIHNldFRpbWVvdXQoZnVuY3Rpb24oKSB7XG4gICAgICAgICAgaXNTbGlkaW5nID0gZmFsc2U7XG4gICAgICAgICAgaWYgKCBzZWxmW2ludGVydmFsXSAmJiAhaGFzQ2xhc3MoZWxlbWVudCxwYXVzZWQpICkge1xuICAgICAgICAgICAgc2VsZi5jeWNsZSgpO1xuICAgICAgICAgIH1cbiAgICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKGVsZW1lbnQsIHNsaWRFdmVudCwgY29tcG9uZW50LCBzbGlkZXNbbmV4dF0pO1xuICAgICAgICB9LCAxMDAgKTtcbiAgICAgIH1cbiAgICB9O1xuICAgIHRoaXMuZ2V0QWN0aXZlSW5kZXggPSBmdW5jdGlvbiAoKSB7XG4gICAgICByZXR1cm4gc2xpZGVzW2luZGV4T2ZdKGdldEVsZW1lbnRzQnlDbGFzc05hbWUoZWxlbWVudCwnaXRlbSBhY3RpdmUnKVswXSkgfHwgMDtcbiAgICB9O1xuICBcbiAgICAvLyBpbml0XG4gICAgaWYgKCAhKHN0cmluZ0Nhcm91c2VsIGluIGVsZW1lbnQgKSApIHsgLy8gcHJldmVudCBhZGRpbmcgZXZlbnQgaGFuZGxlcnMgdHdpY2VcbiAgXG4gICAgICBpZiAoIHNlbGZbcGF1c2VdICYmIHNlbGZbaW50ZXJ2YWxdICkge1xuICAgICAgICBvbiggZWxlbWVudCwgbW91c2VIb3ZlclswXSwgcGF1c2VIYW5kbGVyICk7XG4gICAgICAgIG9uKCBlbGVtZW50LCBtb3VzZUhvdmVyWzFdLCByZXN1bWVIYW5kbGVyICk7XG4gICAgICAgIG9uKCBlbGVtZW50LCB0b3VjaEV2ZW50cy5zdGFydCwgcGF1c2VIYW5kbGVyLCBwYXNzaXZlSGFuZGxlciApO1xuICAgICAgICBvbiggZWxlbWVudCwgdG91Y2hFdmVudHMuZW5kLCByZXN1bWVIYW5kbGVyLCBwYXNzaXZlSGFuZGxlciApO1xuICAgIH1cbiAgXG4gICAgICBzbGlkZXNbbGVuZ3RoXSA+IDEgJiYgb24oIGVsZW1lbnQsIHRvdWNoRXZlbnRzLnN0YXJ0LCB0b3VjaERvd25IYW5kbGVyLCBwYXNzaXZlSGFuZGxlciApO1xuICAgIFxuICAgICAgcmlnaHRBcnJvdyAmJiBvbiggcmlnaHRBcnJvdywgY2xpY2tFdmVudCwgY29udHJvbHNIYW5kbGVyICk7XG4gICAgICBsZWZ0QXJyb3cgJiYgb24oIGxlZnRBcnJvdywgY2xpY2tFdmVudCwgY29udHJvbHNIYW5kbGVyICk7XG4gICAgXG4gICAgICBpbmRpY2F0b3IgJiYgb24oIGluZGljYXRvciwgY2xpY2tFdmVudCwgaW5kaWNhdG9ySGFuZGxlciApO1xuICAgICAgc2VsZltrZXlib2FyZF0gJiYgb24oIGdsb2JhbE9iamVjdCwga2V5ZG93bkV2ZW50LCBrZXlIYW5kbGVyICk7XG4gIFxuICAgIH1cbiAgICBpZiAoc2VsZi5nZXRBY3RpdmVJbmRleCgpPDApIHtcbiAgICAgIHNsaWRlc1tsZW5ndGhdICYmIGFkZENsYXNzKHNsaWRlc1swXSxhY3RpdmUpO1xuICAgICAgaW5kaWNhdG9yc1tsZW5ndGhdICYmIHNldEFjdGl2ZVBhZ2UoMCk7XG4gICAgfVxuICBcbiAgICBpZiAoIHNlbGZbaW50ZXJ2YWxdICl7IHNlbGYuY3ljbGUoKTsgfVxuICAgIGVsZW1lbnRbc3RyaW5nQ2Fyb3VzZWxdID0gc2VsZjtcbiAgfTtcbiAgXG4gIC8vIENBUk9VU0VMIERBVEEgQVBJXG4gIC8vID09PT09PT09PT09PT09PT09XG4gIHN1cHBvcnRzW3B1c2hdKCBbIHN0cmluZ0Nhcm91c2VsLCBDYXJvdXNlbCwgJ1snK2RhdGFSaWRlKyc9XCJjYXJvdXNlbFwiXScgXSApO1xuICBcbiAgXG4gIC8qIE5hdGl2ZSBKYXZhc2NyaXB0IGZvciBCb290c3RyYXAgMyB8IENvbGxhcHNlXG4gIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tKi9cbiAgXG4gIC8vIENPTExBUFNFIERFRklOSVRJT05cbiAgLy8gPT09PT09PT09PT09PT09PT09PVxuICB2YXIgQ29sbGFwc2UgPSBmdW5jdGlvbiggZWxlbWVudCwgb3B0aW9ucyApIHtcbiAgXG4gICAgLy8gaW5pdGlhbGl6YXRpb24gZWxlbWVudFxuICAgIGVsZW1lbnQgPSBxdWVyeUVsZW1lbnQoZWxlbWVudCk7XG4gIFxuICAgIC8vIHNldCBvcHRpb25zXG4gICAgb3B0aW9ucyA9IG9wdGlvbnMgfHwge307XG4gIFxuICAgIC8vIGV2ZW50IHRhcmdldHMgYW5kIGNvbnN0YW50c1xuICAgIHZhciBhY2NvcmRpb24gPSBudWxsLCBjb2xsYXBzZSA9IG51bGwsIHNlbGYgPSB0aGlzLFxuICAgICAgYWNjb3JkaW9uRGF0YSA9IGVsZW1lbnRbZ2V0QXR0cmlidXRlXSgnZGF0YS1wYXJlbnQnKSxcbiAgICAgIGFjdGl2ZUNvbGxhcHNlLCBhY3RpdmVFbGVtZW50LFxuICBcbiAgICAgIC8vIGNvbXBvbmVudCBzdHJpbmdzXG4gICAgICBjb21wb25lbnQgPSAnY29sbGFwc2UnLFxuICAgICAgY29sbGFwc2VkID0gJ2NvbGxhcHNlZCcsXG4gICAgICBpc0FuaW1hdGluZyA9ICdpc0FuaW1hdGluZycsXG4gIFxuICAgICAgLy8gcHJpdmF0ZSBtZXRob2RzXG4gICAgICBvcGVuQWN0aW9uID0gZnVuY3Rpb24oY29sbGFwc2VFbGVtZW50LHRvZ2dsZSkge1xuICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKGNvbGxhcHNlRWxlbWVudCwgc2hvd0V2ZW50LCBjb21wb25lbnQpO1xuICAgICAgICBjb2xsYXBzZUVsZW1lbnRbaXNBbmltYXRpbmddID0gdHJ1ZTtcbiAgICAgICAgYWRkQ2xhc3MoY29sbGFwc2VFbGVtZW50LGNvbGxhcHNpbmcpO1xuICAgICAgICByZW1vdmVDbGFzcyhjb2xsYXBzZUVsZW1lbnQsY29tcG9uZW50KTtcbiAgICAgICAgY29sbGFwc2VFbGVtZW50W3N0eWxlXVtoZWlnaHRdID0gY29sbGFwc2VFbGVtZW50W3Njcm9sbEhlaWdodF0gKyAncHgnO1xuICAgICAgICBcbiAgICAgICAgZW11bGF0ZVRyYW5zaXRpb25FbmQoY29sbGFwc2VFbGVtZW50LCBmdW5jdGlvbigpIHtcbiAgICAgICAgICBjb2xsYXBzZUVsZW1lbnRbaXNBbmltYXRpbmddID0gZmFsc2U7XG4gICAgICAgICAgY29sbGFwc2VFbGVtZW50W3NldEF0dHJpYnV0ZV0oYXJpYUV4cGFuZGVkLCd0cnVlJyk7XG4gICAgICAgICAgdG9nZ2xlW3NldEF0dHJpYnV0ZV0oYXJpYUV4cGFuZGVkLCd0cnVlJyk7ICAgICAgICAgIFxuICAgICAgICAgIHJlbW92ZUNsYXNzKGNvbGxhcHNlRWxlbWVudCxjb2xsYXBzaW5nKTtcbiAgICAgICAgICBhZGRDbGFzcyhjb2xsYXBzZUVsZW1lbnQsIGNvbXBvbmVudCk7XG4gICAgICAgICAgYWRkQ2xhc3MoY29sbGFwc2VFbGVtZW50LCBpbkNsYXNzKTtcbiAgICAgICAgICBjb2xsYXBzZUVsZW1lbnRbc3R5bGVdW2hlaWdodF0gPSAnJztcbiAgICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKGNvbGxhcHNlRWxlbWVudCwgc2hvd25FdmVudCwgY29tcG9uZW50KTtcbiAgICAgICAgfSk7XG4gICAgICB9LFxuICAgICAgY2xvc2VBY3Rpb24gPSBmdW5jdGlvbihjb2xsYXBzZUVsZW1lbnQsdG9nZ2xlKSB7XG4gICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoY29sbGFwc2VFbGVtZW50LCBoaWRlRXZlbnQsIGNvbXBvbmVudCk7XG4gICAgICAgIGNvbGxhcHNlRWxlbWVudFtpc0FuaW1hdGluZ10gPSB0cnVlO1xuICAgICAgICBjb2xsYXBzZUVsZW1lbnRbc3R5bGVdW2hlaWdodF0gPSBjb2xsYXBzZUVsZW1lbnRbc2Nyb2xsSGVpZ2h0XSArICdweCc7IC8vIHNldCBoZWlnaHQgZmlyc3RcbiAgICAgICAgcmVtb3ZlQ2xhc3MoY29sbGFwc2VFbGVtZW50LGNvbXBvbmVudCk7XG4gICAgICAgIHJlbW92ZUNsYXNzKGNvbGxhcHNlRWxlbWVudCwgaW5DbGFzcyk7XG4gICAgICAgIGFkZENsYXNzKGNvbGxhcHNlRWxlbWVudCwgY29sbGFwc2luZyk7XG4gICAgICAgIGNvbGxhcHNlRWxlbWVudFtvZmZzZXRXaWR0aF07IC8vIGZvcmNlIHJlZmxvdyB0byBlbmFibGUgdHJhbnNpdGlvblxuICAgICAgICBjb2xsYXBzZUVsZW1lbnRbc3R5bGVdW2hlaWdodF0gPSAnMHB4JztcbiAgICAgICAgXG4gICAgICAgIGVtdWxhdGVUcmFuc2l0aW9uRW5kKGNvbGxhcHNlRWxlbWVudCwgZnVuY3Rpb24oKSB7XG4gICAgICAgICAgY29sbGFwc2VFbGVtZW50W2lzQW5pbWF0aW5nXSA9IGZhbHNlO1xuICAgICAgICAgIGNvbGxhcHNlRWxlbWVudFtzZXRBdHRyaWJ1dGVdKGFyaWFFeHBhbmRlZCwnZmFsc2UnKTtcbiAgICAgICAgICB0b2dnbGVbc2V0QXR0cmlidXRlXShhcmlhRXhwYW5kZWQsJ2ZhbHNlJyk7XG4gICAgICAgICAgcmVtb3ZlQ2xhc3MoY29sbGFwc2VFbGVtZW50LGNvbGxhcHNpbmcpO1xuICAgICAgICAgIGFkZENsYXNzKGNvbGxhcHNlRWxlbWVudCxjb21wb25lbnQpO1xuICAgICAgICAgIGNvbGxhcHNlRWxlbWVudFtzdHlsZV1baGVpZ2h0XSA9ICcnO1xuICAgICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoY29sbGFwc2VFbGVtZW50LCBoaWRkZW5FdmVudCwgY29tcG9uZW50KTtcbiAgICAgICAgfSk7XG4gICAgICB9LFxuICAgICAgZ2V0VGFyZ2V0ID0gZnVuY3Rpb24oKSB7XG4gICAgICAgIHZhciBocmVmID0gZWxlbWVudC5ocmVmICYmIGVsZW1lbnRbZ2V0QXR0cmlidXRlXSgnaHJlZicpLFxuICAgICAgICAgIHBhcmVudCA9IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhVGFyZ2V0KSxcbiAgICAgICAgICBpZCA9IGhyZWYgfHwgKCBwYXJlbnQgJiYgcGFyZW50LmNoYXJBdCgwKSA9PT0gJyMnICkgJiYgcGFyZW50O1xuICAgICAgICByZXR1cm4gaWQgJiYgcXVlcnlFbGVtZW50KGlkKTtcbiAgICAgIH07XG4gICAgXG4gICAgLy8gcHVibGljIG1ldGhvZHNcbiAgICB0aGlzLnRvZ2dsZSA9IGZ1bmN0aW9uKGUpIHtcbiAgICAgIGVbcHJldmVudERlZmF1bHRdKCk7XG4gICAgICBpZiAoIWhhc0NsYXNzKGNvbGxhcHNlLGluQ2xhc3MpKSB7IHNlbGYuc2hvdygpOyB9IFxuICAgICAgZWxzZSB7IHNlbGYuaGlkZSgpOyB9XG4gICAgfTtcbiAgICB0aGlzLmhpZGUgPSBmdW5jdGlvbigpIHtcbiAgICAgIGlmICggY29sbGFwc2VbaXNBbmltYXRpbmddICkgcmV0dXJuO1xuICAgICAgY2xvc2VBY3Rpb24oY29sbGFwc2UsZWxlbWVudCk7XG4gICAgICBhZGRDbGFzcyhlbGVtZW50LGNvbGxhcHNlZCk7XG4gICAgfTtcbiAgICB0aGlzLnNob3cgPSBmdW5jdGlvbigpIHtcbiAgICAgIGlmICggYWNjb3JkaW9uICkge1xuICAgICAgICBhY3RpdmVDb2xsYXBzZSA9IHF1ZXJ5RWxlbWVudCgnLicrY29tcG9uZW50KycuJytpbkNsYXNzLGFjY29yZGlvbik7XG4gICAgICAgIGFjdGl2ZUVsZW1lbnQgPSBhY3RpdmVDb2xsYXBzZSAmJiAocXVlcnlFbGVtZW50KCdbJytkYXRhVGFyZ2V0Kyc9XCIjJythY3RpdmVDb2xsYXBzZS5pZCsnXCJdJywgYWNjb3JkaW9uKVxuICAgICAgICAgICAgICAgICAgICAgIHx8IHF1ZXJ5RWxlbWVudCgnW2hyZWY9XCIjJythY3RpdmVDb2xsYXBzZS5pZCsnXCJdJyxhY2NvcmRpb24pICk7XG4gICAgICB9XG4gIFxuICAgICAgaWYgKCAhY29sbGFwc2VbaXNBbmltYXRpbmddIHx8IGFjdGl2ZUNvbGxhcHNlICYmICFhY3RpdmVDb2xsYXBzZVtpc0FuaW1hdGluZ10gKSB7XG4gICAgICAgIGlmICggYWN0aXZlRWxlbWVudCAmJiBhY3RpdmVDb2xsYXBzZSAhPT0gY29sbGFwc2UgKSB7XG4gICAgICAgICAgY2xvc2VBY3Rpb24oYWN0aXZlQ29sbGFwc2UsYWN0aXZlRWxlbWVudCk7XG4gICAgICAgICAgYWRkQ2xhc3MoYWN0aXZlRWxlbWVudCxjb2xsYXBzZWQpOyBcbiAgICAgICAgfVxuICAgICAgICBvcGVuQWN0aW9uKGNvbGxhcHNlLGVsZW1lbnQpO1xuICAgICAgICByZW1vdmVDbGFzcyhlbGVtZW50LGNvbGxhcHNlZCk7XG4gICAgICB9XG4gICAgfTtcbiAgXG4gICAgLy8gaW5pdFxuICAgIGlmICggIShzdHJpbmdDb2xsYXBzZSBpbiBlbGVtZW50ICkgKSB7IC8vIHByZXZlbnQgYWRkaW5nIGV2ZW50IGhhbmRsZXJzIHR3aWNlXG4gICAgICBvbihlbGVtZW50LCBjbGlja0V2ZW50LCBzZWxmLnRvZ2dsZSk7XG4gICAgfVxuICAgIGNvbGxhcHNlID0gZ2V0VGFyZ2V0KCk7XG4gICAgY29sbGFwc2VbaXNBbmltYXRpbmddID0gZmFsc2U7ICAvLyB3aGVuIHRydWUgaXQgd2lsbCBwcmV2ZW50IGNsaWNrIGhhbmRsZXJzICBcbiAgICBhY2NvcmRpb24gPSBxdWVyeUVsZW1lbnQob3B0aW9ucy5wYXJlbnQpIHx8IGFjY29yZGlvbkRhdGEgJiYgZ2V0Q2xvc2VzdChlbGVtZW50LCBhY2NvcmRpb25EYXRhKTtcbiAgICBlbGVtZW50W3N0cmluZ0NvbGxhcHNlXSA9IHNlbGY7XG4gIH07XG4gIFxuICAvLyBDT0xMQVBTRSBEQVRBIEFQSVxuICAvLyA9PT09PT09PT09PT09PT09PVxuICBzdXBwb3J0c1twdXNoXSggWyBzdHJpbmdDb2xsYXBzZSwgQ29sbGFwc2UsICdbJytkYXRhVG9nZ2xlKyc9XCJjb2xsYXBzZVwiXScgXSApO1xuICBcbiAgXG4gIC8qIE5hdGl2ZSBKYXZhc2NyaXB0IGZvciBCb290c3RyYXAgMyB8IERyb3Bkb3duXG4gIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0qL1xuICBcbiAgLy8gRFJPUERPV04gREVGSU5JVElPTlxuICAvLyA9PT09PT09PT09PT09PT09PT09XG4gIHZhciBEcm9wZG93biA9IGZ1bmN0aW9uKCBlbGVtZW50LCBvcHRpb24gKSB7XG4gICAgICBcbiAgICAvLyBpbml0aWFsaXphdGlvbiBlbGVtZW50XG4gICAgZWxlbWVudCA9IHF1ZXJ5RWxlbWVudChlbGVtZW50KTtcbiAgXG4gICAgLy8gc2V0IG9wdGlvblxuICAgIHRoaXMucGVyc2lzdCA9IG9wdGlvbiA9PT0gdHJ1ZSB8fCBlbGVtZW50W2dldEF0dHJpYnV0ZV0oJ2RhdGEtcGVyc2lzdCcpID09PSAndHJ1ZScgfHwgZmFsc2U7XG4gIFxuICAgIC8vIGNvbnN0YW50cywgZXZlbnQgdGFyZ2V0cywgc3RyaW5nc1xuICAgIHZhciBzZWxmID0gdGhpcywgY2hpbGRyZW4gPSAnY2hpbGRyZW4nLFxuICAgICAgcGFyZW50ID0gZWxlbWVudFtwYXJlbnROb2RlXSxcbiAgICAgIGNvbXBvbmVudCA9ICdkcm9wZG93bicsIG9wZW4gPSAnb3BlbicsXG4gICAgICByZWxhdGVkVGFyZ2V0ID0gbnVsbCxcbiAgICAgIG1lbnUgPSBxdWVyeUVsZW1lbnQoJy5kcm9wZG93bi1tZW51JywgcGFyZW50KSxcbiAgICAgIG1lbnVJdGVtcyA9IChmdW5jdGlvbigpe1xuICAgICAgICB2YXIgc2V0ID0gbWVudVtjaGlsZHJlbl0sIG5ld1NldCA9IFtdO1xuICAgICAgICBmb3IgKCB2YXIgaT0wOyBpPHNldFtsZW5ndGhdOyBpKysgKXtcbiAgICAgICAgICBzZXRbaV1bY2hpbGRyZW5dW2xlbmd0aF0gJiYgKHNldFtpXVtjaGlsZHJlbl1bMF0udGFnTmFtZSA9PT0gJ0EnICYmIG5ld1NldFtwdXNoXShzZXRbaV0pKTsgICAgICAgICAgXG4gICAgICAgIH1cbiAgICAgICAgcmV0dXJuIG5ld1NldDtcbiAgICAgIH0pKCksXG4gIFxuICAgICAgLy8gcHJldmVudERlZmF1bHQgb24gZW1wdHkgYW5jaG9yIGxpbmtzXG4gICAgICBwcmV2ZW50RW1wdHlBbmNob3IgPSBmdW5jdGlvbihhbmNob3Ipe1xuICAgICAgICAoYW5jaG9yLmhyZWYgJiYgYW5jaG9yLmhyZWYuc2xpY2UoLTEpID09PSAnIycgfHwgYW5jaG9yW3BhcmVudE5vZGVdICYmIGFuY2hvcltwYXJlbnROb2RlXS5ocmVmIFxuICAgICAgICAgICYmIGFuY2hvcltwYXJlbnROb2RlXS5ocmVmLnNsaWNlKC0xKSA9PT0gJyMnKSAmJiB0aGlzW3ByZXZlbnREZWZhdWx0XSgpOyAgICAgIFxuICAgICAgfSxcbiAgXG4gICAgICAvLyB0b2dnbGUgZGlzbWlzc2libGUgZXZlbnRzXG4gICAgICB0b2dnbGVEaXNtaXNzID0gZnVuY3Rpb24oKXtcbiAgICAgICAgdmFyIHR5cGUgPSBlbGVtZW50W29wZW5dID8gb24gOiBvZmY7XG4gICAgICAgIHR5cGUoRE9DLCBjbGlja0V2ZW50LCBkaXNtaXNzSGFuZGxlcik7IFxuICAgICAgICB0eXBlKERPQywga2V5ZG93bkV2ZW50LCBwcmV2ZW50U2Nyb2xsKTtcbiAgICAgICAgdHlwZShET0MsIGtleXVwRXZlbnQsIGtleUhhbmRsZXIpO1xuICAgICAgICB0eXBlKERPQywgZm9jdXNFdmVudCwgZGlzbWlzc0hhbmRsZXIsIHRydWUpO1xuICAgICAgfSxcbiAgXG4gICAgICAvLyBoYW5kbGVyc1xuICAgICAgZGlzbWlzc0hhbmRsZXIgPSBmdW5jdGlvbihlKSB7XG4gICAgICAgIHZhciBldmVudFRhcmdldCA9IGVbdGFyZ2V0XSwgaGFzRGF0YSA9IGV2ZW50VGFyZ2V0ICYmIChldmVudFRhcmdldFtnZXRBdHRyaWJ1dGVdKGRhdGFUb2dnbGUpIFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfHwgZXZlbnRUYXJnZXRbcGFyZW50Tm9kZV0gJiYgZ2V0QXR0cmlidXRlIGluIGV2ZW50VGFyZ2V0W3BhcmVudE5vZGVdIFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgJiYgZXZlbnRUYXJnZXRbcGFyZW50Tm9kZV1bZ2V0QXR0cmlidXRlXShkYXRhVG9nZ2xlKSk7XG4gICAgICAgIGlmICggZS50eXBlID09PSBmb2N1c0V2ZW50ICYmIChldmVudFRhcmdldCA9PT0gZWxlbWVudCB8fCBldmVudFRhcmdldCA9PT0gbWVudSB8fCBtZW51W2NvbnRhaW5zXShldmVudFRhcmdldCkgKSApIHtcbiAgICAgICAgICByZXR1cm47XG4gICAgICAgIH1cbiAgICAgICAgaWYgKCAoZXZlbnRUYXJnZXQgPT09IG1lbnUgfHwgbWVudVtjb250YWluc10oZXZlbnRUYXJnZXQpKSAmJiAoc2VsZi5wZXJzaXN0IHx8IGhhc0RhdGEpICkgeyByZXR1cm47IH1cbiAgICAgICAgZWxzZSB7XG4gICAgICAgICAgcmVsYXRlZFRhcmdldCA9IGV2ZW50VGFyZ2V0ID09PSBlbGVtZW50IHx8IGVsZW1lbnRbY29udGFpbnNdKGV2ZW50VGFyZ2V0KSA/IGVsZW1lbnQgOiBudWxsO1xuICAgICAgICAgIGhpZGUoKTtcbiAgICAgICAgfVxuICAgICAgICBwcmV2ZW50RW1wdHlBbmNob3IuY2FsbChlLGV2ZW50VGFyZ2V0KTtcbiAgICAgIH0sXG4gICAgICBjbGlja0hhbmRsZXIgPSBmdW5jdGlvbihlKSB7XG4gICAgICAgIHJlbGF0ZWRUYXJnZXQgPSBlbGVtZW50O1xuICAgICAgICBzaG93KCk7XG4gICAgICAgIHByZXZlbnRFbXB0eUFuY2hvci5jYWxsKGUsZVt0YXJnZXRdKTtcbiAgICAgIH0sXG4gICAgICBwcmV2ZW50U2Nyb2xsID0gZnVuY3Rpb24oZSl7XG4gICAgICAgIHZhciBrZXkgPSBlLndoaWNoIHx8IGUua2V5Q29kZTtcbiAgICAgICAgaWYoIGtleSA9PT0gMzggfHwga2V5ID09PSA0MCApIHsgZVtwcmV2ZW50RGVmYXVsdF0oKTsgfVxuICAgICAgfSxcbiAgICAgIGtleUhhbmRsZXIgPSBmdW5jdGlvbihlKXtcbiAgICAgICAgdmFyIGtleSA9IGUud2hpY2ggfHwgZS5rZXlDb2RlLCBcbiAgICAgICAgICAgIGFjdGl2ZUl0ZW0gPSBET0MuYWN0aXZlRWxlbWVudCxcbiAgICAgICAgICAgIGlkeCA9IG1lbnVJdGVtc1tpbmRleE9mXShhY3RpdmVJdGVtW3BhcmVudE5vZGVdKSxcbiAgICAgICAgICAgIGlzU2FtZUVsZW1lbnQgPSBhY3RpdmVJdGVtID09PSBlbGVtZW50LFxuICAgICAgICAgICAgaXNJbnNpZGVNZW51ID0gbWVudVtjb250YWluc10oYWN0aXZlSXRlbSksXG4gICAgICAgICAgICBpc01lbnVJdGVtID0gYWN0aXZlSXRlbVtwYXJlbnROb2RlXVtwYXJlbnROb2RlXSA9PT0gbWVudTtcbiAgICAgICAgXG4gICAgICAgIGlmICggaXNNZW51SXRlbSApIHsgLy8gbmF2aWdhdGUgdXAgfCBkb3duXG4gICAgICAgICAgaWR4ID0gaXNTYW1lRWxlbWVudCA/IDAgXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICA6IGtleSA9PT0gMzggPyAoaWR4PjE/aWR4LTE6MCkgXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICA6IGtleSA9PT0gNDAgPyAoaWR4PG1lbnVJdGVtc1tsZW5ndGhdLTE/aWR4KzE6aWR4KSA6IGlkeDtcbiAgICAgICAgICBtZW51SXRlbXNbaWR4XSAmJiBzZXRGb2N1cyhtZW51SXRlbXNbaWR4XVtjaGlsZHJlbl1bMF0pO1xuICAgICAgICB9XG4gICAgICAgIGlmICggKG1lbnVJdGVtc1tsZW5ndGhdICYmIGlzTWVudUl0ZW0gLy8gbWVudSBoYXMgaXRlbXNcbiAgICAgICAgICB8fCAhbWVudUl0ZW1zW2xlbmd0aF0gJiYgKGlzSW5zaWRlTWVudSB8fCBpc1NhbWVFbGVtZW50KSAgLy8gbWVudSBtaWdodCBiZSBhIGZvcm1cbiAgICAgICAgICB8fCAhaXNJbnNpZGVNZW51ICkgLy8gb3IgdGhlIGZvY3VzZWQgZWxlbWVudCBpcyBub3QgaW4gdGhlIG1lbnUgYXQgYWxsXG4gICAgICAgICAgJiYgZWxlbWVudFtvcGVuXSAmJiBrZXkgPT09IDI3IC8vIG1lbnUgbXVzdCBiZSBvcGVuXG4gICAgICAgICkge1xuICAgICAgICAgIHNlbGYudG9nZ2xlKCk7XG4gICAgICAgICAgcmVsYXRlZFRhcmdldCA9IG51bGw7XG4gICAgICAgIH1cbiAgICAgIH0sICBcbiAgXG4gICAgICAvLyBwcml2YXRlIG1ldGhvZHNcbiAgICAgIHNob3cgPSBmdW5jdGlvbigpIHtcbiAgICAgICAgYm9vdHN0cmFwQ3VzdG9tRXZlbnQuY2FsbChwYXJlbnQsIHNob3dFdmVudCwgY29tcG9uZW50LCByZWxhdGVkVGFyZ2V0KTtcbiAgICAgICAgYWRkQ2xhc3MocGFyZW50LG9wZW4pO1xuICAgICAgICBlbGVtZW50W3NldEF0dHJpYnV0ZV0oYXJpYUV4cGFuZGVkLHRydWUpO1xuICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKHBhcmVudCwgc2hvd25FdmVudCwgY29tcG9uZW50LCByZWxhdGVkVGFyZ2V0KTtcbiAgICAgICAgZWxlbWVudFtvcGVuXSA9IHRydWU7XG4gICAgICAgIG9mZihlbGVtZW50LCBjbGlja0V2ZW50LCBjbGlja0hhbmRsZXIpO1xuICAgICAgICBzZXRUaW1lb3V0KGZ1bmN0aW9uKCl7IFxuICAgICAgICAgIHNldEZvY3VzKCBtZW51W2dldEVsZW1lbnRzQnlUYWdOYW1lXSgnSU5QVVQnKVswXSB8fCBlbGVtZW50ICk7IC8vIGZvY3VzIHRoZSBmaXJzdCBpbnB1dCBpdGVtIHwgZWxlbWVudFxuICAgICAgICAgIHRvZ2dsZURpc21pc3MoKTsgXG4gICAgICAgIH0sMSk7XG4gICAgICB9LFxuICAgICAgaGlkZSA9IGZ1bmN0aW9uKCkge1xuICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKHBhcmVudCwgaGlkZUV2ZW50LCBjb21wb25lbnQsIHJlbGF0ZWRUYXJnZXQpO1xuICAgICAgICByZW1vdmVDbGFzcyhwYXJlbnQsb3Blbik7XG4gICAgICAgIGVsZW1lbnRbc2V0QXR0cmlidXRlXShhcmlhRXhwYW5kZWQsZmFsc2UpO1xuICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKHBhcmVudCwgaGlkZGVuRXZlbnQsIGNvbXBvbmVudCwgcmVsYXRlZFRhcmdldCk7XG4gICAgICAgIGVsZW1lbnRbb3Blbl0gPSBmYWxzZTtcbiAgICAgICAgdG9nZ2xlRGlzbWlzcygpO1xuICAgICAgICBzZXRGb2N1cyhlbGVtZW50KTtcbiAgICAgICAgc2V0VGltZW91dChmdW5jdGlvbigpeyBvbihlbGVtZW50LCBjbGlja0V2ZW50LCBjbGlja0hhbmRsZXIpOyB9LDEpO1xuICAgICAgfTtcbiAgXG4gICAgLy8gc2V0IGluaXRpYWwgc3RhdGUgdG8gY2xvc2VkXG4gICAgZWxlbWVudFtvcGVuXSA9IGZhbHNlO1xuICBcbiAgICAvLyBwdWJsaWMgbWV0aG9kc1xuICAgIHRoaXMudG9nZ2xlID0gZnVuY3Rpb24oKSB7XG4gICAgICBpZiAoaGFzQ2xhc3MocGFyZW50LG9wZW4pICYmIGVsZW1lbnRbb3Blbl0pIHsgaGlkZSgpOyB9IFxuICAgICAgZWxzZSB7IHNob3coKTsgfVxuICAgIH07XG4gIFxuICAgIC8vIGluaXRcbiAgICBpZiAoIShzdHJpbmdEcm9wZG93biBpbiBlbGVtZW50KSkgeyAvLyBwcmV2ZW50IGFkZGluZyBldmVudCBoYW5kbGVycyB0d2ljZVxuICAgICAgIXRhYmluZGV4IGluIG1lbnUgJiYgbWVudVtzZXRBdHRyaWJ1dGVdKHRhYmluZGV4LCAnMCcpOyAvLyBGaXggb25ibHVyIG9uIENocm9tZSB8IFNhZmFyaVxuICAgICAgb24oZWxlbWVudCwgY2xpY2tFdmVudCwgY2xpY2tIYW5kbGVyKTtcbiAgICB9XG4gIFxuICAgIGVsZW1lbnRbc3RyaW5nRHJvcGRvd25dID0gc2VsZjtcbiAgfTtcbiAgXG4gIC8vIERST1BET1dOIERBVEEgQVBJXG4gIC8vID09PT09PT09PT09PT09PT09XG4gIHN1cHBvcnRzW3B1c2hdKCBbc3RyaW5nRHJvcGRvd24sIERyb3Bkb3duLCAnWycrZGF0YVRvZ2dsZSsnPVwiZHJvcGRvd25cIl0nXSApO1xuICBcbiAgXG4gIC8qIE5hdGl2ZSBKYXZhc2NyaXB0IGZvciBCb290c3RyYXAgMyB8IE1vZGFsXG4gIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0qL1xuICBcbiAgLy8gTU9EQUwgREVGSU5JVElPTlxuICAvLyA9PT09PT09PT09PT09PT1cbiAgdmFyIE1vZGFsID0gZnVuY3Rpb24oZWxlbWVudCwgb3B0aW9ucykgeyAvLyBlbGVtZW50IGNhbiBiZSB0aGUgbW9kYWwvdHJpZ2dlcmluZyBidXR0b25cbiAgXG4gICAgLy8gdGhlIG1vZGFsIChib3RoIEphdmFTY3JpcHQgLyBEQVRBIEFQSSBpbml0KSAvIHRyaWdnZXJpbmcgYnV0dG9uIGVsZW1lbnQgKERBVEEgQVBJKVxuICAgIGVsZW1lbnQgPSBxdWVyeUVsZW1lbnQoZWxlbWVudCk7XG4gIFxuICAgICAgLy8gc3RyaW5nc1xuICAgICAgdmFyIGNvbXBvbmVudCA9ICdtb2RhbCcsXG4gICAgICAgIHN0YXRpY1N0cmluZyA9ICdzdGF0aWMnLFxuICAgICAgICBtb2RhbFRyaWdnZXIgPSAnbW9kYWxUcmlnZ2VyJyxcbiAgICAgICAgcGFkZGluZ1JpZ2h0ID0gJ3BhZGRpbmdSaWdodCcsXG4gICAgICAgIG1vZGFsQmFja2Ryb3BTdHJpbmcgPSAnbW9kYWwtYmFja2Ryb3AnLFxuICAgICAgICBpc0FuaW1hdGluZyA9ICdpc0FuaW1hdGluZycsXG4gICAgICAgIC8vIGRldGVybWluZSBtb2RhbCwgdHJpZ2dlcmluZyBlbGVtZW50XG4gICAgICAgIGJ0bkNoZWNrID0gZWxlbWVudFtnZXRBdHRyaWJ1dGVdKGRhdGFUYXJnZXQpfHxlbGVtZW50W2dldEF0dHJpYnV0ZV0oJ2hyZWYnKSxcbiAgICAgICAgY2hlY2tNb2RhbCA9IHF1ZXJ5RWxlbWVudCggYnRuQ2hlY2sgKSxcbiAgICAgICAgbW9kYWwgPSBoYXNDbGFzcyhlbGVtZW50LGNvbXBvbmVudCkgPyBlbGVtZW50IDogY2hlY2tNb2RhbDtcbiAgXG4gICAgICBpZiAoIGhhc0NsYXNzKGVsZW1lbnQsIGNvbXBvbmVudCkgKSB7IGVsZW1lbnQgPSBudWxsOyB9IC8vIG1vZGFsIGlzIG5vdyBpbmRlcGVuZGVudCBvZiBpdCdzIHRyaWdnZXJpbmcgZWxlbWVudFxuICBcbiAgICBpZiAoICFtb2RhbCApIHsgcmV0dXJuOyB9IC8vIGludmFsaWRhdGVcbiAgXG4gICAgLy8gc2V0IG9wdGlvbnNcbiAgICBvcHRpb25zID0gb3B0aW9ucyB8fCB7fTtcbiAgXG4gICAgdGhpc1trZXlib2FyZF0gPSBvcHRpb25zW2tleWJvYXJkXSA9PT0gZmFsc2UgfHwgbW9kYWxbZ2V0QXR0cmlidXRlXShkYXRhS2V5Ym9hcmQpID09PSAnZmFsc2UnID8gZmFsc2UgOiB0cnVlO1xuICAgIHRoaXNbYmFja2Ryb3BdID0gb3B0aW9uc1tiYWNrZHJvcF0gPT09IHN0YXRpY1N0cmluZyB8fCBtb2RhbFtnZXRBdHRyaWJ1dGVdKGRhdGFiYWNrZHJvcCkgPT09IHN0YXRpY1N0cmluZyA/IHN0YXRpY1N0cmluZyA6IHRydWU7XG4gICAgdGhpc1tiYWNrZHJvcF0gPSBvcHRpb25zW2JhY2tkcm9wXSA9PT0gZmFsc2UgfHwgbW9kYWxbZ2V0QXR0cmlidXRlXShkYXRhYmFja2Ryb3ApID09PSAnZmFsc2UnID8gZmFsc2UgOiB0aGlzW2JhY2tkcm9wXTtcbiAgICB0aGlzW2FuaW1hdGlvbl0gPSBoYXNDbGFzcyhtb2RhbCwgJ2ZhZGUnKSA/IHRydWUgOiBmYWxzZTtcbiAgICB0aGlzW2NvbnRlbnRdICA9IG9wdGlvbnNbY29udGVudF07IC8vIEphdmFTY3JpcHQgb25seVxuICBcbiAgICAvLyBzZXQgYW4gaW5pdGlhbCBzdGF0ZSBvZiB0aGUgbW9kYWxcbiAgICBtb2RhbFtpc0FuaW1hdGluZ10gPSBmYWxzZTtcbiAgICBcbiAgICAvLyBiaW5kLCBjb25zdGFudHMsIGV2ZW50IHRhcmdldHMgYW5kIG90aGVyIHZhcnNcbiAgICB2YXIgc2VsZiA9IHRoaXMsIHJlbGF0ZWRUYXJnZXQgPSBudWxsLFxuICAgICAgYm9keUlzT3ZlcmZsb3dpbmcsIHNjcm9sbEJhcldpZHRoLCBvdmVybGF5LCBvdmVybGF5RGVsYXksIG1vZGFsVGltZXIsXG4gIFxuICAgICAgLy8gYWxzbyBmaW5kIGZpeGVkLXRvcCAvIGZpeGVkLWJvdHRvbSBpdGVtc1xuICAgICAgZml4ZWRJdGVtcyA9IGdldEVsZW1lbnRzQnlDbGFzc05hbWUoSFRNTCxmaXhlZFRvcCkuY29uY2F0KGdldEVsZW1lbnRzQnlDbGFzc05hbWUoSFRNTCxmaXhlZEJvdHRvbSkpLFxuICBcbiAgICAgIC8vIHByaXZhdGUgbWV0aG9kc1xuICAgICAgZ2V0V2luZG93V2lkdGggPSBmdW5jdGlvbigpIHtcbiAgICAgICAgdmFyIGh0bWxSZWN0ID0gSFRNTFtnZXRCb3VuZGluZ0NsaWVudFJlY3RdKCk7XG4gICAgICAgIHJldHVybiBnbG9iYWxPYmplY3RbaW5uZXJXaWR0aF0gfHwgKGh0bWxSZWN0W3JpZ2h0XSAtIE1hdGguYWJzKGh0bWxSZWN0W2xlZnRdKSk7XG4gICAgICB9LFxuICAgICAgc2V0U2Nyb2xsYmFyID0gZnVuY3Rpb24gKCkge1xuICAgICAgICB2YXIgYm9keVN0eWxlID0gRE9DW2JvZHldLmN1cnJlbnRTdHlsZSB8fCBnbG9iYWxPYmplY3RbZ2V0Q29tcHV0ZWRTdHlsZV0oRE9DW2JvZHldKSxcbiAgICAgICAgICAgIGJvZHlQYWQgPSBwYXJzZUludCgoYm9keVN0eWxlW3BhZGRpbmdSaWdodF0pLCAxMCksIGl0ZW1QYWQ7XG4gICAgICAgIGlmIChib2R5SXNPdmVyZmxvd2luZykge1xuICAgICAgICAgIERPQ1tib2R5XVtzdHlsZV1bcGFkZGluZ1JpZ2h0XSA9IChib2R5UGFkICsgc2Nyb2xsQmFyV2lkdGgpICsgJ3B4JztcbiAgICAgICAgICBtb2RhbFtzdHlsZV1bcGFkZGluZ1JpZ2h0XSA9IHNjcm9sbEJhcldpZHRoKydweCc7XG4gICAgICAgICAgaWYgKGZpeGVkSXRlbXNbbGVuZ3RoXSl7XG4gICAgICAgICAgICBmb3IgKHZhciBpID0gMDsgaSA8IGZpeGVkSXRlbXNbbGVuZ3RoXTsgaSsrKSB7XG4gICAgICAgICAgICAgIGl0ZW1QYWQgPSAoZml4ZWRJdGVtc1tpXS5jdXJyZW50U3R5bGUgfHwgZ2xvYmFsT2JqZWN0W2dldENvbXB1dGVkU3R5bGVdKGZpeGVkSXRlbXNbaV0pKVtwYWRkaW5nUmlnaHRdO1xuICAgICAgICAgICAgICBmaXhlZEl0ZW1zW2ldW3N0eWxlXVtwYWRkaW5nUmlnaHRdID0gKCBwYXJzZUludChpdGVtUGFkKSArIHNjcm9sbEJhcldpZHRoKSArICdweCc7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgfVxuICAgICAgICB9XG4gICAgICB9LFxuICAgICAgcmVzZXRTY3JvbGxiYXIgPSBmdW5jdGlvbiAoKSB7XG4gICAgICAgIERPQ1tib2R5XVtzdHlsZV1bcGFkZGluZ1JpZ2h0XSA9ICcnO1xuICAgICAgICBtb2RhbFtzdHlsZV1bcGFkZGluZ1JpZ2h0XSA9ICcnO1xuICAgICAgICBpZiAoZml4ZWRJdGVtc1tsZW5ndGhdKXtcbiAgICAgICAgICBmb3IgKHZhciBpID0gMDsgaSA8IGZpeGVkSXRlbXNbbGVuZ3RoXTsgaSsrKSB7XG4gICAgICAgICAgICBmaXhlZEl0ZW1zW2ldW3N0eWxlXVtwYWRkaW5nUmlnaHRdID0gJyc7XG4gICAgICAgICAgfVxuICAgICAgICB9XG4gICAgICB9LFxuICAgICAgbWVhc3VyZVNjcm9sbGJhciA9IGZ1bmN0aW9uICgpIHsgLy8gdGh4IHdhbHNoXG4gICAgICAgIHZhciBzY3JvbGxEaXYgPSBET0NbY3JlYXRlRWxlbWVudF0oJ2RpdicpLCB3aWR0aFZhbHVlO1xuICAgICAgICBzY3JvbGxEaXYuY2xhc3NOYW1lID0gY29tcG9uZW50Kyctc2Nyb2xsYmFyLW1lYXN1cmUnOyAvLyB0aGlzIGlzIGhlcmUgdG8gc3RheVxuICAgICAgICBET0NbYm9keV1bYXBwZW5kQ2hpbGRdKHNjcm9sbERpdik7XG4gICAgICAgIHdpZHRoVmFsdWUgPSBzY3JvbGxEaXZbb2Zmc2V0V2lkdGhdIC0gc2Nyb2xsRGl2W2NsaWVudFdpZHRoXTtcbiAgICAgICAgRE9DW2JvZHldLnJlbW92ZUNoaWxkKHNjcm9sbERpdik7XG4gICAgICAgIHJldHVybiB3aWR0aFZhbHVlO1xuICAgICAgfSxcbiAgICAgIGNoZWNrU2Nyb2xsYmFyID0gZnVuY3Rpb24gKCkge1xuICAgICAgICBib2R5SXNPdmVyZmxvd2luZyA9IERPQ1tib2R5XVtjbGllbnRXaWR0aF0gPCBnZXRXaW5kb3dXaWR0aCgpO1xuICAgICAgICBzY3JvbGxCYXJXaWR0aCA9IG1lYXN1cmVTY3JvbGxiYXIoKTtcbiAgICAgIH0sXG4gICAgICBjcmVhdGVPdmVybGF5ID0gZnVuY3Rpb24oKSB7XG4gICAgICAgIHZhciBuZXdPdmVybGF5ID0gRE9DW2NyZWF0ZUVsZW1lbnRdKCdkaXYnKTtcbiAgICAgICAgb3ZlcmxheSA9IHF1ZXJ5RWxlbWVudCgnLicrbW9kYWxCYWNrZHJvcFN0cmluZyk7XG4gIFxuICAgICAgICBpZiAoIG92ZXJsYXkgPT09IG51bGwgKSB7XG4gICAgICAgICAgbmV3T3ZlcmxheVtzZXRBdHRyaWJ1dGVdKCdjbGFzcycsIG1vZGFsQmFja2Ryb3BTdHJpbmcgKyAoc2VsZlthbmltYXRpb25dID8gJyBmYWRlJyA6ICcnKSk7XG4gICAgICAgICAgb3ZlcmxheSA9IG5ld092ZXJsYXk7XG4gICAgICAgICAgRE9DW2JvZHldW2FwcGVuZENoaWxkXShvdmVybGF5KTtcbiAgICAgICAgfVxuICAgICAgICBtb2RhbE92ZXJsYXkgPSAxO1xuICAgICAgfSxcbiAgICAgIHJlbW92ZU92ZXJsYXkgPSBmdW5jdGlvbigpIHtcbiAgICAgICAgb3ZlcmxheSA9IHF1ZXJ5RWxlbWVudCgnLicrbW9kYWxCYWNrZHJvcFN0cmluZyk7XG4gICAgICAgIGlmICggb3ZlcmxheSAmJiBvdmVybGF5ICE9PSBudWxsICYmIHR5cGVvZiBvdmVybGF5ID09PSAnb2JqZWN0JyApIHtcbiAgICAgICAgICBtb2RhbE92ZXJsYXkgPSAwO1xuICAgICAgICAgIERPQ1tib2R5XS5yZW1vdmVDaGlsZChvdmVybGF5KTsgb3ZlcmxheSA9IG51bGw7XG4gICAgICAgIH0gICAgXG4gICAgICB9LFxuICAgICAgLy8gdHJpZ2dlcnNcbiAgICAgIHRyaWdnZXJTaG93ID0gZnVuY3Rpb24oKSB7XG4gICAgICAgIHNldEZvY3VzKG1vZGFsKTtcbiAgICAgICAgbW9kYWxbaXNBbmltYXRpbmddID0gZmFsc2U7XG4gICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwobW9kYWwsIHNob3duRXZlbnQsIGNvbXBvbmVudCwgcmVsYXRlZFRhcmdldCk7XG4gIFxuICAgICAgICBvbihnbG9iYWxPYmplY3QsIHJlc2l6ZUV2ZW50LCBzZWxmLnVwZGF0ZSwgcGFzc2l2ZUhhbmRsZXIpO1xuICAgICAgICBvbihtb2RhbCwgY2xpY2tFdmVudCwgZGlzbWlzc0hhbmRsZXIpO1xuICAgICAgICBvbihET0MsIGtleWRvd25FdmVudCwga2V5SGFuZGxlcik7ICAgICAgXG4gICAgICB9LFxuICAgICAgdHJpZ2dlckhpZGUgPSBmdW5jdGlvbigpIHtcbiAgICAgICAgbW9kYWxbc3R5bGVdLmRpc3BsYXkgPSAnJztcbiAgICAgICAgZWxlbWVudCAmJiAoc2V0Rm9jdXMoZWxlbWVudCkpO1xuICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKG1vZGFsLCBoaWRkZW5FdmVudCwgY29tcG9uZW50KTtcbiAgXG4gICAgICAgIChmdW5jdGlvbigpe1xuICAgICAgICAgIGlmICghZ2V0RWxlbWVudHNCeUNsYXNzTmFtZShET0MsY29tcG9uZW50KycgJytpbkNsYXNzKVswXSkge1xuICAgICAgICAgICAgcmVzZXRTY3JvbGxiYXIoKTtcbiAgICAgICAgICAgIHJlbW92ZUNsYXNzKERPQ1tib2R5XSxjb21wb25lbnQrJy1vcGVuJyk7XG4gICAgICAgICAgICBvdmVybGF5ICYmIGhhc0NsYXNzKG92ZXJsYXksJ2ZhZGUnKSA/IChyZW1vdmVDbGFzcyhvdmVybGF5LGluQ2xhc3MpLCBlbXVsYXRlVHJhbnNpdGlvbkVuZChvdmVybGF5LHJlbW92ZU92ZXJsYXkpKVxuICAgICAgICAgICAgOiByZW1vdmVPdmVybGF5KCk7XG4gIFxuICAgICAgICAgICAgb2ZmKGdsb2JhbE9iamVjdCwgcmVzaXplRXZlbnQsIHNlbGYudXBkYXRlLCBwYXNzaXZlSGFuZGxlcik7XG4gICAgICAgICAgICBvZmYobW9kYWwsIGNsaWNrRXZlbnQsIGRpc21pc3NIYW5kbGVyKTtcbiAgICAgICAgICAgIG9mZihET0MsIGtleWRvd25FdmVudCwga2V5SGFuZGxlcik7ICAgIFxuICAgICAgICAgIH1cbiAgICAgICAgfSgpKTtcbiAgICAgICAgbW9kYWxbaXNBbmltYXRpbmddID0gZmFsc2U7XG4gICAgICB9LFxuICAgICAgLy8gaGFuZGxlcnNcbiAgICAgIGNsaWNrSGFuZGxlciA9IGZ1bmN0aW9uKGUpIHtcbiAgICAgICAgaWYgKCBtb2RhbFtpc0FuaW1hdGluZ10gKSByZXR1cm47XG4gIFxuICAgICAgICB2YXIgY2xpY2tUYXJnZXQgPSBlW3RhcmdldF07XG4gICAgICAgIGNsaWNrVGFyZ2V0ID0gY2xpY2tUYXJnZXRbaGFzQXR0cmlidXRlXShkYXRhVGFyZ2V0KSB8fCBjbGlja1RhcmdldFtoYXNBdHRyaWJ1dGVdKCdocmVmJykgPyBjbGlja1RhcmdldCA6IGNsaWNrVGFyZ2V0W3BhcmVudE5vZGVdO1xuICAgICAgICBpZiAoIGNsaWNrVGFyZ2V0ID09PSBlbGVtZW50ICYmICFoYXNDbGFzcyhtb2RhbCxpbkNsYXNzKSApIHtcbiAgICAgICAgICBtb2RhbFttb2RhbFRyaWdnZXJdID0gZWxlbWVudDtcbiAgICAgICAgICByZWxhdGVkVGFyZ2V0ID0gZWxlbWVudDtcbiAgICAgICAgICBzZWxmLnNob3coKTtcbiAgICAgICAgICBlW3ByZXZlbnREZWZhdWx0XSgpO1xuICAgICAgICB9XG4gICAgICB9LFxuICAgICAga2V5SGFuZGxlciA9IGZ1bmN0aW9uKGUpIHtcbiAgICAgICAgaWYgKCBtb2RhbFtpc0FuaW1hdGluZ10gKSByZXR1cm47XG4gIFxuICAgICAgICB2YXIga2V5ID0gZS53aGljaCB8fCBlLmtleUNvZGU7IC8vIGtleUNvZGUgZm9yIElFOFxuICAgICAgICBpZiAoc2VsZltrZXlib2FyZF0gJiYga2V5ID09IDI3ICYmIGhhc0NsYXNzKG1vZGFsLGluQ2xhc3MpKSB7XG4gICAgICAgICAgc2VsZi5oaWRlKCk7XG4gICAgICAgIH1cbiAgICAgIH0sXG4gICAgICBkaXNtaXNzSGFuZGxlciA9IGZ1bmN0aW9uKGUpIHtcbiAgICAgICAgaWYgKCBtb2RhbFtpc0FuaW1hdGluZ10gKSByZXR1cm47XG4gIFxuICAgICAgICB2YXIgY2xpY2tUYXJnZXQgPSBlW3RhcmdldF07XG4gICAgICAgIGlmICggaGFzQ2xhc3MobW9kYWwsaW5DbGFzcykgJiYgKGNsaWNrVGFyZ2V0W3BhcmVudE5vZGVdW2dldEF0dHJpYnV0ZV0oZGF0YURpc21pc3MpID09PSBjb21wb25lbnRcbiAgICAgICAgICAgIHx8IGNsaWNrVGFyZ2V0W2dldEF0dHJpYnV0ZV0oZGF0YURpc21pc3MpID09PSBjb21wb25lbnRcbiAgICAgICAgICAgIHx8IGNsaWNrVGFyZ2V0ID09PSBtb2RhbCAmJiBzZWxmW2JhY2tkcm9wXSAhPT0gc3RhdGljU3RyaW5nKSApIHtcbiAgICAgICAgICBzZWxmLmhpZGUoKTsgcmVsYXRlZFRhcmdldCA9IG51bGw7XG4gICAgICAgICAgZVtwcmV2ZW50RGVmYXVsdF0oKTtcbiAgICAgICAgfVxuICAgICAgfTtcbiAgXG4gICAgLy8gcHVibGljIG1ldGhvZHNcbiAgICB0aGlzLnRvZ2dsZSA9IGZ1bmN0aW9uKCkge1xuICAgICAgaWYgKCBoYXNDbGFzcyhtb2RhbCxpbkNsYXNzKSApIHt0aGlzLmhpZGUoKTt9IGVsc2Uge3RoaXMuc2hvdygpO31cbiAgICB9O1xuICAgIHRoaXMuc2hvdyA9IGZ1bmN0aW9uKCkge1xuICAgICAgaWYgKCBoYXNDbGFzcyhtb2RhbCxpbkNsYXNzKSB8fCBtb2RhbFtpc0FuaW1hdGluZ10gKSB7cmV0dXJufVxuICBcbiAgICAgIGNsZWFyVGltZW91dChtb2RhbFRpbWVyKTtcbiAgICAgIG1vZGFsVGltZXIgPSBzZXRUaW1lb3V0KGZ1bmN0aW9uKCl7XG4gICAgICAgIG1vZGFsW2lzQW5pbWF0aW5nXSA9IHRydWU7ICAgIFxuICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKG1vZGFsLCBzaG93RXZlbnQsIGNvbXBvbmVudCwgcmVsYXRlZFRhcmdldCk7XG4gIFxuICAgICAgICAvLyB3ZSBlbGVnYW50bHkgaGlkZSBhbnkgb3BlbmVkIG1vZGFsXG4gICAgICAgIHZhciBjdXJyZW50T3BlbiA9IGdldEVsZW1lbnRzQnlDbGFzc05hbWUoRE9DLGNvbXBvbmVudCsnIGluJylbMF07XG4gICAgICAgIGlmIChjdXJyZW50T3BlbiAmJiBjdXJyZW50T3BlbiAhPT0gbW9kYWwpIHtcbiAgICAgICAgICBtb2RhbFRyaWdnZXIgaW4gY3VycmVudE9wZW4gJiYgY3VycmVudE9wZW5bbW9kYWxUcmlnZ2VyXVtzdHJpbmdNb2RhbF0uaGlkZSgpO1xuICAgICAgICAgIHN0cmluZ01vZGFsIGluIGN1cnJlbnRPcGVuICYmIGN1cnJlbnRPcGVuW3N0cmluZ01vZGFsXS5oaWRlKCk7XG4gICAgICAgIH1cbiAgXG4gICAgICAgIGlmICggc2VsZltiYWNrZHJvcF0gKSB7XG4gICAgICAgICAgIW1vZGFsT3ZlcmxheSAmJiAhb3ZlcmxheSAmJiBjcmVhdGVPdmVybGF5KCk7XG4gICAgICAgIH1cbiAgXG4gICAgICAgIGlmICggb3ZlcmxheSAmJiAhaGFzQ2xhc3Mob3ZlcmxheSxpbkNsYXNzKSkge1xuICAgICAgICAgIG92ZXJsYXlbb2Zmc2V0V2lkdGhdOyAvLyBmb3JjZSByZWZsb3cgdG8gZW5hYmxlIHRyYXNpdGlvblxuICAgICAgICAgIG92ZXJsYXlEZWxheSA9IGdldFRyYW5zaXRpb25EdXJhdGlvbkZyb21FbGVtZW50KG92ZXJsYXkpO1xuICAgICAgICAgIGFkZENsYXNzKG92ZXJsYXksaW5DbGFzcyk7XG4gICAgICAgIH1cbiAgXG4gICAgICAgIHNldFRpbWVvdXQoIGZ1bmN0aW9uKCkge1xuICAgICAgICAgIG1vZGFsW3N0eWxlXS5kaXNwbGF5ID0gJ2Jsb2NrJztcbiAgXG4gICAgICAgICAgY2hlY2tTY3JvbGxiYXIoKTtcbiAgICAgICAgICBzZXRTY3JvbGxiYXIoKTtcbiAgXG4gICAgICAgICAgYWRkQ2xhc3MoRE9DW2JvZHldLGNvbXBvbmVudCsnLW9wZW4nKTtcbiAgICAgICAgICBhZGRDbGFzcyhtb2RhbCxpbkNsYXNzKTtcbiAgICAgICAgICBtb2RhbFtzZXRBdHRyaWJ1dGVdKGFyaWFIaWRkZW4sIGZhbHNlKTtcbiAgXG4gICAgICAgICAgaGFzQ2xhc3MobW9kYWwsJ2ZhZGUnKSA/IGVtdWxhdGVUcmFuc2l0aW9uRW5kKG1vZGFsLCB0cmlnZ2VyU2hvdykgOiB0cmlnZ2VyU2hvdygpO1xuICAgICAgICB9LCBzdXBwb3J0VHJhbnNpdGlvbnMgJiYgb3ZlcmxheSAmJiBvdmVybGF5RGVsYXkgPyBvdmVybGF5RGVsYXkgOiAxKTtcbiAgICAgIH0sMSk7XG4gICAgfTtcbiAgICB0aGlzLmhpZGUgPSBmdW5jdGlvbigpIHtcbiAgICAgIGlmICggbW9kYWxbaXNBbmltYXRpbmddIHx8ICFoYXNDbGFzcyhtb2RhbCxpbkNsYXNzKSApIHtyZXR1cm59XG4gIFxuICAgICAgY2xlYXJUaW1lb3V0KG1vZGFsVGltZXIpO1xuICAgICAgbW9kYWxUaW1lciA9IHNldFRpbWVvdXQoZnVuY3Rpb24oKXtcbiAgICAgICAgbW9kYWxbaXNBbmltYXRpbmddID0gdHJ1ZTtcbiAgICAgICAgYm9vdHN0cmFwQ3VzdG9tRXZlbnQuY2FsbChtb2RhbCwgaGlkZUV2ZW50LCBjb21wb25lbnQpO1xuICAgICAgICBvdmVybGF5ID0gcXVlcnlFbGVtZW50KCcuJyttb2RhbEJhY2tkcm9wU3RyaW5nKTtcbiAgICAgICAgb3ZlcmxheURlbGF5ID0gb3ZlcmxheSAmJiBnZXRUcmFuc2l0aW9uRHVyYXRpb25Gcm9tRWxlbWVudChvdmVybGF5KTtcbiAgXG4gICAgICAgIHJlbW92ZUNsYXNzKG1vZGFsLGluQ2xhc3MpO1xuICAgICAgICBtb2RhbFtzZXRBdHRyaWJ1dGVdKGFyaWFIaWRkZW4sIHRydWUpO1xuICBcbiAgICAgICAgc2V0VGltZW91dChmdW5jdGlvbigpe1xuICAgICAgICAgIGhhc0NsYXNzKG1vZGFsLCdmYWRlJykgPyBlbXVsYXRlVHJhbnNpdGlvbkVuZChtb2RhbCwgdHJpZ2dlckhpZGUpIDogdHJpZ2dlckhpZGUoKTtcbiAgICAgICAgfSwgc3VwcG9ydFRyYW5zaXRpb25zICYmIG92ZXJsYXkgJiYgb3ZlcmxheURlbGF5ID8gb3ZlcmxheURlbGF5IDogMik7XG4gICAgICB9LDIpXG4gICAgfTtcbiAgICB0aGlzLnNldENvbnRlbnQgPSBmdW5jdGlvbiggY29udGVudCApIHtcbiAgICAgIHF1ZXJ5RWxlbWVudCgnLicrY29tcG9uZW50KyctY29udGVudCcsbW9kYWwpW2lubmVySFRNTF0gPSBjb250ZW50O1xuICAgIH07XG4gICAgdGhpcy51cGRhdGUgPSBmdW5jdGlvbigpIHtcbiAgICAgIGlmIChoYXNDbGFzcyhtb2RhbCxpbkNsYXNzKSkge1xuICAgICAgICBjaGVja1Njcm9sbGJhcigpO1xuICAgICAgICBzZXRTY3JvbGxiYXIoKTtcbiAgICAgIH1cbiAgICB9O1xuICBcbiAgICAvLyBpbml0XG4gICAgLy8gcHJldmVudCBhZGRpbmcgZXZlbnQgaGFuZGxlcnMgb3ZlciBhbmQgb3ZlclxuICAgIC8vIG1vZGFsIGlzIGluZGVwZW5kZW50IG9mIGEgdHJpZ2dlcmluZyBlbGVtZW50XG4gICAgaWYgKCAhIWVsZW1lbnQgJiYgIShzdHJpbmdNb2RhbCBpbiBlbGVtZW50KSApIHtcbiAgICAgIG9uKGVsZW1lbnQsIGNsaWNrRXZlbnQsIGNsaWNrSGFuZGxlcik7XG4gICAgfVxuICAgIGlmICggISFzZWxmW2NvbnRlbnRdICkgeyBzZWxmLnNldENvbnRlbnQoIHNlbGZbY29udGVudF0gKTsgfVxuICAgIGlmIChlbGVtZW50KSB7IGVsZW1lbnRbc3RyaW5nTW9kYWxdID0gc2VsZjsgbW9kYWxbbW9kYWxUcmlnZ2VyXSA9IGVsZW1lbnQ7IH1cbiAgICBlbHNlIHsgbW9kYWxbc3RyaW5nTW9kYWxdID0gc2VsZjsgfVxuICB9O1xuICBcbiAgLy8gREFUQSBBUElcbiAgc3VwcG9ydHNbcHVzaF0oIFsgc3RyaW5nTW9kYWwsIE1vZGFsLCAnWycrZGF0YVRvZ2dsZSsnPVwibW9kYWxcIl0nIF0gKTtcbiAgXG4gIC8qIE5hdGl2ZSBKYXZhc2NyaXB0IGZvciBCb290c3RyYXAgMyB8IFBvcG92ZXJcbiAgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSovXG4gIFxuICAvLyBQT1BPVkVSIERFRklOSVRJT05cbiAgLy8gPT09PT09PT09PT09PT09PT09XG4gIHZhciBQb3BvdmVyID0gZnVuY3Rpb24oIGVsZW1lbnQsIG9wdGlvbnMgKSB7XG4gIFxuICAgIC8vIGluaXRpYWxpemF0aW9uIGVsZW1lbnRcbiAgICBlbGVtZW50ID0gcXVlcnlFbGVtZW50KGVsZW1lbnQpO1xuICBcbiAgICAvLyBzZXQgb3B0aW9uc1xuICAgIG9wdGlvbnMgPSBvcHRpb25zIHx8IHt9O1xuICBcbiAgICAvLyBEQVRBIEFQSVxuICAgIHZhciB0cmlnZ2VyRGF0YSA9IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhVHJpZ2dlciksIC8vIGNsaWNrIC8gaG92ZXIgLyBmb2N1c1xuICAgICAgICBhbmltYXRpb25EYXRhID0gZWxlbWVudFtnZXRBdHRyaWJ1dGVdKGRhdGFBbmltYXRpb24pLCAvLyB0cnVlIC8gZmFsc2VcbiAgICAgICAgcGxhY2VtZW50RGF0YSA9IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhUGxhY2VtZW50KSxcbiAgICAgICAgZGlzbWlzc2libGVEYXRhID0gZWxlbWVudFtnZXRBdHRyaWJ1dGVdKGRhdGFEaXNtaXNzaWJsZSksXG4gICAgICAgIGRlbGF5RGF0YSA9IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhRGVsYXkpLFxuICAgICAgICBjb250YWluZXJEYXRhID0gZWxlbWVudFtnZXRBdHRyaWJ1dGVdKGRhdGFDb250YWluZXIpLFxuICBcbiAgICAgICAgLy8gaW50ZXJuYWwgc3RyaW5nc1xuICAgICAgICBjb21wb25lbnQgPSAncG9wb3ZlcicsXG4gICAgICAgIHRlbXBsYXRlID0gJ3RlbXBsYXRlJyxcbiAgICAgICAgdHJpZ2dlciA9ICd0cmlnZ2VyJyxcbiAgICAgICAgY2xhc3NTdHJpbmcgPSAnY2xhc3MnLFxuICAgICAgICBkaXYgPSAnZGl2JyxcbiAgICAgICAgZmFkZSA9ICdmYWRlJyxcbiAgICAgICAgZGF0YUNvbnRlbnQgPSAnZGF0YS1jb250ZW50JyxcbiAgICAgICAgZGlzbWlzc2libGUgPSAnZGlzbWlzc2libGUnLFxuICAgICAgICBjbG9zZUJ0biA9ICc8YnV0dG9uIHR5cGU9XCJidXR0b25cIiBjbGFzcz1cImNsb3NlXCI+w5c8L2J1dHRvbj4nLFxuICBcbiAgICAgICAgLy8gY2hlY2sgY29udGFpbmVyXG4gICAgICAgIGNvbnRhaW5lckVsZW1lbnQgPSBxdWVyeUVsZW1lbnQob3B0aW9uc1tjb250YWluZXJdKSxcbiAgICAgICAgY29udGFpbmVyRGF0YUVsZW1lbnQgPSBxdWVyeUVsZW1lbnQoY29udGFpbmVyRGF0YSksICAgICAgXG4gICAgICAgIFxuICAgICAgICAvLyBtYXliZSB0aGUgZWxlbWVudCBpcyBpbnNpZGUgYSBtb2RhbFxuICAgICAgICBtb2RhbCA9IGdldENsb3Nlc3QoZWxlbWVudCwnLm1vZGFsJyksXG4gICAgICAgIFxuICAgICAgICAvLyBtYXliZSB0aGUgZWxlbWVudCBpcyBpbnNpZGUgYSBmaXhlZCBuYXZiYXJcbiAgICAgICAgbmF2YmFyRml4ZWRUb3AgPSBnZXRDbG9zZXN0KGVsZW1lbnQsJy4nK2ZpeGVkVG9wKSxcbiAgICAgICAgbmF2YmFyRml4ZWRCb3R0b20gPSBnZXRDbG9zZXN0KGVsZW1lbnQsJy4nK2ZpeGVkQm90dG9tKTtcbiAgXG4gICAgLy8gc2V0IGluc3RhbmNlIG9wdGlvbnNcbiAgICB0aGlzW3RlbXBsYXRlXSA9IG9wdGlvbnNbdGVtcGxhdGVdID8gb3B0aW9uc1t0ZW1wbGF0ZV0gOiBudWxsOyAvLyBKYXZhU2NyaXB0IG9ubHlcbiAgICB0aGlzW3RyaWdnZXJdID0gb3B0aW9uc1t0cmlnZ2VyXSA/IG9wdGlvbnNbdHJpZ2dlcl0gOiB0cmlnZ2VyRGF0YSB8fCBob3ZlckV2ZW50O1xuICAgIHRoaXNbYW5pbWF0aW9uXSA9IG9wdGlvbnNbYW5pbWF0aW9uXSAmJiBvcHRpb25zW2FuaW1hdGlvbl0gIT09IGZhZGUgPyBvcHRpb25zW2FuaW1hdGlvbl0gOiBhbmltYXRpb25EYXRhIHx8IGZhZGU7XG4gICAgdGhpc1twbGFjZW1lbnRdID0gb3B0aW9uc1twbGFjZW1lbnRdID8gb3B0aW9uc1twbGFjZW1lbnRdIDogcGxhY2VtZW50RGF0YSB8fCB0b3A7XG4gICAgdGhpc1tkZWxheV0gPSBwYXJzZUludChvcHRpb25zW2RlbGF5XSB8fCBkZWxheURhdGEpIHx8IDIwMDtcbiAgICB0aGlzW2Rpc21pc3NpYmxlXSA9IG9wdGlvbnNbZGlzbWlzc2libGVdIHx8IGRpc21pc3NpYmxlRGF0YSA9PT0gJ3RydWUnID8gdHJ1ZSA6IGZhbHNlO1xuICAgIHRoaXNbY29udGFpbmVyXSA9IGNvbnRhaW5lckVsZW1lbnQgPyBjb250YWluZXJFbGVtZW50IFxuICAgICAgICAgICAgICAgICAgICA6IGNvbnRhaW5lckRhdGFFbGVtZW50ID8gY29udGFpbmVyRGF0YUVsZW1lbnQgXG4gICAgICAgICAgICAgICAgICAgIDogbmF2YmFyRml4ZWRUb3AgPyBuYXZiYXJGaXhlZFRvcFxuICAgICAgICAgICAgICAgICAgICA6IG5hdmJhckZpeGVkQm90dG9tID8gbmF2YmFyRml4ZWRCb3R0b21cbiAgICAgICAgICAgICAgICAgICAgOiBtb2RhbCA/IG1vZGFsIDogRE9DW2JvZHldO1xuICBcbiAgICAvLyBiaW5kLCBjb250ZW50XG4gICAgdmFyIHNlbGYgPSB0aGlzLCBcbiAgICAgIHRpdGxlU3RyaW5nID0gb3B0aW9ucy50aXRsZSB8fCBlbGVtZW50W2dldEF0dHJpYnV0ZV0oZGF0YVRpdGxlKSB8fCBudWxsLFxuICAgICAgY29udGVudFN0cmluZyA9IG9wdGlvbnMuY29udGVudCB8fCBlbGVtZW50W2dldEF0dHJpYnV0ZV0oZGF0YUNvbnRlbnQpIHx8IG51bGw7XG4gIFxuICAgIGlmICggIWNvbnRlbnRTdHJpbmcgJiYgIXRoaXNbdGVtcGxhdGVdICkgcmV0dXJuOyAvLyBpbnZhbGlkYXRlXG4gIFxuICAgIC8vIGNvbnN0YW50cywgdmFyc1xuICAgIHZhciBwb3BvdmVyID0gbnVsbCwgdGltZXIgPSAwLCBwbGFjZW1lbnRTZXR0aW5nID0gdGhpc1twbGFjZW1lbnRdLFxuICAgICAgXG4gICAgICAvLyBoYW5kbGVyc1xuICAgICAgZGlzbWlzc2libGVIYW5kbGVyID0gZnVuY3Rpb24oZSkge1xuICAgICAgICBpZiAocG9wb3ZlciAhPT0gbnVsbCAmJiBlW3RhcmdldF0gPT09IHF1ZXJ5RWxlbWVudCgnLmNsb3NlJyxwb3BvdmVyKSkge1xuICAgICAgICAgIHNlbGYuaGlkZSgpO1xuICAgICAgICB9XG4gICAgICB9LFxuICBcbiAgICAgIC8vIHByaXZhdGUgbWV0aG9kc1xuICAgICAgcmVtb3ZlUG9wb3ZlciA9IGZ1bmN0aW9uKCkge1xuICAgICAgICBzZWxmW2NvbnRhaW5lcl0ucmVtb3ZlQ2hpbGQocG9wb3Zlcik7XG4gICAgICAgIHRpbWVyID0gbnVsbDsgcG9wb3ZlciA9IG51bGw7IFxuICAgICAgfSxcbiAgICAgIGNyZWF0ZVBvcG92ZXIgPSBmdW5jdGlvbigpIHtcbiAgICAgICAgdGl0bGVTdHJpbmcgPSBvcHRpb25zLnRpdGxlIHx8IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhVGl0bGUpO1xuICAgICAgICBjb250ZW50U3RyaW5nID0gb3B0aW9ucy5jb250ZW50IHx8IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhQ29udGVudCk7XG4gICAgICAgIC8vIGZpeGluZyBodHRwczovL2dpdGh1Yi5jb20vdGhlZG5wL2Jvb3RzdHJhcC5uYXRpdmUvaXNzdWVzLzIzM1xuICAgICAgICBjb250ZW50U3RyaW5nID0gISFjb250ZW50U3RyaW5nID8gY29udGVudFN0cmluZy5yZXBsYWNlKC9eXFxzK3xcXHMrJC9nLCAnJykgOiBudWxsO1xuICBcbiAgICAgICAgcG9wb3ZlciA9IERPQ1tjcmVhdGVFbGVtZW50XShkaXYpO1xuICBcbiAgICAgICAgaWYgKCBjb250ZW50U3RyaW5nICE9PSBudWxsICYmIHNlbGZbdGVtcGxhdGVdID09PSBudWxsICkgeyAvL2NyZWF0ZSB0aGUgcG9wb3ZlciBmcm9tIGRhdGEgYXR0cmlidXRlc1xuICBcbiAgICAgICAgICBwb3BvdmVyW3NldEF0dHJpYnV0ZV0oJ3JvbGUnLCd0b29sdGlwJyk7XG4gIFxuICAgICAgICAgIGlmICh0aXRsZVN0cmluZyAhPT0gbnVsbCkge1xuICAgICAgICAgICAgdmFyIHBvcG92ZXJUaXRsZSA9IERPQ1tjcmVhdGVFbGVtZW50XSgnaDMnKTtcbiAgICAgICAgICAgIHBvcG92ZXJUaXRsZVtzZXRBdHRyaWJ1dGVdKGNsYXNzU3RyaW5nLGNvbXBvbmVudCsnLXRpdGxlJyk7XG4gIFxuICAgICAgICAgICAgcG9wb3ZlclRpdGxlW2lubmVySFRNTF0gPSBzZWxmW2Rpc21pc3NpYmxlXSA/IHRpdGxlU3RyaW5nICsgY2xvc2VCdG4gOiB0aXRsZVN0cmluZztcbiAgICAgICAgICAgIHBvcG92ZXJbYXBwZW5kQ2hpbGRdKHBvcG92ZXJUaXRsZSk7XG4gICAgICAgICAgfVxuICBcbiAgICAgICAgICB2YXIgcG9wb3ZlckFycm93ID0gRE9DW2NyZWF0ZUVsZW1lbnRdKGRpdiksIHBvcG92ZXJDb250ZW50ID0gRE9DW2NyZWF0ZUVsZW1lbnRdKGRpdik7XG4gICAgICAgICAgcG9wb3ZlckFycm93W3NldEF0dHJpYnV0ZV0oY2xhc3NTdHJpbmcsJ2Fycm93Jyk7IHBvcG92ZXJDb250ZW50W3NldEF0dHJpYnV0ZV0oY2xhc3NTdHJpbmcsY29tcG9uZW50KyctY29udGVudCcpO1xuICAgICAgICAgIHBvcG92ZXJbYXBwZW5kQ2hpbGRdKHBvcG92ZXJBcnJvdyk7IHBvcG92ZXJbYXBwZW5kQ2hpbGRdKHBvcG92ZXJDb250ZW50KTtcbiAgXG4gICAgICAgICAgLy9zZXQgcG9wb3ZlciBjb250ZW50XG4gICAgICAgICAgcG9wb3ZlckNvbnRlbnRbaW5uZXJIVE1MXSA9IHNlbGZbZGlzbWlzc2libGVdICYmIHRpdGxlU3RyaW5nID09PSBudWxsID8gY29udGVudFN0cmluZyArIGNsb3NlQnRuIDogY29udGVudFN0cmluZztcbiAgXG4gICAgICAgIH0gZWxzZSB7ICAvLyBvciBjcmVhdGUgdGhlIHBvcG92ZXIgZnJvbSB0ZW1wbGF0ZVxuICAgICAgICAgIHZhciBwb3BvdmVyVGVtcGxhdGUgPSBET0NbY3JlYXRlRWxlbWVudF0oZGl2KTtcbiAgICAgICAgICBzZWxmW3RlbXBsYXRlXSA9IHNlbGZbdGVtcGxhdGVdLnJlcGxhY2UoL15cXHMrfFxccyskL2csICcnKTtcbiAgICAgICAgICBwb3BvdmVyVGVtcGxhdGVbaW5uZXJIVE1MXSA9IHNlbGZbdGVtcGxhdGVdO1xuICAgICAgICAgIHBvcG92ZXJbaW5uZXJIVE1MXSA9IHBvcG92ZXJUZW1wbGF0ZS5maXJzdENoaWxkW2lubmVySFRNTF07XG4gICAgICAgIH1cbiAgXG4gICAgICAgIC8vYXBwZW5kIHRvIHRoZSBjb250YWluZXJcbiAgICAgICAgc2VsZltjb250YWluZXJdW2FwcGVuZENoaWxkXShwb3BvdmVyKTtcbiAgICAgICAgcG9wb3ZlcltzdHlsZV0uZGlzcGxheSA9ICdibG9jayc7XG4gICAgICAgIHBvcG92ZXJbc2V0QXR0cmlidXRlXShjbGFzc1N0cmluZywgY29tcG9uZW50KyAnICcgKyBwbGFjZW1lbnRTZXR0aW5nICsgJyAnICsgc2VsZlthbmltYXRpb25dKTtcbiAgICAgIH0sXG4gICAgICBzaG93UG9wb3ZlciA9IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgIWhhc0NsYXNzKHBvcG92ZXIsaW5DbGFzcykgJiYgKCBhZGRDbGFzcyhwb3BvdmVyLGluQ2xhc3MpICk7XG4gICAgICB9LFxuICAgICAgdXBkYXRlUG9wb3ZlciA9IGZ1bmN0aW9uKCkge1xuICAgICAgICBzdHlsZVRpcChlbGVtZW50LHBvcG92ZXIscGxhY2VtZW50U2V0dGluZyxzZWxmW2NvbnRhaW5lcl0pO1xuICAgICAgfSxcbiAgICAgIFxuICAgICAgLy8gZXZlbnQgdG9nZ2xlXG4gICAgICBkaXNtaXNzSGFuZGxlclRvZ2dsZSA9IGZ1bmN0aW9uKHR5cGUpe1xuICAgICAgICBpZiAoY2xpY2tFdmVudCA9PSBzZWxmW3RyaWdnZXJdIHx8ICdmb2N1cycgPT0gc2VsZlt0cmlnZ2VyXSkge1xuICAgICAgICAgICFzZWxmW2Rpc21pc3NpYmxlXSAmJiB0eXBlKCBlbGVtZW50LCAnYmx1cicsIHNlbGYuaGlkZSApO1xuICAgICAgICB9XG4gICAgICAgIHNlbGZbZGlzbWlzc2libGVdICYmIHR5cGUoIERPQywgY2xpY2tFdmVudCwgZGlzbWlzc2libGVIYW5kbGVyICk7XG4gICAgICAgICFpc0lFOCAmJiB0eXBlKCBnbG9iYWxPYmplY3QsIHJlc2l6ZUV2ZW50LCBzZWxmLmhpZGUsIHBhc3NpdmVIYW5kbGVyICk7XG4gICAgICB9LFxuICBcbiAgICAgIC8vIHRyaWdnZXJzXG4gICAgICBzaG93VHJpZ2dlciA9IGZ1bmN0aW9uKCkge1xuICAgICAgICBkaXNtaXNzSGFuZGxlclRvZ2dsZShvbik7XG4gICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoZWxlbWVudCwgc2hvd25FdmVudCwgY29tcG9uZW50KTtcbiAgICAgIH0sXG4gICAgICBoaWRlVHJpZ2dlciA9IGZ1bmN0aW9uKCkge1xuICAgICAgICBkaXNtaXNzSGFuZGxlclRvZ2dsZShvZmYpO1xuICAgICAgICByZW1vdmVQb3BvdmVyKCk7XG4gICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoZWxlbWVudCwgaGlkZGVuRXZlbnQsIGNvbXBvbmVudCk7XG4gICAgICB9O1xuICBcbiAgICAvLyBwdWJsaWMgbWV0aG9kcyAvIGhhbmRsZXJzXG4gICAgdGhpcy50b2dnbGUgPSBmdW5jdGlvbigpIHtcbiAgICAgIGlmIChwb3BvdmVyID09PSBudWxsKSB7IHNlbGYuc2hvdygpOyB9IFxuICAgICAgZWxzZSB7IHNlbGYuaGlkZSgpOyB9XG4gICAgfTtcbiAgICB0aGlzLnNob3cgPSBmdW5jdGlvbigpIHtcbiAgICAgIGNsZWFyVGltZW91dCh0aW1lcik7XG4gICAgICB0aW1lciA9IHNldFRpbWVvdXQoIGZ1bmN0aW9uKCkge1xuICAgICAgICBpZiAocG9wb3ZlciA9PT0gbnVsbCkge1xuICAgICAgICAgIHBsYWNlbWVudFNldHRpbmcgPSBzZWxmW3BsYWNlbWVudF07IC8vIHdlIHJlc2V0IHBsYWNlbWVudCBpbiBhbGwgY2FzZXNcbiAgICAgICAgICBjcmVhdGVQb3BvdmVyKCk7XG4gICAgICAgICAgdXBkYXRlUG9wb3ZlcigpO1xuICAgICAgICAgIHNob3dQb3BvdmVyKCk7XG4gICAgICAgICAgYm9vdHN0cmFwQ3VzdG9tRXZlbnQuY2FsbChlbGVtZW50LCBzaG93RXZlbnQsIGNvbXBvbmVudCk7XG4gICAgICAgICAgISFzZWxmW2FuaW1hdGlvbl0gPyBlbXVsYXRlVHJhbnNpdGlvbkVuZChwb3BvdmVyLCBzaG93VHJpZ2dlcikgOiBzaG93VHJpZ2dlcigpO1xuICAgICAgICB9XG4gICAgICB9LCAyMCApO1xuICAgIH07XG4gICAgdGhpcy5oaWRlID0gZnVuY3Rpb24oKSB7XG4gICAgICBjbGVhclRpbWVvdXQodGltZXIpO1xuICAgICAgdGltZXIgPSBzZXRUaW1lb3V0KCBmdW5jdGlvbigpIHtcbiAgICAgICAgaWYgKHBvcG92ZXIgJiYgcG9wb3ZlciAhPT0gbnVsbCAmJiBoYXNDbGFzcyhwb3BvdmVyLGluQ2xhc3MpKSB7XG4gICAgICAgICAgYm9vdHN0cmFwQ3VzdG9tRXZlbnQuY2FsbChlbGVtZW50LCBoaWRlRXZlbnQsIGNvbXBvbmVudCk7XG4gICAgICAgICAgcmVtb3ZlQ2xhc3MocG9wb3ZlcixpbkNsYXNzKTtcbiAgICAgICAgICAhIXNlbGZbYW5pbWF0aW9uXSA/IGVtdWxhdGVUcmFuc2l0aW9uRW5kKHBvcG92ZXIsIGhpZGVUcmlnZ2VyKSA6IGhpZGVUcmlnZ2VyKCk7XG4gICAgICAgIH1cbiAgICAgIH0sIHNlbGZbZGVsYXldICk7XG4gICAgfTtcbiAgXG4gICAgLy8gaW5pdFxuICAgIGlmICggIShzdHJpbmdQb3BvdmVyIGluIGVsZW1lbnQpICkgeyAvLyBwcmV2ZW50IGFkZGluZyBldmVudCBoYW5kbGVycyB0d2ljZVxuICAgICAgaWYgKHNlbGZbdHJpZ2dlcl0gPT09IGhvdmVyRXZlbnQpIHtcbiAgICAgICAgb24oIGVsZW1lbnQsIG1vdXNlSG92ZXJbMF0sIHNlbGYuc2hvdyApO1xuICAgICAgICBpZiAoIXNlbGZbZGlzbWlzc2libGVdKSB7IG9uKCBlbGVtZW50LCBtb3VzZUhvdmVyWzFdLCBzZWxmLmhpZGUgKTsgfVxuICAgICAgfSBlbHNlIGlmIChjbGlja0V2ZW50ID09IHNlbGZbdHJpZ2dlcl0gfHwgJ2ZvY3VzJyA9PSBzZWxmW3RyaWdnZXJdKSB7XG4gICAgICAgIG9uKCBlbGVtZW50LCBzZWxmW3RyaWdnZXJdLCBzZWxmLnRvZ2dsZSApO1xuICAgICAgfSAgICBcbiAgICB9XG4gICAgZWxlbWVudFtzdHJpbmdQb3BvdmVyXSA9IHNlbGY7XG4gIH07XG4gIFxuICAvLyBQT1BPVkVSIERBVEEgQVBJXG4gIC8vID09PT09PT09PT09PT09PT1cbiAgc3VwcG9ydHNbcHVzaF0oIFsgc3RyaW5nUG9wb3ZlciwgUG9wb3ZlciwgJ1snK2RhdGFUb2dnbGUrJz1cInBvcG92ZXJcIl0nIF0gKTtcbiAgXG4gIFxuICAvKiBOYXRpdmUgSmF2YXNjcmlwdCBmb3IgQm9vdHN0cmFwIDMgfCBTY3JvbGxTcHlcbiAgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0qL1xuICBcbiAgLy8gU0NST0xMU1BZIERFRklOSVRJT05cbiAgLy8gPT09PT09PT09PT09PT09PT09PT1cbiAgdmFyIFNjcm9sbFNweSA9IGZ1bmN0aW9uKGVsZW1lbnQsIG9wdGlvbnMpIHtcbiAgXG4gICAgLy8gaW5pdGlhbGl6YXRpb24gZWxlbWVudCwgdGhlIGVsZW1lbnQgd2Ugc3B5IG9uXG4gICAgZWxlbWVudCA9IHF1ZXJ5RWxlbWVudChlbGVtZW50KTsgXG4gIFxuICAgIC8vIERBVEEgQVBJXG4gICAgdmFyIHRhcmdldERhdGEgPSBxdWVyeUVsZW1lbnQoZWxlbWVudFtnZXRBdHRyaWJ1dGVdKGRhdGFUYXJnZXQpKSxcbiAgICAgICAgb2Zmc2V0RGF0YSA9IGVsZW1lbnRbZ2V0QXR0cmlidXRlXSgnZGF0YS1vZmZzZXQnKTtcbiAgXG4gICAgLy8gc2V0IG9wdGlvbnNcbiAgICBvcHRpb25zID0gb3B0aW9ucyB8fCB7fTtcbiAgXG4gICAgLy8gaW52YWxpZGF0ZVxuICAgIGlmICggIW9wdGlvbnNbdGFyZ2V0XSAmJiAhdGFyZ2V0RGF0YSApIHsgcmV0dXJuOyB9IFxuICBcbiAgICAvLyBldmVudCB0YXJnZXRzLCBjb25zdGFudHNcbiAgICB2YXIgc2VsZiA9IHRoaXMsIHNweVRhcmdldCA9IG9wdGlvbnNbdGFyZ2V0XSAmJiBxdWVyeUVsZW1lbnQob3B0aW9uc1t0YXJnZXRdKSB8fCB0YXJnZXREYXRhLFxuICAgICAgICBsaW5rcyA9IHNweVRhcmdldCAmJiBzcHlUYXJnZXRbZ2V0RWxlbWVudHNCeVRhZ05hbWVdKCdBJyksXG4gICAgICAgIG9mZnNldCA9IHBhcnNlSW50KG9wdGlvbnNbJ29mZnNldCddIHx8IG9mZnNldERhdGEpIHx8IDEwLCAgICAgIFxuICAgICAgICBpdGVtcyA9IFtdLCB0YXJnZXRJdGVtcyA9IFtdLCBzY3JvbGxPZmZzZXQsXG4gICAgICAgIHNjcm9sbFRhcmdldCA9IGVsZW1lbnRbb2Zmc2V0SGVpZ2h0XSA8IGVsZW1lbnRbc2Nyb2xsSGVpZ2h0XSA/IGVsZW1lbnQgOiBnbG9iYWxPYmplY3QsIC8vIGRldGVybWluZSB3aGljaCBpcyB0aGUgcmVhbCBzY3JvbGxUYXJnZXRcbiAgICAgICAgaXNXaW5kb3cgPSBzY3JvbGxUYXJnZXQgPT09IGdsb2JhbE9iamVjdDsgIFxuICBcbiAgICAvLyBwb3B1bGF0ZSBpdGVtcyBhbmQgdGFyZ2V0c1xuICAgIGZvciAodmFyIGk9MCwgaWw9bGlua3NbbGVuZ3RoXTsgaTxpbDsgaSsrKSB7XG4gICAgICB2YXIgaHJlZiA9IGxpbmtzW2ldW2dldEF0dHJpYnV0ZV0oJ2hyZWYnKSwgXG4gICAgICAgICAgdGFyZ2V0SXRlbSA9IGhyZWYgJiYgaHJlZi5jaGFyQXQoMCkgPT09ICcjJyAmJiBocmVmLnNsaWNlKC0xKSAhPT0gJyMnICYmIHF1ZXJ5RWxlbWVudChocmVmKTtcbiAgICAgIGlmICggISF0YXJnZXRJdGVtICkge1xuICAgICAgICBpdGVtc1twdXNoXShsaW5rc1tpXSk7XG4gICAgICAgIHRhcmdldEl0ZW1zW3B1c2hdKHRhcmdldEl0ZW0pO1xuICAgICAgfVxuICAgIH1cbiAgXG4gICAgLy8gcHJpdmF0ZSBtZXRob2RzXG4gICAgdmFyIHVwZGF0ZUl0ZW0gPSBmdW5jdGlvbihpbmRleCkge1xuICAgICAgdmFyIHBhcmVudCA9IGl0ZW1zW2luZGV4XVtwYXJlbnROb2RlXSwgLy8gaXRlbSdzIHBhcmVudCBMSSBlbGVtZW50XG4gICAgICAgICAgdGFyZ2V0SXRlbSA9IHRhcmdldEl0ZW1zW2luZGV4XSwgLy8gdGhlIG1lbnUgaXRlbSB0YXJnZXRzIHRoaXMgZWxlbWVudFxuICAgICAgICAgIGRyb3Bkb3duID0gZ2V0Q2xvc2VzdChwYXJlbnQsJy5kcm9wZG93bicpLFxuICAgICAgICAgIHRhcmdldFJlY3QgPSBpc1dpbmRvdyAmJiB0YXJnZXRJdGVtW2dldEJvdW5kaW5nQ2xpZW50UmVjdF0oKSxcbiAgXG4gICAgICAgICAgaXNBY3RpdmUgPSBoYXNDbGFzcyhwYXJlbnQsYWN0aXZlKSB8fCBmYWxzZSxcbiAgXG4gICAgICAgICAgdG9wRWRnZSA9IChpc1dpbmRvdyA/IHRhcmdldFJlY3RbdG9wXSArIHNjcm9sbE9mZnNldCA6IHRhcmdldEl0ZW1bb2Zmc2V0VG9wXSkgLSBvZmZzZXQsXG4gICAgICAgICAgYm90dG9tRWRnZSA9IGlzV2luZG93ID8gdGFyZ2V0UmVjdFtib3R0b21dICsgc2Nyb2xsT2Zmc2V0IC0gb2Zmc2V0IDogdGFyZ2V0SXRlbXNbaW5kZXgrMV0gPyB0YXJnZXRJdGVtc1tpbmRleCsxXVtvZmZzZXRUb3BdIC0gb2Zmc2V0IDogZWxlbWVudFtzY3JvbGxIZWlnaHRdLFxuICBcbiAgICAgICAgICBpbnNpZGUgPSBzY3JvbGxPZmZzZXQgPj0gdG9wRWRnZSAmJiBib3R0b21FZGdlID4gc2Nyb2xsT2Zmc2V0O1xuICBcbiAgICAgICAgaWYgKCAhaXNBY3RpdmUgJiYgaW5zaWRlICkge1xuICAgICAgICAgIGlmICggcGFyZW50LnRhZ05hbWUgPT09ICdMSScgJiYgIWhhc0NsYXNzKHBhcmVudCxhY3RpdmUpICkge1xuICAgICAgICAgICAgYWRkQ2xhc3MocGFyZW50LGFjdGl2ZSk7XG4gICAgICAgICAgICBpZiAoZHJvcGRvd24gJiYgIWhhc0NsYXNzKGRyb3Bkb3duLGFjdGl2ZSkgKSB7XG4gICAgICAgICAgICAgIGFkZENsYXNzKGRyb3Bkb3duLGFjdGl2ZSk7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKGVsZW1lbnQsICdhY3RpdmF0ZScsICdzY3JvbGxzcHknLCBpdGVtc1tpbmRleF0pO1xuICAgICAgICAgIH1cbiAgICAgICAgfSBlbHNlIGlmICggIWluc2lkZSApIHtcbiAgICAgICAgICBpZiAoIHBhcmVudC50YWdOYW1lID09PSAnTEknICYmIGhhc0NsYXNzKHBhcmVudCxhY3RpdmUpICkge1xuICAgICAgICAgICAgcmVtb3ZlQ2xhc3MocGFyZW50LGFjdGl2ZSk7XG4gICAgICAgICAgICBpZiAoZHJvcGRvd24gJiYgaGFzQ2xhc3MoZHJvcGRvd24sYWN0aXZlKSAmJiAhZ2V0RWxlbWVudHNCeUNsYXNzTmFtZShwYXJlbnRbcGFyZW50Tm9kZV0sYWN0aXZlKS5sZW5ndGggKSB7XG4gICAgICAgICAgICAgIHJlbW92ZUNsYXNzKGRyb3Bkb3duLGFjdGl2ZSk7XG4gICAgICAgICAgICB9XG4gICAgICAgICAgfVxuICAgICAgICB9IGVsc2UgaWYgKCAhaW5zaWRlICYmICFpc0FjdGl2ZSB8fCBpc0FjdGl2ZSAmJiBpbnNpZGUgKSB7XG4gICAgICAgICAgcmV0dXJuO1xuICAgICAgICB9XG4gICAgICB9LFxuICAgICAgdXBkYXRlSXRlbXMgPSBmdW5jdGlvbigpe1xuICAgICAgICBzY3JvbGxPZmZzZXQgPSBpc1dpbmRvdyA/IGdldFNjcm9sbCgpLnkgOiBlbGVtZW50W3Njcm9sbFRvcF07XG4gICAgICAgIGZvciAodmFyIGluZGV4PTAsIGl0bD1pdGVtc1tsZW5ndGhdOyBpbmRleDxpdGw7IGluZGV4KyspIHtcbiAgICAgICAgICB1cGRhdGVJdGVtKGluZGV4KVxuICAgICAgICB9XG4gICAgICB9O1xuICBcbiAgICAvLyBwdWJsaWMgbWV0aG9kXG4gICAgdGhpcy5yZWZyZXNoID0gZnVuY3Rpb24gKCkge1xuICAgICAgdXBkYXRlSXRlbXMoKTtcbiAgICB9XG4gIFxuICAgIC8vIGluaXRcbiAgICBpZiAoICEoc3RyaW5nU2Nyb2xsU3B5IGluIGVsZW1lbnQpICkgeyAvLyBwcmV2ZW50IGFkZGluZyBldmVudCBoYW5kbGVycyB0d2ljZVxuICAgICAgb24oIHNjcm9sbFRhcmdldCwgc2Nyb2xsRXZlbnQsIHNlbGYucmVmcmVzaCwgcGFzc2l2ZUhhbmRsZXIgKTtcbiAgICAgICFpc0lFOCAmJiBvbiggZ2xvYmFsT2JqZWN0LCByZXNpemVFdmVudCwgc2VsZi5yZWZyZXNoLCBwYXNzaXZlSGFuZGxlciApOyBcbiAgfVxuICAgIHNlbGYucmVmcmVzaCgpO1xuICAgIGVsZW1lbnRbc3RyaW5nU2Nyb2xsU3B5XSA9IHNlbGY7XG4gIH07XG4gIFxuICAvLyBTQ1JPTExTUFkgREFUQSBBUElcbiAgLy8gPT09PT09PT09PT09PT09PT09XG4gIHN1cHBvcnRzW3B1c2hdKCBbIHN0cmluZ1Njcm9sbFNweSwgU2Nyb2xsU3B5LCAnWycrZGF0YVNweSsnPVwic2Nyb2xsXCJdJyBdICk7XG4gIFxuICBcbiAgLyogTmF0aXZlIEphdmFzY3JpcHQgZm9yIEJvb3RzdHJhcCAzIHwgVGFiXG4gIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tKi9cbiAgXG4gIC8vIFRBQiBERUZJTklUSU9OXG4gIC8vID09PT09PT09PT09PT09XG4gIHZhciBUYWIgPSBmdW5jdGlvbiggZWxlbWVudCwgb3B0aW9ucyApIHtcbiAgXG4gICAgLy8gaW5pdGlhbGl6YXRpb24gZWxlbWVudFxuICAgIGVsZW1lbnQgPSBxdWVyeUVsZW1lbnQoZWxlbWVudCk7XG4gIFxuICAgIC8vIERBVEEgQVBJXG4gICAgdmFyIGhlaWdodERhdGEgPSBlbGVtZW50W2dldEF0dHJpYnV0ZV0oZGF0YUhlaWdodCksXG4gICAgICBcbiAgICAgICAgLy8gc3RyaW5nc1xuICAgICAgICBjb21wb25lbnQgPSAndGFiJywgaGVpZ2h0ID0gJ2hlaWdodCcsIGZsb2F0ID0gJ2Zsb2F0JywgaXNBbmltYXRpbmcgPSAnaXNBbmltYXRpbmcnO1xuICBcbiAgICAvLyBzZXQgb3B0aW9uc1xuICAgIG9wdGlvbnMgPSBvcHRpb25zIHx8IHt9O1xuICAgIHRoaXNbaGVpZ2h0XSA9IHN1cHBvcnRUcmFuc2l0aW9ucyA/IChvcHRpb25zW2hlaWdodF0gfHwgaGVpZ2h0RGF0YSA9PT0gJ3RydWUnKSA6IGZhbHNlOyAvLyBmaWx0ZXIgbGVnYWN5IGJyb3dzZXJzXG4gIFxuICAgIC8vIGJpbmQsIGV2ZW50IHRhcmdldHNcbiAgICB2YXIgc2VsZiA9IHRoaXMsIG5leHQsXG4gICAgICB0YWJzID0gZ2V0Q2xvc2VzdChlbGVtZW50LCcubmF2JyksXG4gICAgICB0YWJzQ29udGVudENvbnRhaW5lciA9IGZhbHNlLFxuICAgICAgZHJvcGRvd24gPSB0YWJzICYmIHF1ZXJ5RWxlbWVudCgnLmRyb3Bkb3duJyx0YWJzKSxcbiAgICAgIGFjdGl2ZVRhYiwgYWN0aXZlQ29udGVudCwgbmV4dENvbnRlbnQsIGNvbnRhaW5lckhlaWdodCwgZXF1YWxDb250ZW50cywgbmV4dEhlaWdodCxcbiAgXG4gICAgICAvLyB0cmlnZ2VyXG4gICAgICB0cmlnZ2VyRW5kID0gZnVuY3Rpb24oKXtcbiAgICAgICAgdGFic0NvbnRlbnRDb250YWluZXJbc3R5bGVdW2hlaWdodF0gPSAnJztcbiAgICAgICAgcmVtb3ZlQ2xhc3ModGFic0NvbnRlbnRDb250YWluZXIsY29sbGFwc2luZyk7XG4gICAgICAgIHRhYnNbaXNBbmltYXRpbmddID0gZmFsc2U7XG4gICAgICB9LFxuICAgICAgdHJpZ2dlclNob3cgPSBmdW5jdGlvbigpIHtcbiAgICAgICAgaWYgKHRhYnNDb250ZW50Q29udGFpbmVyKSB7IC8vIGhlaWdodCBhbmltYXRpb25cbiAgICAgICAgICBpZiAoIGVxdWFsQ29udGVudHMgKSB7XG4gICAgICAgICAgICB0cmlnZ2VyRW5kKCk7XG4gICAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAgIHNldFRpbWVvdXQoZnVuY3Rpb24oKXsgLy8gZW5hYmxlcyBoZWlnaHQgYW5pbWF0aW9uXG4gICAgICAgICAgICAgIHRhYnNDb250ZW50Q29udGFpbmVyW3N0eWxlXVtoZWlnaHRdID0gbmV4dEhlaWdodCArICdweCc7IC8vIGhlaWdodCBhbmltYXRpb25cbiAgICAgICAgICAgICAgdGFic0NvbnRlbnRDb250YWluZXJbb2Zmc2V0V2lkdGhdO1xuICAgICAgICAgICAgICBlbXVsYXRlVHJhbnNpdGlvbkVuZCh0YWJzQ29udGVudENvbnRhaW5lciwgdHJpZ2dlckVuZCk7XG4gICAgICAgICAgICB9LDUwKTtcbiAgICAgICAgICB9XG4gICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgdGFic1tpc0FuaW1hdGluZ10gPSBmYWxzZTsgXG4gICAgICAgIH1cbiAgICAgICAgYm9vdHN0cmFwQ3VzdG9tRXZlbnQuY2FsbChuZXh0LCBzaG93bkV2ZW50LCBjb21wb25lbnQsIGFjdGl2ZVRhYik7XG4gICAgICB9LFxuICAgICAgdHJpZ2dlckhpZGUgPSBmdW5jdGlvbigpIHtcbiAgICAgICAgaWYgKHRhYnNDb250ZW50Q29udGFpbmVyKSB7XG4gICAgICAgICAgYWN0aXZlQ29udGVudFtzdHlsZV1bZmxvYXRdID0gbGVmdDtcbiAgICAgICAgICBuZXh0Q29udGVudFtzdHlsZV1bZmxvYXRdID0gbGVmdDsgICAgICAgIFxuICAgICAgICAgIGNvbnRhaW5lckhlaWdodCA9IGFjdGl2ZUNvbnRlbnRbc2Nyb2xsSGVpZ2h0XTtcbiAgICAgICAgfVxuICAgICAgICBcbiAgICAgICAgYWRkQ2xhc3MobmV4dENvbnRlbnQsYWN0aXZlKTtcbiAgICAgICAgYm9vdHN0cmFwQ3VzdG9tRXZlbnQuY2FsbChuZXh0LCBzaG93RXZlbnQsIGNvbXBvbmVudCwgYWN0aXZlVGFiKTtcbiAgICAgICAgXG4gICAgICAgIHJlbW92ZUNsYXNzKGFjdGl2ZUNvbnRlbnQsYWN0aXZlKTtcbiAgICAgICAgYm9vdHN0cmFwQ3VzdG9tRXZlbnQuY2FsbChhY3RpdmVUYWIsIGhpZGRlbkV2ZW50LCBjb21wb25lbnQsIG5leHQpO1xuICAgICAgICBcbiAgICAgICAgaWYgKHRhYnNDb250ZW50Q29udGFpbmVyKSB7XG4gICAgICAgICAgbmV4dEhlaWdodCA9IG5leHRDb250ZW50W3Njcm9sbEhlaWdodF07XG4gICAgICAgICAgZXF1YWxDb250ZW50cyA9IG5leHRIZWlnaHQgPT09IGNvbnRhaW5lckhlaWdodDtcbiAgICAgICAgICBhZGRDbGFzcyh0YWJzQ29udGVudENvbnRhaW5lcixjb2xsYXBzaW5nKTtcbiAgICAgICAgICB0YWJzQ29udGVudENvbnRhaW5lcltzdHlsZV1baGVpZ2h0XSA9IGNvbnRhaW5lckhlaWdodCArICdweCc7IC8vIGhlaWdodCBhbmltYXRpb25cbiAgICAgICAgICB0YWJzQ29udGVudENvbnRhaW5lcltvZmZzZXRIZWlnaHRdO1xuICAgICAgICAgIGFjdGl2ZUNvbnRlbnRbc3R5bGVdW2Zsb2F0XSA9ICcnO1xuICAgICAgICAgIG5leHRDb250ZW50W3N0eWxlXVtmbG9hdF0gPSAnJztcbiAgICAgICAgfVxuICBcbiAgICAgICAgaWYgKCBoYXNDbGFzcyhuZXh0Q29udGVudCwgJ2ZhZGUnKSApIHtcbiAgICAgICAgICBzZXRUaW1lb3V0KGZ1bmN0aW9uKCl7XG4gICAgICAgICAgICBhZGRDbGFzcyhuZXh0Q29udGVudCxpbkNsYXNzKTtcbiAgICAgICAgICAgIGVtdWxhdGVUcmFuc2l0aW9uRW5kKG5leHRDb250ZW50LHRyaWdnZXJTaG93KTtcbiAgICAgICAgICB9LDIwKTtcbiAgICAgICAgfSBlbHNlIHsgdHJpZ2dlclNob3coKTsgfSAgICAgICAgXG4gICAgICB9O1xuICBcbiAgICBpZiAoIXRhYnMpIHJldHVybjsgLy8gaW52YWxpZGF0ZSBcbiAgXG4gICAgLy8gc2V0IGRlZmF1bHQgYW5pbWF0aW9uIHN0YXRlXG4gICAgdGFic1tpc0FuaW1hdGluZ10gPSBmYWxzZTtcbiAgICAgIFxuICAgIC8vIHByaXZhdGUgbWV0aG9kc1xuICAgIHZhciBnZXRBY3RpdmVUYWIgPSBmdW5jdGlvbigpIHtcbiAgICAgICAgdmFyIGFjdGl2ZVRhYnMgPSBnZXRFbGVtZW50c0J5Q2xhc3NOYW1lKHRhYnMsYWN0aXZlKSwgYWN0aXZlVGFiO1xuICAgICAgICBpZiAoIGFjdGl2ZVRhYnNbbGVuZ3RoXSA9PT0gMSAmJiAhaGFzQ2xhc3MoYWN0aXZlVGFic1swXSwnZHJvcGRvd24nKSApIHtcbiAgICAgICAgICBhY3RpdmVUYWIgPSBhY3RpdmVUYWJzWzBdO1xuICAgICAgICB9IGVsc2UgaWYgKCBhY3RpdmVUYWJzW2xlbmd0aF0gPiAxICkge1xuICAgICAgICAgIGFjdGl2ZVRhYiA9IGFjdGl2ZVRhYnNbYWN0aXZlVGFic1tsZW5ndGhdLTFdO1xuICAgICAgICB9XG4gICAgICAgIHJldHVybiBhY3RpdmVUYWJbZ2V0RWxlbWVudHNCeVRhZ05hbWVdKCdBJylbMF07XG4gICAgICB9LFxuICAgICAgZ2V0QWN0aXZlQ29udGVudCA9IGZ1bmN0aW9uKCkge1xuICAgICAgICByZXR1cm4gcXVlcnlFbGVtZW50KGdldEFjdGl2ZVRhYigpW2dldEF0dHJpYnV0ZV0oJ2hyZWYnKSk7XG4gICAgICB9LFxuICAgICAgLy8gaGFuZGxlclxuICAgICAgY2xpY2tIYW5kbGVyID0gZnVuY3Rpb24oZSkge1xuICAgICAgICBlW3ByZXZlbnREZWZhdWx0XSgpO1xuICAgICAgICBuZXh0ID0gZVtjdXJyZW50VGFyZ2V0XSB8fCB0aGlzOyAvLyBJRTggbmVlZHMgdG8ga25vdyB3aG8gcmVhbGx5IGN1cnJlbnRUYXJnZXQgaXNcbiAgICAgICAgIXRhYnNbaXNBbmltYXRpbmddICYmICFoYXNDbGFzcyhuZXh0W3BhcmVudE5vZGVdLGFjdGl2ZSkgJiYgc2VsZi5zaG93KCk7XG4gICAgICB9O1xuICBcbiAgICAvLyBwdWJsaWMgbWV0aG9kXG4gICAgdGhpcy5zaG93ID0gZnVuY3Rpb24oKSB7IC8vIHRoZSB0YWIgd2UgY2xpY2tlZCBpcyBub3cgdGhlIG5leHQgdGFiXG4gICAgICBuZXh0ID0gbmV4dCB8fCBlbGVtZW50O1xuICAgICAgbmV4dENvbnRlbnQgPSBxdWVyeUVsZW1lbnQobmV4dFtnZXRBdHRyaWJ1dGVdKCdocmVmJykpOyAvL3RoaXMgaXMgdGhlIGFjdHVhbCBvYmplY3QsIHRoZSBuZXh0IHRhYiBjb250ZW50IHRvIGFjdGl2YXRlXG4gICAgICBhY3RpdmVUYWIgPSBnZXRBY3RpdmVUYWIoKTsgXG4gICAgICBhY3RpdmVDb250ZW50ID0gZ2V0QWN0aXZlQ29udGVudCgpO1xuICBcbiAgICAgIHRhYnNbaXNBbmltYXRpbmddID0gdHJ1ZTtcbiAgICAgIHJlbW92ZUNsYXNzKGFjdGl2ZVRhYltwYXJlbnROb2RlXSxhY3RpdmUpO1xuICAgICAgYWN0aXZlVGFiW3NldEF0dHJpYnV0ZV0oYXJpYUV4cGFuZGVkLCdmYWxzZScpO1xuICAgICAgYWRkQ2xhc3MobmV4dFtwYXJlbnROb2RlXSxhY3RpdmUpO1xuICAgICAgbmV4dFtzZXRBdHRyaWJ1dGVdKGFyaWFFeHBhbmRlZCwndHJ1ZScpO1xuICBcbiAgICAgIGlmICggZHJvcGRvd24gKSB7XG4gICAgICAgIGlmICggIWhhc0NsYXNzKGVsZW1lbnRbcGFyZW50Tm9kZV1bcGFyZW50Tm9kZV0sJ2Ryb3Bkb3duLW1lbnUnKSApIHtcbiAgICAgICAgICBpZiAoaGFzQ2xhc3MoZHJvcGRvd24sYWN0aXZlKSkgcmVtb3ZlQ2xhc3MoZHJvcGRvd24sYWN0aXZlKTtcbiAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICBpZiAoIWhhc0NsYXNzKGRyb3Bkb3duLGFjdGl2ZSkpIGFkZENsYXNzKGRyb3Bkb3duLGFjdGl2ZSk7XG4gICAgICAgIH1cbiAgICAgIH1cbiAgICAgIFxuICAgICAgYm9vdHN0cmFwQ3VzdG9tRXZlbnQuY2FsbChhY3RpdmVUYWIsIGhpZGVFdmVudCwgY29tcG9uZW50LCBuZXh0KTtcbiAgICAgIFxuICAgICAgaWYgKGhhc0NsYXNzKGFjdGl2ZUNvbnRlbnQsICdmYWRlJykpIHtcbiAgICAgICAgcmVtb3ZlQ2xhc3MoYWN0aXZlQ29udGVudCxpbkNsYXNzKTtcbiAgICAgICAgZW11bGF0ZVRyYW5zaXRpb25FbmQoYWN0aXZlQ29udGVudCwgdHJpZ2dlckhpZGUpO1xuICAgICAgfSBlbHNlIHsgdHJpZ2dlckhpZGUoKTsgfVxuICAgIH07XG4gIFxuICAgIC8vIGluaXRcbiAgICBpZiAoICEoc3RyaW5nVGFiIGluIGVsZW1lbnQpICkgeyAvLyBwcmV2ZW50IGFkZGluZyBldmVudCBoYW5kbGVycyB0d2ljZVxuICAgICAgb24oZWxlbWVudCwgY2xpY2tFdmVudCwgY2xpY2tIYW5kbGVyKTtcbiAgICB9XG4gICAgaWYgKHNlbGZbaGVpZ2h0XSkgeyB0YWJzQ29udGVudENvbnRhaW5lciA9IGdldEFjdGl2ZUNvbnRlbnQoKVtwYXJlbnROb2RlXTsgfVxuICAgIGVsZW1lbnRbc3RyaW5nVGFiXSA9IHNlbGY7XG4gIH07XG4gIFxuICAvLyBUQUIgREFUQSBBUElcbiAgLy8gPT09PT09PT09PT09XG4gIHN1cHBvcnRzW3B1c2hdKCBbIHN0cmluZ1RhYiwgVGFiLCAnWycrZGF0YVRvZ2dsZSsnPVwidGFiXCJdJyBdICk7XG4gIFxuICBcbiAgLyogTmF0aXZlIEphdmFzY3JpcHQgZm9yIEJvb3RzdHJhcCAzIHwgVG9vbHRpcFxuICAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0qL1xuICBcbiAgLy8gVE9PTFRJUCBERUZJTklUSU9OXG4gIC8vID09PT09PT09PT09PT09PT09PVxuICB2YXIgVG9vbHRpcCA9IGZ1bmN0aW9uKCBlbGVtZW50LG9wdGlvbnMgKSB7XG4gIFxuICAgIC8vIGluaXRpYWxpemF0aW9uIGVsZW1lbnRcbiAgICBlbGVtZW50ID0gcXVlcnlFbGVtZW50KGVsZW1lbnQpO1xuICBcbiAgICAvLyBzZXQgb3B0aW9uc1xuICAgIG9wdGlvbnMgPSBvcHRpb25zIHx8IHt9O1xuICBcbiAgICAvLyBEQVRBIEFQSVxuICAgIHZhciBhbmltYXRpb25EYXRhID0gZWxlbWVudFtnZXRBdHRyaWJ1dGVdKGRhdGFBbmltYXRpb24pLFxuICAgICAgICBwbGFjZW1lbnREYXRhID0gZWxlbWVudFtnZXRBdHRyaWJ1dGVdKGRhdGFQbGFjZW1lbnQpLFxuICAgICAgICBkZWxheURhdGEgPSBlbGVtZW50W2dldEF0dHJpYnV0ZV0oZGF0YURlbGF5KSxcbiAgICAgICAgY29udGFpbmVyRGF0YSA9IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhQ29udGFpbmVyKSxcbiAgICAgICAgXG4gICAgICAgIC8vIHN0cmluZ3NcbiAgICAgICAgY29tcG9uZW50ID0gJ3Rvb2x0aXAnLFxuICAgICAgICBjbGFzc1N0cmluZyA9ICdjbGFzcycsXG4gICAgICAgIHRpdGxlID0gJ3RpdGxlJyxcbiAgICAgICAgZmFkZSA9ICdmYWRlJyxcbiAgICAgICAgZGl2ID0gJ2RpdicsXG4gIFxuICAgICAgICAvLyBjaGVjayBjb250YWluZXJcbiAgICAgICAgY29udGFpbmVyRWxlbWVudCA9IHF1ZXJ5RWxlbWVudChvcHRpb25zW2NvbnRhaW5lcl0pLFxuICAgICAgICBjb250YWluZXJEYXRhRWxlbWVudCA9IHF1ZXJ5RWxlbWVudChjb250YWluZXJEYXRhKSwgICAgICAgIFxuICBcbiAgICAgICAgLy8gbWF5YmUgdGhlIGVsZW1lbnQgaXMgaW5zaWRlIGEgbW9kYWxcbiAgICAgICAgbW9kYWwgPSBnZXRDbG9zZXN0KGVsZW1lbnQsJy5tb2RhbCcpLFxuICAgICAgICBcbiAgICAgICAgLy8gbWF5YmUgdGhlIGVsZW1lbnQgaXMgaW5zaWRlIGEgZml4ZWQgbmF2YmFyXG4gICAgICAgIG5hdmJhckZpeGVkVG9wID0gZ2V0Q2xvc2VzdChlbGVtZW50LCcuJytmaXhlZFRvcCksXG4gICAgICAgIG5hdmJhckZpeGVkQm90dG9tID0gZ2V0Q2xvc2VzdChlbGVtZW50LCcuJytmaXhlZEJvdHRvbSk7XG4gIFxuICAgIC8vIHNldCBpbnN0YW5jZSBvcHRpb25zXG4gICAgdGhpc1thbmltYXRpb25dID0gb3B0aW9uc1thbmltYXRpb25dICYmIG9wdGlvbnNbYW5pbWF0aW9uXSAhPT0gZmFkZSA/IG9wdGlvbnNbYW5pbWF0aW9uXSA6IGFuaW1hdGlvbkRhdGEgfHwgZmFkZTtcbiAgICB0aGlzW3BsYWNlbWVudF0gPSBvcHRpb25zW3BsYWNlbWVudF0gPyBvcHRpb25zW3BsYWNlbWVudF0gOiBwbGFjZW1lbnREYXRhIHx8IHRvcDtcbiAgICB0aGlzW2RlbGF5XSA9IHBhcnNlSW50KG9wdGlvbnNbZGVsYXldIHx8IGRlbGF5RGF0YSkgfHwgMjAwO1xuICAgIHRoaXNbY29udGFpbmVyXSA9IGNvbnRhaW5lckVsZW1lbnQgPyBjb250YWluZXJFbGVtZW50IFxuICAgICAgICAgICAgICAgICAgICA6IGNvbnRhaW5lckRhdGFFbGVtZW50ID8gY29udGFpbmVyRGF0YUVsZW1lbnQgXG4gICAgICAgICAgICAgICAgICAgIDogbmF2YmFyRml4ZWRUb3AgPyBuYXZiYXJGaXhlZFRvcFxuICAgICAgICAgICAgICAgICAgICA6IG5hdmJhckZpeGVkQm90dG9tID8gbmF2YmFyRml4ZWRCb3R0b21cbiAgICAgICAgICAgICAgICAgICAgOiBtb2RhbCA/IG1vZGFsIDogRE9DW2JvZHldO1xuICBcbiAgICAvLyBiaW5kLCBldmVudCB0YXJnZXRzLCB0aXRsZSBhbmQgY29uc3RhbnRzXG4gICAgdmFyIHNlbGYgPSB0aGlzLCB0aW1lciA9IDAsIHBsYWNlbWVudFNldHRpbmcgPSB0aGlzW3BsYWNlbWVudF0sIHRvb2x0aXAgPSBudWxsLFxuICAgICAgdGl0bGVTdHJpbmcgPSBlbGVtZW50W2dldEF0dHJpYnV0ZV0odGl0bGUpIHx8IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhVGl0bGUpIHx8IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhT3JpZ2luYWxUaXRsZSk7XG4gIFxuICAgIGlmICggIXRpdGxlU3RyaW5nIHx8IHRpdGxlU3RyaW5nID09IFwiXCIgKSByZXR1cm47IC8vIGludmFsaWRhdGVcbiAgXG4gICAgLy8gcHJpdmF0ZSBtZXRob2RzXG4gICAgdmFyIHJlbW92ZVRvb2xUaXAgPSBmdW5jdGlvbigpIHtcbiAgICAgICAgc2VsZltjb250YWluZXJdLnJlbW92ZUNoaWxkKHRvb2x0aXApO1xuICAgICAgICB0b29sdGlwID0gbnVsbDsgdGltZXIgPSBudWxsO1xuICAgICAgfSxcbiAgICAgIGNyZWF0ZVRvb2xUaXAgPSBmdW5jdGlvbigpIHtcbiAgICAgICAgdGl0bGVTdHJpbmcgPSBlbGVtZW50W2dldEF0dHJpYnV0ZV0odGl0bGUpIHx8IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhVGl0bGUpIHx8IGVsZW1lbnRbZ2V0QXR0cmlidXRlXShkYXRhT3JpZ2luYWxUaXRsZSk7IC8vIHJlYWQgdGhlIHRpdGxlIGFnYWluXG4gICAgICAgIGlmICggIXRpdGxlU3RyaW5nIHx8IHRpdGxlU3RyaW5nID09IFwiXCIgKSByZXR1cm4gZmFsc2U7IC8vIGludmFsaWRhdGVcbiAgICAgICAgXG4gICAgICAgIHRvb2x0aXAgPSBET0NbY3JlYXRlRWxlbWVudF0oZGl2KTtcbiAgICAgICAgdG9vbHRpcFtzZXRBdHRyaWJ1dGVdKCdyb2xlJyxjb21wb25lbnQpO1xuICBcbiAgICAgICAgdmFyIHRvb2x0aXBBcnJvdyA9IERPQ1tjcmVhdGVFbGVtZW50XShkaXYpLCB0b29sdGlwSW5uZXIgPSBET0NbY3JlYXRlRWxlbWVudF0oZGl2KTtcbiAgICAgICAgdG9vbHRpcEFycm93W3NldEF0dHJpYnV0ZV0oY2xhc3NTdHJpbmcsIGNvbXBvbmVudCsnLWFycm93Jyk7IHRvb2x0aXBJbm5lcltzZXRBdHRyaWJ1dGVdKGNsYXNzU3RyaW5nLGNvbXBvbmVudCsnLWlubmVyJyk7XG4gIFxuICAgICAgICB0b29sdGlwW2FwcGVuZENoaWxkXSh0b29sdGlwQXJyb3cpOyB0b29sdGlwW2FwcGVuZENoaWxkXSh0b29sdGlwSW5uZXIpO1xuICBcbiAgICAgICAgdG9vbHRpcElubmVyW2lubmVySFRNTF0gPSB0aXRsZVN0cmluZztcbiAgXG4gICAgICAgIHNlbGZbY29udGFpbmVyXVthcHBlbmRDaGlsZF0odG9vbHRpcCk7XG4gICAgICAgIHRvb2x0aXBbc2V0QXR0cmlidXRlXShjbGFzc1N0cmluZywgY29tcG9uZW50ICsgJyAnICsgcGxhY2VtZW50U2V0dGluZyArICcgJyArIHNlbGZbYW5pbWF0aW9uXSk7XG4gICAgICB9LFxuICAgICAgdXBkYXRlVG9vbHRpcCA9IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgc3R5bGVUaXAoZWxlbWVudCx0b29sdGlwLHBsYWNlbWVudFNldHRpbmcsc2VsZltjb250YWluZXJdKTtcbiAgICAgIH0sXG4gICAgICBzaG93VG9vbHRpcCA9IGZ1bmN0aW9uICgpIHtcbiAgICAgICAgIWhhc0NsYXNzKHRvb2x0aXAsaW5DbGFzcykgJiYgKCBhZGRDbGFzcyh0b29sdGlwLGluQ2xhc3MpICk7XG4gICAgICB9LFxuICAgICAgLy8gdHJpZ2dlcnNcbiAgICAgIHNob3dUcmlnZ2VyID0gZnVuY3Rpb24oKSB7XG4gICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoZWxlbWVudCwgc2hvd25FdmVudCwgY29tcG9uZW50KTtcbiAgICAgICAgIWlzSUU4ICYmIG9uKCBnbG9iYWxPYmplY3QsIHJlc2l6ZUV2ZW50LCBzZWxmLmhpZGUsIHBhc3NpdmVIYW5kbGVyICk7ICAgICAgXG4gICAgICB9LFxuICAgICAgaGlkZVRyaWdnZXIgPSBmdW5jdGlvbigpIHtcbiAgICAgICAgIWlzSUU4ICYmIG9mZiggZ2xvYmFsT2JqZWN0LCByZXNpemVFdmVudCwgc2VsZi5oaWRlLCBwYXNzaXZlSGFuZGxlciApOyAgICAgIFxuICAgICAgICByZW1vdmVUb29sVGlwKCk7XG4gICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoZWxlbWVudCwgaGlkZGVuRXZlbnQsIGNvbXBvbmVudCk7XG4gICAgICB9O1xuICBcbiAgICAvLyBwdWJsaWMgbWV0aG9kc1xuICAgIHRoaXMuc2hvdyA9IGZ1bmN0aW9uKCkge1xuICAgICAgY2xlYXJUaW1lb3V0KHRpbWVyKTtcbiAgICAgIHRpbWVyID0gc2V0VGltZW91dCggZnVuY3Rpb24oKSB7XG4gICAgICAgIGlmICh0b29sdGlwID09PSBudWxsKSB7XG4gICAgICAgICAgcGxhY2VtZW50U2V0dGluZyA9IHNlbGZbcGxhY2VtZW50XTsgLy8gd2UgcmVzZXQgcGxhY2VtZW50IGluIGFsbCBjYXNlc1xuICAgICAgICAgIGlmKGNyZWF0ZVRvb2xUaXAoKSA9PSBmYWxzZSkgcmV0dXJuO1xuICAgICAgICAgIHVwZGF0ZVRvb2x0aXAoKTtcbiAgICAgICAgICBzaG93VG9vbHRpcCgpO1xuICAgICAgICAgIGJvb3RzdHJhcEN1c3RvbUV2ZW50LmNhbGwoZWxlbWVudCwgc2hvd0V2ZW50LCBjb21wb25lbnQpO1xuICAgICAgICAgICEhc2VsZlthbmltYXRpb25dID8gZW11bGF0ZVRyYW5zaXRpb25FbmQodG9vbHRpcCwgc2hvd1RyaWdnZXIpIDogc2hvd1RyaWdnZXIoKTtcbiAgICAgICAgfVxuICAgICAgfSwgMjAgKTtcbiAgICB9O1xuICAgIHRoaXMuaGlkZSA9IGZ1bmN0aW9uKCkge1xuICAgICAgY2xlYXJUaW1lb3V0KHRpbWVyKTtcbiAgICAgIHRpbWVyID0gc2V0VGltZW91dCggZnVuY3Rpb24oKSB7XG4gICAgICAgIGlmICh0b29sdGlwICYmIGhhc0NsYXNzKHRvb2x0aXAsaW5DbGFzcykpIHtcbiAgICAgICAgICBib290c3RyYXBDdXN0b21FdmVudC5jYWxsKGVsZW1lbnQsIGhpZGVFdmVudCwgY29tcG9uZW50KTtcbiAgICAgICAgICByZW1vdmVDbGFzcyh0b29sdGlwLGluQ2xhc3MpO1xuICAgICAgICAgICEhc2VsZlthbmltYXRpb25dID8gZW11bGF0ZVRyYW5zaXRpb25FbmQodG9vbHRpcCwgaGlkZVRyaWdnZXIpIDogaGlkZVRyaWdnZXIoKTtcbiAgICAgICAgfVxuICAgICAgfSwgc2VsZltkZWxheV0pO1xuICAgIH07XG4gICAgdGhpcy50b2dnbGUgPSBmdW5jdGlvbigpIHtcbiAgICAgIGlmICghdG9vbHRpcCkgeyBzZWxmLnNob3coKTsgfSBcbiAgICAgIGVsc2UgeyBzZWxmLmhpZGUoKTsgfVxuICAgIH07XG4gIFxuICAgIC8vIGluaXRcbiAgICBpZiAoICEoc3RyaW5nVG9vbHRpcCBpbiBlbGVtZW50KSApIHsgLy8gcHJldmVudCBhZGRpbmcgZXZlbnQgaGFuZGxlcnMgdHdpY2VcbiAgICAgIGVsZW1lbnRbc2V0QXR0cmlidXRlXShkYXRhT3JpZ2luYWxUaXRsZSx0aXRsZVN0cmluZyk7XG4gICAgICBlbGVtZW50LnJlbW92ZUF0dHJpYnV0ZSh0aXRsZSk7XG4gICAgICBvbihlbGVtZW50LCBtb3VzZUhvdmVyWzBdLCBzZWxmLnNob3cpO1xuICAgICAgb24oZWxlbWVudCwgbW91c2VIb3ZlclsxXSwgc2VsZi5oaWRlKTtcbiAgICB9XG4gICAgZWxlbWVudFtzdHJpbmdUb29sdGlwXSA9IHNlbGY7XG4gIH07XG4gIFxuICAvLyBUT09MVElQIERBVEEgQVBJXG4gIC8vID09PT09PT09PT09PT09PT09XG4gIHN1cHBvcnRzW3B1c2hdKCBbIHN0cmluZ1Rvb2x0aXAsIFRvb2x0aXAsICdbJytkYXRhVG9nZ2xlKyc9XCJ0b29sdGlwXCJdJyBdICk7XG4gIFxuICBcbiAgXHJcbiAgLyogTmF0aXZlIEphdmFzY3JpcHQgZm9yIEJvb3RzdHJhcCB8IEluaXRpYWxpemUgRGF0YSBBUElcclxuICAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSovXHJcbiAgdmFyIGluaXRpYWxpemVEYXRhQVBJID0gZnVuY3Rpb24oIGNvbnN0cnVjdG9yLCBjb2xsZWN0aW9uICl7XHJcbiAgICAgIGZvciAodmFyIGk9MCwgbD1jb2xsZWN0aW9uW2xlbmd0aF07IGk8bDsgaSsrKSB7XHJcbiAgICAgICAgbmV3IGNvbnN0cnVjdG9yKGNvbGxlY3Rpb25baV0pO1xyXG4gICAgICB9XHJcbiAgICB9LFxyXG4gICAgaW5pdENhbGxiYWNrID0gQlNOLmluaXRDYWxsYmFjayA9IGZ1bmN0aW9uKGxvb2tVcCl7XHJcbiAgICAgIGxvb2tVcCA9IGxvb2tVcCB8fCBET0M7XHJcbiAgICAgIGZvciAodmFyIGk9MCwgbD1zdXBwb3J0c1tsZW5ndGhdOyBpPGw7IGkrKykge1xyXG4gICAgICAgIGluaXRpYWxpemVEYXRhQVBJKCBzdXBwb3J0c1tpXVsxXSwgbG9va1VwW3F1ZXJ5U2VsZWN0b3JBbGxdIChzdXBwb3J0c1tpXVsyXSkgKTtcclxuICAgICAgfVxyXG4gICAgfTtcclxuICBcclxuICAvLyBidWxrIGluaXRpYWxpemUgYWxsIGNvbXBvbmVudHNcclxuICBET0NbYm9keV0gPyBpbml0Q2FsbGJhY2soKSA6IG9uKCBET0MsICdET01Db250ZW50TG9hZGVkJywgZnVuY3Rpb24oKXsgaW5pdENhbGxiYWNrKCk7IH0gKTtcclxuICBcbiAgcmV0dXJuIHtcbiAgICBBZmZpeDogQWZmaXgsXG4gICAgQWxlcnQ6IEFsZXJ0LFxuICAgIEJ1dHRvbjogQnV0dG9uLFxuICAgIENhcm91c2VsOiBDYXJvdXNlbCxcbiAgICBDb2xsYXBzZTogQ29sbGFwc2UsXG4gICAgRHJvcGRvd246IERyb3Bkb3duLFxuICAgIE1vZGFsOiBNb2RhbCxcbiAgICBQb3BvdmVyOiBQb3BvdmVyLFxuICAgIFNjcm9sbFNweTogU2Nyb2xsU3B5LFxuICAgIFRhYjogVGFiLFxuICAgIFRvb2x0aXA6IFRvb2x0aXBcbiAgfTtcbn0pKTtcbiJdfQ==
