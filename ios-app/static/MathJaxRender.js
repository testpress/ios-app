// Render MathJax into elements
var mathElements = document.getElementsByClassName('math-tex');
for (var i = 0; i < mathElements.length; i++) {
   if (typeof renderMathInElement !== 'undefined') {
      renderMathInElement(mathElements.item(i));
  }
}
