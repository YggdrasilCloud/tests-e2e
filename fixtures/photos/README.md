# Test Photos Fixtures

This directory contains sample photos used for E2E testing.

## Adding Test Photos

Place sample images here that will be used by the seed script.

Recommended test images:
- `sample1.jpg` - Standard JPEG photo
- `sample2.png` - PNG image
- `sample3.webp` - WebP image
- `sample4.gif` - GIF image

## Image Requirements

- Max size: 20 MB (per UploadConfiguration)
- Allowed types: JPEG, PNG, GIF, WebP
- Dimensions: Any (will be resized/thumbnailed by backend)

## Git LFS (Optional)

If you want to version control actual test images, consider using Git LFS:

```bash
git lfs install
git lfs track "*.jpg" "*.png" "*.webp" "*.gif"
git add .gitattributes
```

## Generating Test Images

You can use placeholder services during development:

```bash
# Download sample images
curl -o sample1.jpg "https://picsum.photos/800/600"
curl -o sample2.png "https://picsum.photos/1024/768"
curl -o sample3.webp "https://picsum.photos/640/480"
```

Or create simple colored squares:

```bash
# Using ImageMagick
convert -size 800x600 xc:blue sample1.jpg
convert -size 1024x768 xc:green sample2.png
convert -size 640x480 xc:red sample3.webp
```

## Usage in Seed Script

The backend seed command should:
1. Read images from this directory
2. Create test folders
3. Upload images to test folders
4. Generate thumbnails and metadata

Example seed logic:

```php
// In backend: src/Command/SeedTestDataCommand.php
$fixturesDir = '/app/fixtures/photos';
$photos = glob("$fixturesDir/*.{jpg,png,webp,gif}", GLOB_BRACE);

foreach ($photos as $photoPath) {
    // Upload to folder
    $this->photoService->upload($folderId, $photoPath);
}
```
