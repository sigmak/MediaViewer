unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ImageLoader, RasterImageHandler, AnimatedImageHandler;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    viewer: TImage;
    procedure Button1Click(Sender: TObject);
    function IsAnimatedImage(const FilePath: string): Boolean;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  dlg: TOpenDialog;
  filePath, extension: string;
  loader: TImageLoader;
  animatedHandler :TAnimatedImageHandler;
  image: TBitmap;
begin
  // 파일 열기 대화 상자 생성
  dlg := TOpenDialog.Create(Self);
  try
    if dlg.Execute then
    begin
      filePath := dlg.FileName;
      extension := ExtractFileExt(filePath); // 파일 확장자 추출 (예: '.png')

      // 애니메이션 이미지인지 확인
      //if IsAnimatedImage(filePath) then
      if (extension='.gif') or (extension='.webp') then
      begin
        animatedHandler := TAnimatedImageHandler.Create;
        try
          animatedHandler.Animation(filePath, viewer);
        finally
          animatedHandler.Free;
        end;
      end
      else
      begin

        // 정적 이미지 처리
        loader := TRasterImageHandler.Create;
        try
          image := loader.LoadImage(filePath);
          try
            if Assigned(viewer.Picture) then
              viewer.Picture.Free;
            viewer.Picture := TPicture.Create;
            viewer.Picture.Bitmap.Assign(image);
            viewer.Refresh;
          finally
            image.Free;
          end;
        finally
          //loader.Free;  // 여기서 메모리 오류나서 일단은 주석처리..2025.04.07
        end;
      end;
    end;
  finally
    dlg.Free;
  end;
end;

function TForm1.IsAnimatedImage(const FilePath: string): Boolean;
var
  FileStream: TFileStream;
  //SkStream: ISkStream;
  //Codec: ISkCodec;
begin
  Result := False;
  FileStream := nil;
{
  try
    // 파일 스트림 열기
    FileStream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);

    // Skia 스트림 생성
    SkStream := TSkManagedStream.Create(FileStream);

    // 코덱 생성
    Codec := TSkCodec.MakeFromStream(SkStream);
    if Assigned(Codec) then
    begin
      // 프레임 수 확인 및 출력
      ShowMessage('codec.FrameCount = ' + IntToStr(Codec.FrameCount));
      Result := Codec.FrameCount > 1;
    end;
  finally
    // 리소스 정리
    if Assigned(FileStream) then
      FileStream.Free;
  end;
  }
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  viewer.Stretch:=true;
end;

end.

