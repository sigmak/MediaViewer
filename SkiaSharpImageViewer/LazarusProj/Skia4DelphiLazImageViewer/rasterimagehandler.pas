unit RasterImageHandler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics,
  ImageLoader,
  LCL.Skia, System.Skia,
  Types, System.UITypes, System.IOUtils;

  //Skia, Skia.Types, Skia.Codec, Skia.Image, ImageLoader;

  type
    TRasterImageHandler = class(TImageLoader)
    protected
      function LoadImageInternal(const filePath: string): TBitmap; override;
    end;

  implementation

  function TRasterImageHandler.LoadImageInternal(const filePath: string): TBitmap;
  var
    FileStream: TFileStream;
    Codec: ISkCodec;
    Surface: ISkSurface;
    Image: ISkImage;
    Data: TBytes;
    MemStream: TMemoryStream;
    Info : TSkImageInfo;
    Result2 : boolean;//TBitmap;
    RowBytes : byte;
    Pixels : Pointer;
    Picture : TPicture;
  begin
    Result := nil;
    FileStream := nil;
    MemStream := nil;

    try
      // 파일 스트림 열기
      FileStream := TFileStream.Create(filePath, fmOpenRead or fmShareDenyWrite);
{
      // 코덱 생성
      Codec := TSkCodec.MakeFromStream(FileStream);
      if not Assigned(Codec) then
        raise Exception.Create('지원되지 않는 이미지 형식입니다.');

      // 이미지 정보 및 서피스 생성
      Info := TSkImageInfo.Create(Codec.Width, Codec.Height, TSkColorType.RGBA8888, TSkAlphaType.Premul);
      Surface := TSkSurface.MakeRaster(Info);
      bitmap := SKBitmap(info);

      // 픽셀 데이터 디코딩
      RowBytes := Info.BytesPerPixel * Info.Width; //행당 바이트수 계산
      Pixels := Surface.GetCanvas.BaseProperties.PixelGeometry.;//Surface.PeekPixels; // 픽셀 데이터 포인터
      //if not Codec.GetPixels(Pixels, RowBytes, Info.ColorType, Info.AlphaType) then
      //  raise  Exception.Create('이미지 디코딩 실패: ');

      Result2 := Codec.GetPixels(Pixels, RowBytes, Info.ColorType, Info.AlphaType);
      //Result2 := Codec.GetPixels(Surface.PeekPixels.ImageInfo, Surface.PeekPixels,  );
      if Result2 <> true then //TSkCodecResult.Success
        raise Exception.Create('이미지 디코딩 실패: ' + Result2.ToString);
}
      // TSkImage로 변환 및 인코딩
      //Image := Surface.MakeImageSnapshot;
      Image := TSkImage.MakeFromEncodedFile(filePath);
      if not Assigned(Image) then
        raise Exception.Create('이미지를 로드할 수 없습니다.');
      Data := Image.Encode(TSkEncodedImageFormat.PNG, 100); // Image.EncodeToData(TSkEncodedImageFormat.PNG, 100);
      if Length(Data) = 0 then
        raise Exception.Create('이미지 인코딩 실패');
      // 메모리 스트림으로 저장
      MemStream := TMemoryStream.Create;
      MemStream.WriteBuffer(Data[0], Length(Data));
      MemStream.Position := 0;  // 스트림 위치 초기화

      // TBitmap으로 변환
      //Result := TBitmap.Create;
      //Result.LoadFromStream(MemStream);


        // TBitmap으로 변환
        Picture := TPicture.Create;
        try
          Picture.LoadFromStream(MemStream); // TPicture를 사용하여 다양한 형식 지원
          Result := TBitmap.Create;
          Result.Assign(Picture.Bitmap); // TBitmap으로 변환
        finally
          Picture.Free;
        end;



    finally
      // 리소스 정리
      if Assigned(MemStream) then
        MemStream.Free;
      if Assigned(FileStream) then
        FileStream.Free;
    end;
  end;

  end.
