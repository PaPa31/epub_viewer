#!/bin/sh
# generate_toc.sh - EPUB Viewer with error detection for non-existent pages (maximum backward compatibility).

# List .xhtml and .html files, sorted alphabetically
pages=""
for page in $(ls *.xhtml *.html 2>/dev/null | sort); do
  [ -e "$page" ] && pages="$pages '$page',"
done

# Add a fake page to simulate error
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
    button { padding: 5px 10px; }
    #status, #error { margin-top: 10px; font-size: 0.9em; }
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
<iframe id="viewer" onerror="triggerError('Iframe load failed')"></iframe>
<script>
  var pages = [
$pages
  ];
  var currentIndex = 0;

  function loadPage(index) {
    var viewer = document.getElementById('viewer');
    var errorSpan = document.getElementById('error');
    var breadcrumb = document.getElementById('breadcrumb');

    errorSpan.innerHTML = '';
    breadcrumb.innerHTML = 'Loading...';

    var pageUrl = pages[index] || 'nonexistent.xhtml';
    viewer.src = pageUrl;

    // Old JS compatibility: use onload/onerror directly
    viewer.onload = function() {
      breadcrumb.innerHTML = 'Page ' + (index + 1);
    };
    viewer.onerror = function() {
      triggerError(pageUrl);
    };
    currentIndex = index;
  }

  function simulateError() {
    triggerError('Simulated Error Page');
  }

  function triggerError(page) {
    document.getElementById('error').innerHTML = 'Error loading: ' + page;
    document.getElementById('breadcrumb').innerHTML = 'Failed to load page';
  }

  function prevPage() {
    if (currentIndex > 0) {
      loadPage(currentIndex - 1);
    } else {
      triggerError('First page reached');
    }
  }

  function nextPage() {
    if (currentIndex < pages.length - 1) {
      loadPage(currentIndex + 1);
    } else {
      triggerError('Next page not found');
    }
  }

  document.onkeydown = function(e) {
    var key = e ? e.keyCode : window.event.keyCode;
    if (key === 37) prevPage(); // Left arrow
    if (key === 39) nextPage(); // Right arrow
  };

  loadPage(0);
</script>
</body>
</html>
EOF

echo "index.html regenerated with maximum backward compatibility for old JavaScript."
