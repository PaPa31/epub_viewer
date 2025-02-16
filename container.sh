#!/bin/sh
# generate_toc.sh - Create index.html with navigation and breadcrumbs for XHTML pages

set -x

# List all .xhtml files in order
pages=$(ls *.html *.xhtml 2>/dev/null | sort)

# Generate index.html with breadcrumbs
cat > index.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>EPUB Viewer</title>
  <style>
    iframe { width: 100%; height: 75vh; border: 1px solid #ccc; }
    nav, .breadcrumbs { margin-bottom: 10px; }
    button { padding: 5px 10px; margin-right: 5px; }
    .breadcrumbs { font-size: 0.9em; color: #555; }
  </style>
</head>
<body>
<nav>
  <button onclick="prevPage()">Previous</button>
  <button onclick="nextPage()">Next</button>
</nav>
<div class="breadcrumbs" id="breadcrumb"></div>
<iframe id="viewer"></iframe>
<script>
  const pages = [
$(for page in $pages; do echo "    '$page',"; done)
  ];
  let currentIndex = 0;
  function loadPage(index) {
    if (index >= 0 && index < pages.length) {
      document.getElementById('viewer').src = pages[index];
      var index2 = index + 1;
      document.getElementById('breadcrumb').innerText = 'Page ' + index2 + ' of ' + pages.length;
      currentIndex = index;
    }
  }
  function prevPage() { if (currentIndex > 0) loadPage(currentIndex - 1); }
  function nextPage() { if (currentIndex < pages.length - 1) loadPage(currentIndex + 1); }
  loadPage(0);
</script>
</body>
</html>
EOF

echo "index.html generated with breadcrumbs and navigation for XHTML pages."
