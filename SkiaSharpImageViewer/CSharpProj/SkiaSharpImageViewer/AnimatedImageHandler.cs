using System;
using System.Drawing;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Forms;
using SkiaSharp;

namespace SkiaSharpImageViewer
{
    public class AnimatedImageHandler : ImageLoader
    {
        private SKCodec codec;
        private PictureBox pictureBox;

        public override Image LoadImage(string filePath)
        {
            throw new NotSupportedException("AnimatedImageHandler는 단일 이미지를 반환하지 않습니다. StartAnimation 메서드를 사용하세요.");
        }

        public async void Animation(string filePath, PictureBox targetPictureBox)
        {
            this.pictureBox = targetPictureBox;

            try
            {
                // 파일을 메모리로 로드
                byte[] fileBytes;
                using (var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read))
                {
                    fileBytes = new byte[stream.Length];
                    stream.Read(fileBytes, 0, fileBytes.Length);
                }

                // 메모리 스트림 생성
                using (var memoryStream = new MemoryStream(fileBytes))
                using (var skStream = new SKManagedStream(memoryStream))
                {
                    codec = SKCodec.Create(skStream);
                    if (codec == null || codec.FrameCount <= 1)
                    {
                        throw new Exception("지원되지 않는 애니메이션 형식입니다.");
                    }

                    if (codec.FrameCount > 1)
                    {
                        // 움직이는 영상(애니메이션 GIF/WebP) 처리
                        //MessageBox.Show("현재 애니메이션 이미지는 지원되지 않습니다.", "정보", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        //return;
                        for (int i = 0; i < codec.FrameCount; i++)
                        {
                            SKCodecOptions codecOptions = new SKCodecOptions(i);
                            SKImageInfo skImageInfo = new SKImageInfo(codec.Info.Width, codec.Info.Height);
                            using (SKBitmap skBitmap = new SKBitmap(skImageInfo))
                            {
                                // GetPixels을 사용하여 이미지 데이터 디코딩
                                var result = codec.GetPixels(skBitmap.Info, skBitmap.GetPixels(), codecOptions);
                                if (result != SKCodecResult.Success)
                                {
                                    throw new Exception($"이미지 디코딩 실패: {result}");
                                }

                                // SKBitmap을 System.Drawing.Bitmap으로 직접 변환
                                using (var image = SKImage.FromBitmap(skBitmap))
                                using (var data = image.Encode(SKEncodedImageFormat.Png, 100))
                                {
                                    byte[] buffer = data.ToArray();
                                    using (var memStream = new MemoryStream(buffer))
                                    {
                                        var bitmap = new Bitmap(memStream);
                                        pictureBox.Image?.Dispose(); // 이전 이미지 리소스 해제
                                        pictureBox.Image = bitmap;
                                        pictureBox.Refresh(); // 화면 갱신

                                    }
                                }
                            }
                            // 애니메이션 딜레이 (필요시 실제 프레임 딜레이 사용)
                            //Thread.Sleep(10);
                            await Task.Delay(1); // 2025-04-03 추가2

                        }

                    }

                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"애니메이션 로드 중 오류가 발생했습니다: {ex.Message}", "오류", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        protected override Image LoadImageInternal(string filePath)
        {
            throw new NotImplementedException();
        }


    }
}