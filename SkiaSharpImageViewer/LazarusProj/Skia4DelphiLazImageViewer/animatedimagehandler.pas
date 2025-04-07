unit AnimatedImageHandler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Forms, Controls, Dialogs, ExtCtrls, StdCtrls,
  LCL.Skia, System.Skia,
  SyncObjs,
  libwebp, fpreadwebp, webpimage,
  LCLType,
  FPImage, FPReadGif,
  Types, System.UITypes, System.IOUtils,
  BGRABitmap, BGRABitmapTypes, BGRAAnimatedGif;

type
  { TAnimatedImageHandler }
  TAnimatedImageHandler = class
  private
    FBitmap: TBitmap;
    FImage: TImage;
    FWidth, FHeight: Integer;
    procedure LoadWebP(const AFileName: string);
    procedure LoadGIF(const FileName: string);
    function LoadFileToMemory(const AFileName: string; out ASize: Cardinal): PByte;
  public
    destructor Destroy; override;
    procedure Animation(const AFileName: string; const AImage: TImage);
  end;

implementation

{ TAnimatedImageHandler }

destructor TAnimatedImageHandler.Destroy;
begin
  FBitmap.Free;
  inherited Destroy;
end;

procedure TAnimatedImageHandler.Animation(const AFileName: string; const AImage: TImage);
var
  Ext: string;
begin
  if not Assigned(AImage) then
    raise Exception.Create('TImage가 할당되지 않았습니다.');

  FImage := AImage;

  Ext := LowerCase(ExtractFileExt(AFileName));
  try
    if Ext = '.webp' then
      LoadWebP(AFileName)
    else if Ext = '.gif' then
      LoadGIF(AFileName)
    else
      raise Exception.Create('지원되지 않는 파일 형식입니다.');
  except
    on E: Exception do
      ShowMessage('애니메이션 로드 중 오류가 발생했습니다: ' + E.Message);
  end;
end;

procedure InitializeBitmap(var Bitmap: TBitmap; Width, Height: Integer);
begin
  with Bitmap do
  begin
    SetSize(Width, Height);
    if RawImage.Description.BitsPerPixel <> 32 then
    begin
      RawImage.Description.Init_BPP32_B8G8R8A8_BIO_TTB(Width, Height);
      RawImage.CreateData(true);
    end;
  end;
end;

procedure TAnimatedImageHandler.LoadWebP(const AFileName: string);
var
  WebPData: PByte;
  WebPSize: Cardinal;
  Width, Height: Integer;
  Bitmap: TBitmap;
begin
  WebPData := nil;
  try
    // WebP 파일을 메모리로 로드
    WebPData := LoadFileToMemory(AFileName, WebPSize);
    if WebPData = nil then
      raise Exception.Create('WebP 파일 로드 실패');

    // WebP 이미지 크기 가져오기
    WebPGetInfo(WebPData, WebPSize, @Width, @Height);
    //if WebPGetInfo(WebPData, WebPSize, @Width, @Height) = 0 then
    //  raise Exception.Create('WebP 정보 가져오기 실패');

    // 비트맵 초기화
    Bitmap := TBitmap.Create;
    try
      Bitmap.PixelFormat := pf32bit; // 32비트 RGBA 형식으로 설정
      Bitmap.SetSize(Width, Height);

      // WebP 디코딩
      //if WebPDecodeRGBAInto(WebPData, WebPSize, PByte(Bitmap.RawImage.Data), Bitmap.RawImage.Description.BitsPerLine * Height, Width * 4) = 0 then
      //  raise Exception.Create('WebP 디코딩 실패');

      // TImage에 비트맵 설정
      FImage.Picture.Bitmap.Assign(Bitmap);
      // 화면 갱신
      FImage.Refresh;

      Application.ProcessMessages;
      Sleep(100); // 프레임 간격 지연
    finally
      Bitmap.Free;
    end;
  finally
    if WebPData <> nil then
      FreeMem(WebPData);
  end;
end;

procedure TAnimatedImageHandler.LoadGIF(const FileName: string);
var
  GIFImage2: TBGRAAnimatedGif;
  GIFImage: TFPMemoryImage;
  Reader: TFPReaderGIF;
  FrameIndex: Integer;
begin
  GIFImage2 := TBGRAAnimatedGif.Create;
  GIFImage2.LoadFromFile(FileName);
  GIFImage := TFPMemoryImage.Create(GIFImage2.Width, GIFImage2.Height);
  Reader := TFPReaderGIF.Create;
  try
    GIFImage.LoadFromFile(FileName, Reader);
    for FrameIndex := 0 to GIFImage2.Count - 1 do
    begin
      //Reader.CurrentFrame := FrameIndex;
      // GIF 이미지를 TImage에 복사
      FImage.Picture.Bitmap.Assign(GIFImage2.FrameImage[FrameIndex]);

      // 화면 갱신
      FImage.Refresh;

      Application.ProcessMessages;
      Sleep(20); // 프레임 간격 지연
    end;
  finally
    Reader.Free;
    GIFImage.Free;
    GIFImage2.Free;
  end;
end;

function TAnimatedImageHandler.LoadFileToMemory(const AFileName: string; out ASize: Cardinal): PByte;
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    ASize := FileStream.Size;
    GetMem(Result, ASize);
    FileStream.ReadBuffer(Result^, ASize);
  finally
    FileStream.Free;
  end;
end;

end.
