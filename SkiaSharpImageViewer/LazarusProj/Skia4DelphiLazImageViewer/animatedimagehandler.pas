unit AnimatedImageHandler;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, Graphics, Forms, Controls,Dialogs, ExtCtrls, StdCtrls,
    ImageLoader,
    LCL.Skia, System.Skia,
    Types, System.UITypes, System.IOUtils;
    //Skia, Skia.Types, Skia.Codec, Skia.Image, ImageLoader;

//  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
//  Skia, Skia.Types, Skia.Codec, Skia.Image, ImageLoader;

// 2025.04.07 gif, webp 애니메이션 기능은 skiaSharp 과 사용법이 달라서 아직은 구현 실패했음.
type
  ENotImplementedException = class(Exception)
  public
    constructor Create;
  end;

  TAnimatedImageHandler = class(TImageLoader)
  private
    FCodec: ISkCodec;
    FTargetImage: TImage;
    procedure LoadAnimationFrames;
  public
    procedure Animation(const FilePath: string; TargetImage: TImage);
  protected
    function LoadImageInternal(const FilePath: string): TBitmap; override;
  end;

implementation

{ ENotImplementedException }

constructor ENotImplementedException.Create;
begin
  inherited Create('이 메서드는 구현되지 않았습니다.');
end;

{ TAnimatedImageHandler }

procedure TAnimatedImageHandler.Animation(const FilePath: string; TargetImage: TImage);
var
  FileStream: TFileStream;
  //SkStream: TSkStream; //사용안됨
  //LAnimatedImage: SkAnimatedImage; // 사용안됨.
begin
  FTargetImage := TargetImage;
{
  try
    // 파일 스트림 열기
    FileStream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
    try
      //SkStream := TSKManagedStream.Create(FileStream);

      // 코덱 생성
      FCodec := TSkCodec.MakeFromStream(FileStream); //SkStream
      if not Assigned(FCodec) or ( StrToInt(FCodec.FrameCount) <= 1) then
      begin
        ShowMessage('지원되지 않는 애니메이션 형식입니다.');
        Exit;
      end;

      // 새로운 스레드에서 애니메이션 로드 시작
      TThread.CreateAnonymousThread(LoadAnimationFrames).Start;

    finally
      FileStream.Free;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('애니메이션 로드 중 오류가 발생했습니다: ' + E.Message);
    end;
  end;
  }
end;

procedure TAnimatedImageHandler.LoadAnimationFrames;
{
var
  CodecOptions: TSkCodecOptions;
  SkImageInfo: TSkImageInfo;
  SkBitmap: ISkBitmap;
  Image: ISkImage;
  Data: TBytes;
  MemStream: TMemoryStream;
  Bitmap: TBitmap;
  i: Integer;
  }
begin
  {
  try
    if FCodec.FrameCount > 1 then
    begin
      for i := 0 to FCodec.FrameCount - 1 do
      begin
        // 코덱 옵션 설정
        CodecOptions := TSkCodecOptions.Create(i);

        // 이미지 정보 및 비트맵 생성
        SkImageInfo := TSkImageInfo.Create(FCodec.Width, FCodec.Height, TSkColorType.RGBA8888, TSkAlphaType.Premul);
        SkBitmap := TSkBitmap.Create(SkImageInfo);

        // 픽셀 데이터 디코딩
        var Result2 := FCodec.GetPixels(SkBitmap.Info, SkBitmap.PeekPixels, CodecOptions);
        if Result2 <> TSkCodecResult.Success then
          raise Exception.Create('이미지 디코딩 실패: ' + Result2.ToString);

        // SKBitmap을 PNG 형식으로 인코딩
        Image := TSkImage.MakeFromBitmap(SkBitmap);
        Data := Image.EncodeToData(TSkEncodedImageFormat.PNG, 100);

        // 메모리 스트림으로 저장
        MemStream := TMemoryStream.Create;
        try
          MemStream.WriteBuffer(Data[0], Length(Data));
          MemStream.Position := 0;

          // TBitmap으로 변환
          Bitmap := TBitmap.Create;
          try
            Bitmap.LoadFromStream(MemStream);

            // UI 스레드에서 이미지 업데이트
            TThread.Synchronize(nil,
              procedure
              begin
                if Assigned(FTargetImage.Picture) then
                  FTargetImage.Picture.Free;
                FTargetImage.Picture := TPicture.Create;
                FTargetImage.Picture.Bitmap.Assign(Bitmap);
                FTargetImage.Refresh;
              end);

          finally
            Bitmap.Free;
          end;
        finally
          MemStream.Free;
        end;

        Sleep(10); // 10ms 동안 대기
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('애니메이션 처리 중 오류가 발생했습니다: ' + E.Message);
    end;
  end;
  }
end;

function TAnimatedImageHandler.LoadImageInternal(const FilePath: string): TBitmap;
begin
  raise ENotImplementedException.Create;
end;

end.
