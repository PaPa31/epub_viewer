#!/bin/sh
# generate_toc.sh - EPUB Viewer with error detection for non-existent pages.

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
<iframe id="viewer"></iframe>
<script>
  var pages = [
$pages
  ];
  var currentIndex = 0;

  function loadPage(index) {
    var viewer = document.getElementById('viewer');
    var errorSpan = document.getElementById('error');
    var breadcrumb = document.getElementById('breadcrumb');

    errorSpan.innerText = '';
    breadcrumb.innerText = 'Loading...';

    var pageUrl = pages[index] || 'nonexistent.xhtml';
    fetch(pageUrl)
      .then(response => {
        if (!response.ok) {
          throw new Error('Page not found: ' + pageUrl);
        }
        viewer.src = pageUrl;
        breadcrumb.innerText = 'Page ' + (index + 1);
      })
      .catch(error => {
        triggerError(pageUrl);
      });

    currentIndex = index;
  }

  function simulateError() {
    triggerError('Simulated Error Page');
  }

  function triggerError(page) {
    document.getElementById('error').innerText = 'Error loading: ' + page;
    document.getElementById('breadcrumb').innerText = 'Failed to load page';
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

  document.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowLeft') prevPage();
    if (e.key === 'ArrowRight') nextPage();
  });

  loadPage(0);
</script>
</body>
</html>
EOF

echo "index.html regenerated with real-time error detection for navigation."
