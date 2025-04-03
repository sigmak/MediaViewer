using System;
using System.Drawing;
using System.IO;
using SkiaSharp;

namespace SkiaSharpImageViewer
{
    public class RasterImageHandler : ImageLoader
    {
        protected override Image LoadImageInternal(string filePath)
        {
            using (var stream = new FileStream(filePath, FileMode.Open))
            using (var skStream = new SKManagedStream(stream))
            using (var codec = SKCodec.Create(skStream))
            {
                if (codec == null)
                {
                    throw new Exception("지원되지 않는 이미지 형식입니다.");
                }

                var info = new SKImageInfo(codec.Info.Width, codec.Info.Height);
                using (var bitmap = new SKBitmap(info))
                {
                    var result = codec.GetPixels(bitmap.Info, bitmap.GetPixels());
                    if (result != SKCodecResult.Success)
                    {
                        throw new Exception($"이미지 디코딩 실패: {result}");
                    }

                    using (var image = SKImage.FromBitmap(bitmap))
                    using (var data = image.Encode(SKEncodedImageFormat.Png, 100))
                    using (var memStream = new MemoryStream())
                    {
                        data.SaveTo(memStream);
                        memStream.Seek(0, SeekOrigin.Begin);
                        return Image.FromStream(memStream);
                    }
                }
            }
        }
    }
}
