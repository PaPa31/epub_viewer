#!/bin/sh
# generate_toc.sh - Create index.html to navigate XHTML pages

# List all .xhtml files in order
#pages=$(ls *.xhtml | sort)
pages=$(ls *.html *.xhtml 2>/dev/null | sort)

# Generate index.html
cat > index.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>EPUB Viewer</title>
  <style>
    iframe { width: 100%; height: 80vh; border: 1px solid #ccc; }
    nav { margin-bottom: 10px; }
    button { padding: 5px 10px; margin-right: 5px; }
  </style>
</head>
<body>
<nav>
  <button onclick="prevPage()">Previous</button>
  <button onclick="nextPage()">Next</button>
</nav>
<iframe id="viewer"></iframe>
<script>
  const pages = [
$(for page in $pages; do echo "    '$page',"; done)
  ];
  let currentIndex = 0;
  function loadPage(index) {
    if (index >= 0 && index < pages.length) {
      document.getElementById('viewer').src = pages[index];
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

echo "index.html generated with navigation for XHTML pages."
