!function t(e,i,n){function a(l,r){if(!i[l]){if(!e[l]){var s="function"==typeof require&&require;if(!r&&s)return s(l,!0);if(o)return o(l,!0);var c=new Error("Cannot find module '"+l+"'");throw c.code="MODULE_NOT_FOUND",c}var d=i[l]={exports:{}};e[l][0].call(d.exports,(function(t){return a(e[l][1][t]||t)}),d,d.exports,t,e,i,n)}return i[l].exports}for(var o="function"==typeof require&&require,l=0;l<n.length;l++)a(n[l]);return a}({1:[function(t,e,i){var n;(n="undefined"!=typeof $hx_scope?$hx_scope:$hx_scope={}).__registry__=Object.assign({},n.__registry__,{"bootstrap.native":t("bootstrap.native")})},{"bootstrap.native":2}],2:[function(t,e,i){(function(t){!function(t,i){if("function"==typeof define&&define.amd)define([],i);else if("object"==typeof e&&e.exports)e.exports=i();else{var n=i();t.Affix=n.Affix,t.Alert=n.Alert,t.Button=n.Button,t.Carousel=n.Carousel,t.Collapse=n.Collapse,t.Dropdown=n.Dropdown,t.Modal=n.Modal,t.Popover=n.Popover,t.ScrollSpy=n.ScrollSpy,t.Tab=n.Tab,t.Tooltip=n.Tooltip}}(this,(function(){"use strict";var e=void 0!==t?t:this||window,i=document,n=i.documentElement,a=e.BSN={},o=a.supports=[],l="data-toggle",r="onmouseleave"in i?["mouseenter","mouseleave"]:["mouseover","mouseout"],s="touchstart",c="touchend",d="active",u="left",f="top",p=!("opacity"in n.style),h=/\b(top|bottom|left|right)+/,g=0,m="navbar-fixed-top",b="WebkitTransition"in n.style||"Transition".toLowerCase()in n.style,v="WebkitTransition"in n.style?"Webkit".toLowerCase()+"TransitionEnd":"Transition".toLowerCase()+"end",y="WebkitDuration"in n.style?"Webkit".toLowerCase()+"TransitionDuration":"Transition".toLowerCase()+"Duration",A=function(t){t.focus?t.focus():t.setActive()},T=function(t,e){t.classList.add(e)},w=function(t,e){t.classList.remove(e)},x=function(t,e){return t.classList.contains(e)},k=function(t,e){return function(t){for(var e=[],i=0,n=t.length;i<n;i++)e.push(t[i]);return e}(t[p?"querySelectorAll":"getElementsByClassName"](p?"."+e.replace(/\s(?=[a-z])/g,"."):e))},N=function(t,e){return"object"==typeof t?t:(e||i).querySelector(t)},C=function(t,e){var n=e.charAt(0),a=e.substr(1);if("."===n){for(;t&&t!==i;t=t.parentNode)if(null!==N(e,t.parentNode)&&x(t,a))return t}else if("#"===n)for(;t&&t!==i;t=t.parentNode)if(t.id===a)return t;return!1},I=function(t,e,i,n){n=n||!1,t.addEventListener(e,i,n)},L=function(t,e,i,n){n=n||!1,t.removeEventListener(e,i,n)},E=function(t,e,i,n){I(t,e,(function a(o){i(o),L(t,e,a,n)}),n)},B=!!function(){var t=!1;try{var i=Object.defineProperty({},"passive",{get:function(){t=!0}});E(e,"testPassive",null,i)}catch(t){}return t}()&&{passive:!0},H=function(t){var i=b?e.getComputedStyle(t)[y]:0;return"number"!=typeof(i=parseFloat(i))||isNaN(i)?0:1e3*i},M=function(t,e){var i=0;H(t)?E(t,v,(function(t){!i&&e(t),i=1})):setTimeout((function(){!i&&e(),i=1}),17)},D=function(t,e,i){var n=new CustomEvent(t+".bs."+e);n.relatedTarget=i,this.dispatchEvent(n)},S=function(){return{y:e.pageYOffset||n.scrollTop,x:e.pageXOffset||n.scrollLeft}},W=function(t,e,a,o){var l,r,s,c,d=e.offsetWidth,p=e.offsetHeight,g=n.clientWidth||i.body.clientWidth,m=n.clientHeight||i.body.clientHeight,b=t.getBoundingClientRect(),v=o===i.body?S():{x:o.offsetLeft+o.scrollLeft,y:o.offsetTop+o.scrollTop},y=b.right-b.left,A=b.bottom-b.top,T=N('[class*="arrow"]',e),w=b.top+A/2-p/2<0,x=b.left+y/2-d/2<0,k=b.left+d/2+y/2>=g,C=b.top+p/2+A/2>=m,I=b.top-p<0,L=b.left-d<0,E=b.top+p+A>=m,B=b.left+d+y>=g;(a="right"===(a=(a="bottom"===(a=(a=(a===u||"right"===a)&&L&&B?f:a)===f&&I?"bottom":a)&&E?f:a)===u&&L?"right":a)&&B?u:a)===u||"right"===a?(r=a===u?b.left+v.x-d:b.left+v.x+y,w?(l=b.top+v.y,s=A/2):C?(l=b.top+v.y-p+A,s=p-A/2):l=b.top+v.y-p/2+A/2):a!==f&&"bottom"!==a||(l=a===f?b.top+v.y-p:b.top+v.y+A,x?(r=0,c=b.left+y/2):k?(r=g-1.01*d,c=d-(g-b.left)+y/2):r=b.left+v.x-d/2+y/2),e.style.top=l+"px",e.style.left=r+"px",s&&(T.style.top=s+"px"),c&&(T.style.left=c+"px"),-1===e.className.indexOf(a)&&(e.className=e.className.replace(h,a))};a.version="2.0.27";var R=function(t,a){a=a||{};var o=(t=N(t)).getAttribute("data-target"),l=t.getAttribute("data-offset-top"),r=t.getAttribute("data-offset-bottom"),s="affix",c="function";if(this.target=a.target?N(a.target):N(o)||null,this.offsetTop=a.offsetTop?a.offsetTop:parseInt(l)||0,this.offsetBottom=a.offsetBottom?a.offsetBottom:parseInt(r)||0,this.target||this.offsetTop||this.offsetBottom){var d,u,f,h,g,m=this,b=!1,v=!1,y=function(){b&&x(t,s)&&(w(t,s),b=!1)};this.update=function(){f=Math.max(i.body.scrollHeight,i.body.offsetHeight,n.clientHeight,n.scrollHeight,n.offsetHeight),h=parseInt(S().y,0),d=null!==m.target?m.target.getBoundingClientRect().top+h:m.offsetTop?parseInt(typeof m.offsetTop===c?m.offsetTop():m.offsetTop||0):void 0,u=function(){if(m.offsetBottom)return f-t.offsetHeight-parseInt(typeof m.offsetBottom===c?m.offsetBottom():m.offsetBottom||0)}(),g=parseInt(d)-h<0&&h>parseInt(d),parseInt(u)-h<0&&h>parseInt(u)?(g&&y(),v||x(t,"affix-bottom")||(D.call(t,s,s),D.call(t,"affix-bottom",s),T(t,"affix-bottom"),v=!0,D.call(t,"affixed",s),D.call(t,"affixed-bottom",s))):(v&&x(t,"affix-bottom")&&(w(t,"affix-bottom"),v=!1),g?b||x(t,s)||(D.call(t,s,s),D.call(t,"affix-top",s),T(t,s),b=!0,D.call(t,"affixed",s),D.call(t,"affixed-top",s)):y())},"Affix"in t||(I(e,"scroll",m.update,B),!p&&I(e,"resize",m.update,B)),t.Affix=m,m.update()}};o.push(["Affix",R,'[data-spy="affix"]']);var _=function(t){t=N(t);var e=this,i=C(t,".alert"),n=function(n){i=C(n.target,".alert"),(t=N('[data-dismiss="alert"]',i))&&i&&(t===n.target||t.contains(n.target))&&e.close()},a=function(){D.call(i,"closed","alert"),L(t,"click",n),i.parentNode.removeChild(i)};this.close=function(){i&&t&&x(i,"in")&&(D.call(i,"close","alert"),w(i,"in"),i&&(x(i,"fade")?M(i,a):a()))},"Alert"in t||I(t,"click",n),t.Alert=e};o.push(["Alert",_,'[data-dismiss="alert"]']);var O=function(t,e){t=N(t),e=e||null;var n=!1,a="checked",o=function(e){var i="LABEL"===e.target.tagName?e.target:"LABEL"===e.target.parentNode.tagName?e.target.parentNode:null;if(i){var o=k(i.parentNode,"btn"),l=i.getElementsByTagName("INPUT")[0];if(l){if("checkbox"===l.type&&(l.checked?(w(i,d),l.getAttribute(a),l.removeAttribute(a),l.checked=!1):(T(i,d),l.getAttribute(a),l.setAttribute(a,a),l.checked=!0),n||(n=!0,D.call(l,"change","button"),D.call(t,"change","button"))),"radio"===l.type&&!n&&(!l.checked||0===e.screenX&&0==e.screenY)){T(i,d),l.setAttribute(a,a),l.checked=!0,D.call(l,"change","button"),D.call(t,"change","button"),n=!0;for(var r=0,s=o.length;r<s;r++){var c=o[r],u=c.getElementsByTagName("INPUT")[0];c!==i&&x(c,d)&&(w(c,d),u.removeAttribute(a),u.checked=!1,D.call(u,"change","button"))}}setTimeout((function(){n=!1}),50)}}};if(x(t,"btn"))null!==e&&("reset"!==e?e&&"reset"!==e&&("loading"===e&&(T(t,"disabled"),t.setAttribute("disabled","disabled"),t.setAttribute("data-original-text",t.innerHTML.trim())),t.innerHTML=t.getAttribute("data-"+e+"-text")):t.getAttribute("data-original-text")&&((x(t,"disabled")||"disabled"===t.getAttribute("disabled"))&&(w(t,"disabled"),t.removeAttribute("disabled")),t.innerHTML=t.getAttribute("data-original-text")));else{"Button"in t||(I(t,"click",o),I(t,"keyup",(function(t){32===(t.which||t.keyCode)&&t.target===i.activeElement&&o(t)})),I(t,"keydown",(function(t){32===(t.which||t.keyCode)&&t.preventDefault()})));for(var l=k(t,"btn"),r=l.length,s=0;s<r;s++)!x(l[s],d)&&N("input",l[s]).getAttribute(a)&&T(l[s],d);t.Button=this}};o.push(["Button",O,'[data-toggle="buttons"]']);var P=function(t,i){i=i||{};var a=(t=N(t)).getAttribute("data-interval"),o=i.interval,l="false"===a?0:parseInt(a),f="hover"===t.getAttribute("data-pause")||!1,p="true"===t.getAttribute("data-keyboard")||!1;this.keyboard=!0===i.keyboard||p,this.pause=!("hover"!==i.pause&&!f)&&"hover",this.interval="number"==typeof o?o:!1===o||0===l||!1===l?0:isNaN(l)?5e3:l;var h=this,g=t.index=0,m=t.timer=0,v=!1,y=!1,A=null,C=null,E=null,H=k(t,"item"),S=H.length,W=this.direction=u,R=k(t,"carousel-control"),_=R[0],O=R[1],P=N(".carousel-indicators",t),z=P&&P.getElementsByTagName("LI")||[];if(!(S<2)){var q=function(){!1===h.interval||x(t,"paused")||(T(t,"paused"),!v&&(clearInterval(m),m=null))},j=function(){!1!==h.interval&&x(t,"paused")&&(w(t,"paused"),!v&&(clearInterval(m),m=null),!v&&h.cycle())},U=function(t){if(t.preventDefault(),!v){var e=t.currentTarget||t.srcElement;e===O?g++:e===_&&g--,h.slideTo(g)}},X=function(e){e(t,"touchmove",$,B),e(t,c,F,B)},$=function(t){if(y)return C=parseInt(t.touches[0].pageX),"touchmove"===t.type&&t.touches.length>1?(t.preventDefault(),!1):void 0;t.preventDefault()},F=function(e){if(y&&!v&&(E=C||parseInt(e.touches[0].pageX),y)){if((!t.contains(e.target)||!t.contains(e.relatedTarget))&&Math.abs(A-E)<75)return!1;C<A?g++:C>A&&g--,y=!1,h.slideTo(g),X(L)}},Y=function(t){for(var e=0,i=z.length;e<i;e++)w(z[e],d);z[t]&&T(z[t],d)};this.cycle=function(){m&&(clearInterval(m),m=null),m=setInterval((function(){var i,a;i=t.getBoundingClientRect(),a=e.innerHeight||n.clientHeight,i.top<=a&&i.bottom>=0&&(g++,h.slideTo(g))}),this.interval)},this.slideTo=function(e){if(!v){var i,n=this.getActiveIndex();n!==e&&(n<e||0===n&&e===S-1?W=h.direction=u:(n>e||n===S-1&&0===e)&&(W=h.direction="right"),e<0?e=S-1:e>=S&&(e=0),g=e,i=W===u?"next":"prev",D.call(t,"slide","carousel",H[e]),v=!0,clearInterval(m),m=null,Y(e),b&&x(t,"slide")?(T(H[e],i),H[e].offsetWidth,T(H[e],W),T(H[n],W),M(H[e],(function(a){var o=a&&a.target!==H[e]?1e3*a.elapsedTime+100:20;v&&setTimeout((function(){v=!1,T(H[e],d),w(H[n],d),w(H[e],i),w(H[e],W),w(H[n],W),D.call(t,"slid","carousel",H[e]),h.interval&&!x(t,"paused")&&h.cycle()}),o)}))):(T(H[e],d),H[e].offsetWidth,w(H[n],d),setTimeout((function(){v=!1,h.interval&&!x(t,"paused")&&h.cycle(),D.call(t,"slid","carousel",H[e])}),100)))}},this.getActiveIndex=function(){return H.indexOf(k(t,"item active")[0])||0},"Carousel"in t||(h.pause&&h.interval&&(I(t,r[0],q),I(t,r[1],j),I(t,s,q,B),I(t,c,j,B)),H.length>1&&I(t,s,(function(e){y||(A=parseInt(e.touches[0].pageX),t.contains(e.target)&&(y=!0,X(I)))}),B),O&&I(O,"click",U),_&&I(_,"click",U),P&&I(P,"click",(function(t){if(t.preventDefault(),!v){var e=t.target;if(!e||x(e,d)||!e.getAttribute("data-slide-to"))return!1;g=parseInt(e.getAttribute("data-slide-to"),10),h.slideTo(g)}})),h.keyboard&&I(e,"keydown",(function(t){if(!v){switch(t.which){case 39:g++;break;case 37:g--;break;default:return}h.slideTo(g)}}))),h.getActiveIndex()<0&&(H.length&&T(H[0],d),z.length&&Y(0)),h.interval&&h.cycle(),t.Carousel=h}};o.push(["Carousel",P,'[data-ride="carousel"]']);var z=function(t,e){t=N(t),e=e||{};var i,n,a,o,l,r=null,s=null,c=this,d=t.getAttribute("data-parent"),u=function(t,e){D.call(t,"hide","collapse"),t.isAnimating=!0,t.style.height=t.scrollHeight+"px",w(t,"collapse"),w(t,"in"),T(t,"collapsing"),t.offsetWidth,t.style.height="0px",M(t,(function(){t.isAnimating=!1,t.setAttribute("aria-expanded","false"),e.setAttribute("aria-expanded","false"),w(t,"collapsing"),T(t,"collapse"),t.style.height="",D.call(t,"hidden","collapse")}))};this.toggle=function(t){t.preventDefault(),x(s,"in")?c.hide():c.show()},this.hide=function(){s.isAnimating||(u(s,t),T(t,"collapsed"))},this.show=function(){var e,a;r&&(i=N(".collapse.in",r),n=i&&(N('[data-target="#'+i.id+'"]',r)||N('[href="#'+i.id+'"]',r))),(!s.isAnimating||i&&!i.isAnimating)&&(n&&i!==s&&(u(i,n),T(n,"collapsed")),a=t,D.call(e=s,"show","collapse"),e.isAnimating=!0,T(e,"collapsing"),w(e,"collapse"),e.style.height=e.scrollHeight+"px",M(e,(function(){e.isAnimating=!1,e.setAttribute("aria-expanded","true"),a.setAttribute("aria-expanded","true"),w(e,"collapsing"),T(e,"collapse"),T(e,"in"),e.style.height="",D.call(e,"shown","collapse")})),w(t,"collapsed"))},"Collapse"in t||I(t,"click",c.toggle),a=t.href&&t.getAttribute("href"),o=t.getAttribute("data-target"),l=a||o&&"#"===o.charAt(0)&&o,(s=l&&N(l)).isAnimating=!1,r=N(e.parent)||d&&C(t,d),t.Collapse=c};o.push(["Collapse",z,'[data-toggle="collapse"]']);var q=function(t,e){t=N(t),this.persist=!0===e||"true"===t.getAttribute("data-persist")||!1;var n=this,a=t.parentNode,o="open",r=null,s=N(".dropdown-menu",a),c=function(){for(var t=s.children,e=[],i=0;i<t.length;i++)t[i].children.length&&"A"===t[i].children[0].tagName&&e.push(t[i]);return e}(),d=function(t){(t.href&&"#"===t.href.slice(-1)||t.parentNode&&t.parentNode.href&&"#"===t.parentNode.href.slice(-1))&&this.preventDefault()},u=function(){var e=t.open?I:L;e(i,"click",f),e(i,"keydown",h),e(i,"keyup",g),e(i,"focus",f,!0)},f=function(e){var i=e.target,a=i&&(i.getAttribute(l)||i.parentNode&&"getAttribute"in i.parentNode&&i.parentNode.getAttribute(l));("focus"!==e.type||i!==t&&i!==s&&!s.contains(i))&&(i!==s&&!s.contains(i)||!n.persist&&!a)&&(r=i===t||t.contains(i)?t:null,b(),d.call(e,i))},p=function(e){r=t,m(),d.call(e,e.target)},h=function(t){var e=t.which||t.keyCode;38!==e&&40!==e||t.preventDefault()},g=function(e){var a=e.which||e.keyCode,o=i.activeElement,l=c.indexOf(o.parentNode),d=o===t,u=s.contains(o),f=o.parentNode.parentNode===s;f&&(l=d?0:38===a?l>1?l-1:0:40===a&&l<c.length-1?l+1:l,c[l]&&A(c[l].children[0])),(c.length&&f||!c.length&&(u||d)||!u)&&t.open&&27===a&&(n.toggle(),r=null)},m=function(){D.call(a,"show","dropdown",r),T(a,o),t.setAttribute("aria-expanded",!0),D.call(a,"shown","dropdown",r),t.open=!0,L(t,"click",p),setTimeout((function(){A(s.getElementsByTagName("INPUT")[0]||t),u()}),1)},b=function(){D.call(a,"hide","dropdown",r),w(a,o),t.setAttribute("aria-expanded",!1),D.call(a,"hidden","dropdown",r),t.open=!1,u(),A(t),setTimeout((function(){I(t,"click",p)}),1)};t.open=!1,this.toggle=function(){x(a,o)&&t.open?b():m()},"Dropdown"in t||(!1 in s&&s.setAttribute("tabindex","0"),I(t,"click",p)),t.Dropdown=n};o.push(["Dropdown",q,'[data-toggle="dropdown"]']);var j=function(t,a){var o=(t=N(t)).getAttribute("data-target")||t.getAttribute("href"),l=N(o),r=x(t,"modal")?t:l;if(x(t,"modal")&&(t=null),r){a=a||{},this.keyboard=!1!==a.keyboard&&"false"!==r.getAttribute("data-keyboard"),this.backdrop="static"!==a.backdrop&&"static"!==r.getAttribute("data-backdrop")||"static",this.backdrop=!1!==a.backdrop&&"false"!==r.getAttribute("data-backdrop")&&this.backdrop,this.animation=!!x(r,"fade"),this.content=a.content,r.isAnimating=!1;var s,c,d,u,f,p=this,h=null,v=k(n,m).concat(k(n,"navbar-fixed-bottom")),y=function(){var t,n=i.body.currentStyle||e.getComputedStyle(i.body),a=parseInt(n.paddingRight,10);if(s&&(i.body.style.paddingRight=a+c+"px",r.style.paddingRight=c+"px",v.length))for(var o=0;o<v.length;o++)t=(v[o].currentStyle||e.getComputedStyle(v[o])).paddingRight,v[o].style.paddingRight=parseInt(t)+c+"px"},C=function(){var t,a,o;s=i.body.clientWidth<(t=n.getBoundingClientRect(),e.innerWidth||t.right-Math.abs(t.left)),(o=i.createElement("div")).className="modal-scrollbar-measure",i.body.appendChild(o),a=o.offsetWidth-o.clientWidth,i.body.removeChild(o),c=a},E=function(){(d=N(".modal-backdrop"))&&null!==d&&"object"==typeof d&&(g=0,i.body.removeChild(d),d=null)},S=function(){A(r),r.isAnimating=!1,D.call(r,"shown","modal",h),I(e,"resize",p.update,B),I(r,"click",_),I(i,"keydown",R)},W=function(){r.style.display="",t&&A(t),D.call(r,"hidden","modal"),k(i,"modal in")[0]||(function(){if(i.body.style.paddingRight="",r.style.paddingRight="",v.length)for(var t=0;t<v.length;t++)v[t].style.paddingRight=""}(),w(i.body,"modal-open"),d&&x(d,"fade")?(w(d,"in"),M(d,E)):E(),L(e,"resize",p.update,B),L(r,"click",_),L(i,"keydown",R)),r.isAnimating=!1},R=function(t){if(!r.isAnimating){var e=t.which||t.keyCode;p.keyboard&&27==e&&x(r,"in")&&p.hide()}},_=function(t){if(!r.isAnimating){var e=t.target;x(r,"in")&&("modal"===e.parentNode.getAttribute("data-dismiss")||"modal"===e.getAttribute("data-dismiss")||e===r&&"static"!==p.backdrop)&&(p.hide(),h=null,t.preventDefault())}};this.toggle=function(){x(r,"in")?this.hide():this.show()},this.show=function(){x(r,"in")||r.isAnimating||(clearTimeout(f),f=setTimeout((function(){r.isAnimating=!0,D.call(r,"show","modal",h);var t,e=k(i,"modal in")[0];e&&e!==r&&("modalTrigger"in e&&e.modalTrigger.Modal.hide(),"Modal"in e&&e.Modal.hide()),p.backdrop&&!g&&!d&&(t=i.createElement("div"),null===(d=N(".modal-backdrop"))&&(t.setAttribute("class","modal-backdrop"+(p.animation?" fade":"")),d=t,i.body.appendChild(d)),g=1),d&&!x(d,"in")&&(d.offsetWidth,u=H(d),T(d,"in")),setTimeout((function(){r.style.display="block",C(),y(),T(i.body,"modal-open"),T(r,"in"),r.setAttribute("aria-hidden",!1),x(r,"fade")?M(r,S):S()}),b&&d&&u?u:1)}),1))},this.hide=function(){!r.isAnimating&&x(r,"in")&&(clearTimeout(f),f=setTimeout((function(){r.isAnimating=!0,D.call(r,"hide","modal"),d=N(".modal-backdrop"),u=d&&H(d),w(r,"in"),r.setAttribute("aria-hidden",!0),setTimeout((function(){x(r,"fade")?M(r,W):W()}),b&&d&&u?u:2)}),2))},this.setContent=function(t){N(".modal-content",r).innerHTML=t},this.update=function(){x(r,"in")&&(C(),y())},!t||"Modal"in t||I(t,"click",(function(e){if(!r.isAnimating){var i=e.target;(i=i.hasAttribute("data-target")||i.hasAttribute("href")?i:i.parentNode)!==t||x(r,"in")||(r.modalTrigger=t,h=t,p.show(),e.preventDefault())}})),p.content&&p.setContent(p.content),t?(t.Modal=p,r.modalTrigger=t):r.Modal=p}};o.push(["Modal",j,'[data-toggle="modal"]']);var U=function(t,n){t=N(t),n=n||{};var a=t.getAttribute("data-trigger"),o=t.getAttribute("data-animation"),l=t.getAttribute("data-placement"),s=t.getAttribute("data-dismissible"),c=t.getAttribute("data-delay"),d=t.getAttribute("data-container"),u='<button type="button" class="close">×</button>',h=N(n.container),g=N(d),b=C(t,".modal"),v=C(t,"."+m),y=C(t,".navbar-fixed-bottom");this.template=n.template?n.template:null,this.trigger=n.trigger?n.trigger:a||"hover",this.animation=n.animation&&"fade"!==n.animation?n.animation:o||"fade",this.placement=n.placement?n.placement:l||f,this.delay=parseInt(n.delay||c)||200,this.dismissible=!(!n.dismissible&&"true"!==s),this.container=h||g||v||y||b||i.body;var A=this,k=n.title||t.getAttribute("data-title")||null,E=n.content||t.getAttribute("data-content")||null;if(E||this.template){var H=null,S=0,R=this.placement,_=function(t){null!==H&&t.target===N(".close",H)&&A.hide()},O=function(n){"click"!=A.trigger&&"focus"!=A.trigger||!A.dismissible&&n(t,"blur",A.hide),A.dismissible&&n(i,"click",_),!p&&n(e,"resize",A.hide,B)},P=function(){O(I),D.call(t,"shown","popover")},z=function(){O(L),A.container.removeChild(H),S=null,H=null,D.call(t,"hidden","popover")};this.toggle=function(){null===H?A.show():A.hide()},this.show=function(){clearTimeout(S),S=setTimeout((function(){null===H&&(R=A.placement,function(){if(k=n.title||t.getAttribute("data-title"),E=(E=n.content||t.getAttribute("data-content"))?E.replace(/^\s+|\s+$/g,""):null,H=i.createElement("div"),null!==E&&null===A.template){if(H.setAttribute("role","tooltip"),null!==k){var e=i.createElement("h3");e.setAttribute("class","popover-title"),e.innerHTML=A.dismissible?k+u:k,H.appendChild(e)}var a=i.createElement("div"),o=i.createElement("div");a.setAttribute("class","arrow"),o.setAttribute("class","popover-content"),H.appendChild(a),H.appendChild(o),o.innerHTML=A.dismissible&&null===k?E+u:E}else{var l=i.createElement("div");A.template=A.template.replace(/^\s+|\s+$/g,""),l.innerHTML=A.template,H.innerHTML=l.firstChild.innerHTML}A.container.appendChild(H),H.style.display="block",H.setAttribute("class","popover "+R+" "+A.animation)}(),W(t,H,R,A.container),!x(H,"in")&&T(H,"in"),D.call(t,"show","popover"),A.animation?M(H,P):P())}),20)},this.hide=function(){clearTimeout(S),S=setTimeout((function(){H&&null!==H&&x(H,"in")&&(D.call(t,"hide","popover"),w(H,"in"),A.animation?M(H,z):z())}),A.delay)},"Popover"in t||("hover"===A.trigger?(I(t,r[0],A.show),A.dismissible||I(t,r[1],A.hide)):"click"!=A.trigger&&"focus"!=A.trigger||I(t,A.trigger,A.toggle)),t.Popover=A}};o.push(["Popover",U,'[data-toggle="popover"]']);var X=function(t,i){t=N(t);var n=N(t.getAttribute("data-target")),a=t.getAttribute("data-offset");if((i=i||{}).target||n){for(var o,l=i.target&&N(i.target)||n,r=l&&l.getElementsByTagName("A"),s=parseInt(i.offset||a)||10,c=[],u=[],f=t.offsetHeight<t.scrollHeight?t:e,h=f===e,g=0,m=r.length;g<m;g++){var b=r[g].getAttribute("href"),v=b&&"#"===b.charAt(0)&&"#"!==b.slice(-1)&&N(b);v&&(c.push(r[g]),u.push(v))}var y=function(e){var i=c[e].parentNode,n=u[e],a=C(i,".dropdown"),l=h&&n.getBoundingClientRect(),r=x(i,d)||!1,f=(h?l.top+o:n.offsetTop)-s,p=h?l.bottom+o-s:u[e+1]?u[e+1].offsetTop-s:t.scrollHeight,g=o>=f&&p>o;if(!r&&g)"LI"!==i.tagName||x(i,d)||(T(i,d),a&&!x(a,d)&&T(a,d),D.call(t,"activate","scrollspy",c[e]));else if(g){if(!g&&!r||r&&g)return}else"LI"===i.tagName&&x(i,d)&&(w(i,d),a&&x(a,d)&&!k(i.parentNode,d).length&&w(a,d))};this.refresh=function(){!function(){o=h?S().y:t.scrollTop;for(var e=0,i=c.length;e<i;e++)y(e)}()},"ScrollSpy"in t||(I(f,"scroll",this.refresh,B),!p&&I(e,"resize",this.refresh,B)),this.refresh(),t.ScrollSpy=this}};o.push(["ScrollSpy",X,'[data-spy="scroll"]']);var $=function(t,e){var i=(t=N(t)).getAttribute("data-height");e=e||{},this.height=!!b&&(e.height||"true"===i);var n,a,o,l,r,s,c,f=this,p=C(t,".nav"),h=!1,g=p&&N(".dropdown",p),m=function(){h.style.height="",w(h,"collapsing"),p.isAnimating=!1},v=function(){h?s?m():setTimeout((function(){h.style.height=c+"px",h.offsetWidth,M(h,m)}),50):p.isAnimating=!1,D.call(n,"shown","tab",a)},y=function(){h&&(o.style.float=u,l.style.float=u,r=o.scrollHeight),T(l,d),D.call(n,"show","tab",a),w(o,d),D.call(a,"hidden","tab",n),h&&(c=l.scrollHeight,s=c===r,T(h,"collapsing"),h.style.height=r+"px",h.offsetHeight,o.style.float="",l.style.float=""),x(l,"fade")?setTimeout((function(){T(l,"in"),M(l,v)}),20):v()};if(p){p.isAnimating=!1;var A=function(){var t,e=k(p,d);return 1!==e.length||x(e[0],"dropdown")?e.length>1&&(t=e[e.length-1]):t=e[0],t.getElementsByTagName("A")[0]},L=function(){return N(A().getAttribute("href"))};this.show=function(){l=N((n=n||t).getAttribute("href")),a=A(),o=L(),p.isAnimating=!0,w(a.parentNode,d),a.setAttribute("aria-expanded","false"),T(n.parentNode,d),n.setAttribute("aria-expanded","true"),g&&(x(t.parentNode.parentNode,"dropdown-menu")?x(g,d)||T(g,d):x(g,d)&&w(g,d)),D.call(a,"hide","tab",n),x(o,"fade")?(w(o,"in"),M(o,y)):y()},"Tab"in t||I(t,"click",(function(t){t.preventDefault(),n=t.currentTarget||this,!p.isAnimating&&!x(n.parentNode,d)&&f.show()})),f.height&&(h=L().parentNode),t.Tab=f}};o.push(["Tab",$,'[data-toggle="tab"]']);var F=function(t,n){n=n||{};var a=(t=N(t)).getAttribute("data-animation"),o=t.getAttribute("data-placement"),l=t.getAttribute("data-delay"),s=t.getAttribute("data-container"),c=N(n.container),d=N(s),u=C(t,".modal"),h=C(t,"."+m),g=C(t,".navbar-fixed-bottom");this.animation=n.animation&&"fade"!==n.animation?n.animation:a||"fade",this.placement=n.placement?n.placement:o||f,this.delay=parseInt(n.delay||l)||200,this.container=c||d||h||g||u||i.body;var b=this,v=0,y=this.placement,A=null,k=t.getAttribute("title")||t.getAttribute("data-title")||t.getAttribute("data-original-title");if(k&&""!=k){var E=function(){D.call(t,"shown","tooltip"),!p&&I(e,"resize",b.hide,B)},H=function(){!p&&L(e,"resize",b.hide,B),b.container.removeChild(A),A=null,v=null,D.call(t,"hidden","tooltip")};this.show=function(){clearTimeout(v),v=setTimeout((function(){if(null===A){if(y=b.placement,0==function(){if(!(k=t.getAttribute("title")||t.getAttribute("data-title")||t.getAttribute("data-original-title"))||""==k)return!1;(A=i.createElement("div")).setAttribute("role","tooltip");var e=i.createElement("div"),n=i.createElement("div");e.setAttribute("class","tooltip-arrow"),n.setAttribute("class","tooltip-inner"),A.appendChild(e),A.appendChild(n),n.innerHTML=k,b.container.appendChild(A),A.setAttribute("class","tooltip "+y+" "+b.animation)}())return;W(t,A,y,b.container),!x(A,"in")&&T(A,"in"),D.call(t,"show","tooltip"),b.animation?M(A,E):E()}}),20)},this.hide=function(){clearTimeout(v),v=setTimeout((function(){A&&x(A,"in")&&(D.call(t,"hide","tooltip"),w(A,"in"),b.animation?M(A,H):H())}),b.delay)},this.toggle=function(){A?b.hide():b.show()},"Tooltip"in t||(t.setAttribute("data-original-title",k),t.removeAttribute("title"),I(t,r[0],b.show),I(t,r[1],b.hide)),t.Tooltip=b}};o.push(["Tooltip",F,'[data-toggle="tooltip"]']);var Y=function(t,e){for(var i=0,n=e.length;i<n;i++)new t(e[i])},G=a.initCallback=function(t){t=t||i;for(var e=0,n=o.length;e<n;e++)Y(o[e][1],t.querySelectorAll(o[e][2]))};return i.body?G():I(i,"DOMContentLoaded",(function(){G()})),{Affix:R,Alert:_,Button:O,Carousel:P,Collapse:z,Dropdown:q,Modal:j,Popover:U,ScrollSpy:X,Tab:$,Tooltip:F}}))}).call(this,"undefined"!=typeof global?global:"undefined"!=typeof self?self:"undefined"!=typeof window?window:{})},{}]},{},[1]);
