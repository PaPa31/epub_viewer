#!/bin/sh
# generate_toc.sh - Create index.html for XHTML pages (Optimized for eBox-2300sx, OpenWrt Backfire, BusyBox)

# List .xhtml files (POSIX-compliant)
pages=""
for page in *html; do
  pages="$pages '$page',"
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
  </style>
</head>
<body>
<nav>
  <button onclick="prevPage()">Previous</button>
  <button onclick="nextPage()">Next</button>
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
      currentIndex = index;
      viewer.onload = updateTitle;
    }
  }

  function updateTitle() {
    var frame = document.getElementById('viewer').contentDocument;
    var title = frame ? (frame.title || 'Untitled') : 'Untitled';
    var index2 = currentIndex + 1;
    document.getElementById('breadcrumb').innerText = 'Page ' + index2 + ' of ' + pages.length + ': ' + title;
  }

  function prevPage() { if (currentIndex > 0) loadPage(currentIndex - 1); }
  function nextPage() { if (currentIndex < pages.length - 1) loadPage(currentIndex + 1); }

  loadPage(0);
</script>
</body>
</html>
EOF

echo "index.html generated with page title in breadcrumb for XHTML pages."
