#!/bin/sh
# generate_toc.sh - Create index.html with enhancements (Optimized for eBox-2300sx, OpenWrt Backfire, BusyBox)

# List .xhtml and .html files, sorted alphabetically with error handling
pages=""
for page in $(ls *.xhtml *.html 2>/dev/null | sort); do
  [ -e "$page" ] && pages="$pages '$page',"
done

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
    #status { margin-top: 10px; font-size: 0.9em; }
    .error { color: red; font-size: 0.9em; }
  </style>
</head>
<body>
<nav>
  <button onclick="prevPage()">Previous</button>
  <button onclick="nextPage()">Next</button>
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
      document.getElementById('breadcrumb').innerText = 'Loading...';
      document.getElementById('error').innerText = '';
      viewer.src = pages[index];
      currentIndex = index;
      viewer.onload = updateTitle;
      viewer.onerror = showError;
    }
  }

  function updateTitle() {
    var frame = document.getElementById('viewer').contentDocument;
    var title = frame ? (frame.title || 'Untitled') : 'Untitled';
    var index2 = currentIndex + 1;
    document.getElementById('breadcrumb').innerText = 'Page ' + index2 + ' of ' + pages.length + ': ' + title;
    document.getElementById('status').innerText = 'Viewing page ' + index2 + ' of ' + pages.length;
  }

  function showError() {
    document.getElementById('error').innerText = 'Failed to load page: ' + pages[currentIndex];
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

echo "index.html generated with error handling and status display."
