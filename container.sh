#!/bin/sh
# generate_toc.sh - Create index.html with fixed error display and breadcrumb handling.

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
<div id="breadcrumb">Page 1</div>
<iframe id="viewer"></iframe>
<script>
  var pages = [
$pages
  ];
  var currentIndex = 0;

  function loadPage(index) {
    if (index >= 0 && index < pages.length) {
      var viewer = document.getElementById('viewer');
      viewer.src = pages[index];
      viewer.onerror = showError;
      viewer.onload = updateTitle;
      document.getElementById('breadcrumb').innerText = 'Loading...';
      document.getElementById('error').innerText = '';
      currentIndex = index;
    }
  }

  function simulateError() {
    var viewer = document.getElementById('viewer');
    viewer.removeAttribute('onload');
    viewer.src = 'about:blank';
    showError();
  }

  function updateTitle() {
    var pageNum = currentIndex + 1;
    document.getElementById('breadcrumb').innerText = 'Page ' + pageNum + ' of ' + pages.length;
  }

  function showError() {
    document.getElementById('error').innerText = 'Error loading page: ' + pages[currentIndex];
    document.getElementById('breadcrumb').innerText = 'Failed to load page';
  }

  function prevPage() { if (currentIndex > 0) loadPage(currentIndex - 1); }
  function nextPage() { if (currentIndex < pages.length - 1) loadPage(currentIndex + 1); }

  document.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowLeft') prevPage();
    if (e.key === 'ArrowRight') nextPage();
  });

  loadPage(0);
</script>
</body>
</html>
EOF

echo "index.html generated with corrected error handler and breadcrumb display."
