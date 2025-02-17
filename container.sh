#!/bin/sh
# generate_toc.sh - EPUB Viewer with robust error detection (maximum backward compatibility)

# Collect .xhtml and .html files, sorted alphabetically
pages=""
for page in $(ls *.xhtml *.html 2>/dev/null | sort); do
  [ -e "$page" ] && pages="$pages '$page',"
done

# Add test page for error simulation
pages="$pages 'fake_page.xhtml',"

# Generate index.html
cat > index.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>EPUB Viewer</title>
  <style>
    iframe { width: 100%; height: 75vh; border: 1px solid #ccc; }
    nav { margin-bottom: 10px; }
    .error { color: red; }
    .loading { font-style: italic; color: #888; }
  </style>
</head>
<body>
<nav>
  <button onclick="prevPage()">Previous</button>
  <button onclick="nextPage()">Next</button>
  <button onclick="simulateError()">Simulate Error</button>
  <span id="status"></span>
  <span id="error" class="error"></span>
</nav>
<div id="breadcrumb" class="loading">Loading...</div>
<iframe id="viewer"></iframe>
<script>
  var pages = [
$pages
  ];
  var currentIndex = 0;

  function loadPage(index) {
    var viewer = document.getElementById('viewer');
    document.getElementById('error').innerHTML = '';
    document.getElementById('breadcrumb').innerHTML = 'Loading...';
    viewer.src = pages[index] || 'nonexistent.xhtml';
    currentIndex = index;
    setTimeout(checkPageError, 700);
  }

  function checkPageError() {
    var viewer = document.getElementById('viewer');
    var bodyContent = viewer.contentDocument ? viewer.contentDocument.body.innerHTML : '';
    if (/404|Not Found/i.test(bodyContent)) {
      triggerError(pages[currentIndex]);
    } else {
      document.getElementById('breadcrumb').innerHTML = 'Page ' + (currentIndex + 1);
    }
  }

  function simulateError() {
    triggerError('Simulated Error Page');
  }

  function triggerError(page) {
    document.getElementById('error').innerHTML = 'Error loading: ' + page;
    document.getElementById('breadcrumb').innerHTML = 'Failed to load page';
  }

  function prevPage() {
    currentIndex > 0 ? loadPage(currentIndex - 1) : triggerError('First page reached');
  }

  function nextPage() {
    currentIndex < pages.length - 1 ? loadPage(currentIndex + 1) : triggerError('Next page not found');
  }

  document.onkeydown = function(e) {
    var key = e ? e.keyCode : window.event.keyCode;
    if (key === 37) prevPage();
    if (key === 39) nextPage();
  };

  loadPage(0);
</script>
</body>
</html>
EOF

echo "index.html regenerated with advanced error detection for non-existent pages."
