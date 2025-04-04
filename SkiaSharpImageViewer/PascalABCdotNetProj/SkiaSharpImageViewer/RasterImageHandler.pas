unit RasterImageHandler;

interface

uses System.Drawing, System.IO;
uses SkiaSharp, ImageLoader;

type
  RasterImageHandler2 = class(ImageLoader.ImageLoader2)
  protected
    function LoadImageInternal(filePath: string): Image; override;
  end;


implementation

function RasterImageHandler2.LoadImageInternal(filePath: string): Image;
  var 
    stream: FileStream;
    skStream: SKManagedStream;
    codec: SKCodec;
    bitmap: SKBitmap;
    image: SKImage;
    data: SKData;
    memStream: MemoryStream := nil;
begin

  try
    // 파일 스트림 열기
    stream := new FileStream(filePath, FileMode.Open);
    skStream := new SKManagedStream(stream);
    codec := SKCodec.Create(skStream);

    if codec = nil then
      raise new Exception('지원되지 않는 이미지 형식입니다.');

    // 이미지 정보 및 비트맵 생성
    var info := new SKImageInfo(codec.Info.Width, codec.Info.Height);
    bitmap := new SKBitmap(info);

    var result2 := codec.GetPixels(bitmap.Info, bitmap.GetPixels());
    if result2 <> SKCodecResult.Success then
      raise new Exception('이미지 디코딩 실패: ' + result.ToString);

    // SKImage로 변환 및 인코딩
    image := SKImage.FromBitmap(bitmap);
    data := image.Encode(SKEncodedImageFormat.Png, 100);

    memStream := new MemoryStream();
    data.SaveTo(memStream);
    memStream.Seek(0, SeekOrigin.Begin);

    // System.Drawing.Image로 변환
    Result := System.Drawing.Image.FromStream(memStream);
  
  finally
    // 리소스 정리
    if data <> nil then
      data.Dispose;
    if image <> nil then
      image.Dispose;
    if bitmap <> nil then
      bitmap.Dispose;
    if codec <> nil then
      codec.Dispose;
    if skStream <> nil then
      skStream.Dispose;
    if stream <> nil then
      stream.Dispose;
    if memStream <> nil then
      memStream.Dispose;
  end;
 end;    
end.