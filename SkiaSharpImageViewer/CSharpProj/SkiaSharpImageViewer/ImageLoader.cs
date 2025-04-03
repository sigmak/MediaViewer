using System;
using System.Collections.Generic;
using System.Drawing;

namespace SkiaSharpImageViewer
{
    public abstract class ImageLoader
    {
        protected static Dictionary<string, Image> imageCache = new Dictionary<string, Image>(); // 캐시
        private const int MaxCacheSize = 50; // 최대 캐시 크기

        public virtual Image LoadImage(string filePath)
        {
            if (TryGetFromCache(filePath, out var cachedImage))
            {
                return cachedImage;
            }

            var image = LoadImageInternal(filePath);
            AddToCache(filePath, image);
            return image;
        }

        protected bool TryGetFromCache(string filePath, out Image cachedImage)
        {
            return imageCache.TryGetValue(filePath, out cachedImage);
        }

        protected void AddToCache(string filePath, Image image)
        {
            if (imageCache.Count >= MaxCacheSize)
            {
                // 가장 오래된 항목 제거 (FIFO)
                var oldestKey = imageCache.Keys.GetEnumerator().Current;
                imageCache.Remove(oldestKey);
            }

            imageCache[filePath] = image;
        }

        protected abstract Image LoadImageInternal(string filePath);
    }
}
