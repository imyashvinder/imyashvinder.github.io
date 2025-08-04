#!/bin/bash

echo "=== Repository Optimization Script ==="
echo "Current repository size: $(du -sh . | cut -f1)"
echo ""

# Step 1: Remove HEIC files (saves ~13MB)
echo "Step 1: Removing HEIC files..."
rm -f blog/assets/images/*.HEIC
echo "✓ Removed HEIC files"

# Step 2: Replace large PNG with optimized WebP
echo "Step 2: Optimizing kl-start.png..."
if [ -f "blog/assets/images/kl-start-optimized.webp" ]; then
    mv blog/assets/images/kl-start-optimized.webp blog/assets/images/kl-start.webp
    rm -f blog/assets/images/kl-start.png
    echo "✓ Replaced kl-start.png with optimized WebP"
else
    echo "⚠️  Optimized WebP not found, keeping original PNG"
fi

# Step 3: Update blog post to remove HEIC references
echo "Step 3: Updating blog post..."
sed -i '' 's/\.HEIC/\.webp/g' blog/_posts/2025-07-10-welcome-to-my-blog.md
echo "✓ Updated blog post references"

# Step 4: Show results
echo ""
echo "=== Optimization Results ==="
echo "New repository size: $(du -sh . | cut -f1)"
echo "Images folder size: $(du -sh blog/assets/images/ | cut -f1)"
echo ""
echo "=== Remaining Files ==="
ls -lh blog/assets/images/ | grep -E "\.(avif|webp|jpg)$"

echo ""
echo "✅ Repository optimization complete!"
echo "📝 Don't forget to commit and push the changes:"
echo "   git add . && git commit -m 'Optimize repository size' && git push origin main" 