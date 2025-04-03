using System;
using System.Drawing;
using System.IO;
using SkiaSharp;
using SkiaSharp.Extended.Svg;
using SKSvg = SkiaSharp.SKSvg;

namespace SkiaSharpImageViewer
{
    public class SvgImageHandler : ImageLoader
    {
        protected override Image LoadImageInternal(string filePath)
        {
            if (!File.Exists(filePath))
            {
                throw new FileNotFoundException("SVG 파일을 찾을 수 없습니다.", filePath);
            }

            var svg = new SKSvg();
            try
            {
                using (var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read))
                {
                    Console.WriteLine("SVG 파일 스트림 로드 중...");
                    svg.Load(stream);
                    Console.WriteLine("SVG 파일 로드 완료.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"SVG 파일 로드 중 오류 발생: {ex.Message}");
                throw new Exception($"SVG 파일 로드 중 오류가 발생했습니다: {ex.Message}", ex);
            }

            // SVG Picture가 null인지 확인
            if (svg.Picture == null)
            {
                Console.WriteLine("SVG 파일을 올바르게 파싱할 수 없습니다. Picture가 null입니다.");
                throw new InvalidOperationException("SVG 파일을 올바르게 파싱할 수 없습니다. Picture가 null입니다.");
            }

            var svgSize = svg.Picture.CullRect.Size;
            int width = Math.Max((int)svgSize.Width, 1); // 최소 크기 보장
            int height = Math.Max((int)svgSize.Height, 1);
            Console.WriteLine($"SVG 크기: Width = {width}, Height = {height}");

            using (var surface = SKSurface.Create(new SKImageInfo(width, height)))
            {
                if (surface == null)
                {
                    throw new InvalidOperationException("SKSurface 생성 실패");
                }

                var canvas = surface.Canvas;
                canvas.Clear(SKColors.White); // 배경색 설정
                canvas.DrawPicture(svg.Picture); // SVG 그리기

                using (var image = surface.Snapshot())
                using (var data = image.Encode(SKEncodedImageFormat.Png, 100))
                using (var memStream = new MemoryStream())
                {
                    data.SaveTo(memStream);
                    memStream.Seek(0, SeekOrigin.Begin);

                    // 디버깅용 파일 저장
                    File.WriteAllBytes("output.png", memStream.ToArray());
                    Console.WriteLine("렌더링된 이미지를 output.png로 저장했습니다.");

                    return Image.FromStream(memStream);
                }
            }
        }
    }
}