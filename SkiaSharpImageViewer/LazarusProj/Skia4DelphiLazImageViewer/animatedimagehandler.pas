unit AnimatedImageHandler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Forms, Controls, Dialogs, ExtCtrls, StdCtrls,
  LCL.Skia, System.Skia,
  SyncObjs,
  libwebp, //fpreadwebp, webpimage,
  LCLType,
  FPImage, FPReadGif,
  Types, System.UITypes, System.IOUtils,
  BGRABitmap, BGRABitmapTypes, BGRAAnimatedGif;

type
  { TAnimatedImageHandler }
  TAnimatedImageHandler = class
  private
    FImage: TImage;
    procedure LoadWebP(const AFileName: string);
    procedure LoadGIF(const AFileName: string);
    function LoadFileToMemory(const AFileName: string; out ASize: Cardinal): PByte;
  public
    destructor Destroy; override;
    procedure Animation(const AFileName: string; const AImage: TImage);
  end;

implementation

{ TAnimatedImageHandler }

destructor TAnimatedImageHandler.Destroy;
begin
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


procedure TAnimatedImageHandler.LoadGIF(const AFileName: string);
var
  GIF: TBGRAAnimatedGif;
  FrameIndex: Integer;
  Bmp: TBitmap;
  BGRA: TBGRABitmap;
const
  DefaultDelay = 100; // ms, 보통 10fps
begin
  GIF := TBGRAAnimatedGif.Create;
  try
    GIF.LoadFromFile(AFileName);

    for FrameIndex := 0 to GIF.Count - 1 do
    begin
      BGRA := GIF.FrameImage[FrameIndex];
      Bmp := TBitmap.Create;
      try
        Bmp.SetSize(BGRA.Width, BGRA.Height);
        Bmp.PixelFormat := pf32bit;

        // BGRA → TBitmap 변환
        BGRA.Draw(Bmp.Canvas, 0, 0, True);

        // TImage에 표시
        FImage.Picture.Assign(Bmp);
        FImage.Refresh;

        Application.ProcessMessages;
        Sleep(DefaultDelay); // 고정 딜레이 사용
      finally
        Bmp.Free;
      end;
    end;
  finally
    GIF.Free;
  end;
end;




procedure TAnimatedImageHandler.LoadWebP(const AFileName: string);
var
  WebPData: PByte;
  WebPSize: Cardinal;
  Width, Height: Integer;
  RawData: PByte;
  Bitmap: TBitmap;
begin
  WebPData := nil;
  try
    WebPData := LoadFileToMemory(AFileName, WebPSize);
    if WebPData = nil then
      raise Exception.Create('WebP 파일 로드 실패');

    if WebPGetInfo(WebPData, WebPSize, @Width, @Height) = 0 then
      raise Exception.Create('WebP 정보 파싱 실패');

    GetMem(RawData, Width * Height * 4);
    try
      if WebPDecodeRGBAInto(WebPData, WebPSize, RawData, Width * Height * 4, Width * 4) = nil then
        raise Exception.Create('WebP 디코딩 실패');

      Bitmap := TBitmap.Create;
      try
        Bitmap.PixelFormat := pf32bit;
        Bitmap.SetSize(Width, Height);
        Move(RawData^, Bitmap.RawImage.Data^, Width * Height * 4);

        FImage.Picture.Bitmap.Assign(Bitmap);
        FImage.Refresh;
      finally
        Bitmap.Free;
      end;
    finally
      FreeMem(RawData);
    end;
  finally
    FreeMem(WebPData);
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

