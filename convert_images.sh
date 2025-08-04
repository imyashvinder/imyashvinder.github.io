#!/bin/bash

# Script to convert images to AVIF format for the blog
# Usage: ./convert_images.sh [input_folder] [output_folder]

INPUT_FOLDER=${1:-"."}
OUTPUT_FOLDER=${2:-"blog/assets/images"}

# Create output folder if it doesn't exist
mkdir -p "$OUTPUT_FOLDER"

echo "Converting images to AVIF format..."
echo "Input folder: $INPUT_FOLDER"
echo "Output folder: $OUTPUT_FOLDER"
echo ""
echo "Supported input formats: HEIC, JPG, JPEG, PNG, WebP"
echo "Output formats: AVIF (primary), WebP (fallback)"
echo ""

# Convert HEIC files first (iPhone photos)
for file in "$INPUT_FOLDER"/*.{heic,HEIC}; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        name_without_ext="${filename%.*}"
        temp_jpg="$OUTPUT_FOLDER/${name_without_ext}_temp.jpg"
        output_file="$OUTPUT_FOLDER/${name_without_ext}.avif"
        
        echo "Converting HEIC $filename to AVIF..."
        
        # First convert HEIC to JPEG
        heif-convert "$file" "$temp_jpg"
        
        if [ $? -eq 0 ]; then
            # Then convert JPEG to AVIF
            avifenc -q 51 -a end-usage=q -a cq-level=23 "$temp_jpg" "$output_file"
            
            if [ $? -eq 0 ]; then
                echo "✓ Successfully converted $filename to $output_file"
                # Clean up temp file
                rm "$temp_jpg"
            else
                echo "✗ Failed to convert $filename to AVIF"
            fi
        else
            echo "✗ Failed to convert HEIC $filename to JPEG"
        fi
    fi
done

# Convert common image formats to AVIF (JPG, JPEG, PNG, WebP)
for file in "$INPUT_FOLDER"/*.{jpg,jpeg,png,webp}; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        name_without_ext="${filename%.*}"
        output_file="$OUTPUT_FOLDER/${name_without_ext}.avif"
        
        echo "Converting $filename to AVIF..."
        avifenc -q 51 -a end-usage=q -a cq-level=23 "$file" "$output_file"
        
        if [ $? -eq 0 ]; then
            echo "✓ Successfully converted $filename to $output_file"
        else
            echo "✗ Failed to convert $filename"
        fi
    fi
done

echo "Conversion complete!"
echo ""
echo "Creating WebP versions for better browser support..."

# Create WebP versions for all converted AVIF files
for avif_file in "$OUTPUT_FOLDER"/*.avif; do
    if [ -f "$avif_file" ]; then
        filename=$(basename "$avif_file")
        name_without_ext="${filename%.avif}"
        webp_file="$OUTPUT_FOLDER/${name_without_ext}.webp"
        
        # Find the original file to convert to WebP
        original_file=""
        for ext in jpg jpeg png heic HEIC; do
            if [ -f "$INPUT_FOLDER/${name_without_ext}.$ext" ]; then
                original_file="$INPUT_FOLDER/${name_without_ext}.$ext"
                break
            fi
        done
        
        if [ -n "$original_file" ]; then
            echo "Creating WebP version of $filename..."
            if [[ "$original_file" == *.heic ]] || [[ "$original_file" == *.HEIC ]]; then
                # Convert HEIC to JPEG first, then to WebP
                temp_jpg="$OUTPUT_FOLDER/${name_without_ext}_temp_webp.jpg"
                heif-convert "$original_file" "$temp_jpg"
                cwebp -q 80 "$temp_jpg" -o "$webp_file"
                rm "$temp_jpg"
            else
                cwebp -q 80 "$original_file" -o "$webp_file"
            fi
            
            if [ $? -eq 0 ]; then
                echo "✓ Created WebP version: $webp_file"
            else
                echo "✗ Failed to create WebP version of $filename"
            fi
        fi
    fi
done

echo ""
echo "✅ All conversions complete!"
echo ""
echo "Your images are ready to use in your blog post:"
echo "- AVIF files: /blog/assets/images/[filename].avif"
echo "- WebP files: /blog/assets/images/[filename].webp"
echo "- Fallback JPEGs: Use your original files"
echo ""
echo "The blog post is already configured to use these optimized images!" 