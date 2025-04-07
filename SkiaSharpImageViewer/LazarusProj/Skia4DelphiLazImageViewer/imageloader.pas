unit ImageLoader;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, FPImage, FPCanvas, FPImgCanv;

type
  TImageLoader = class abstract
  private
    const MaxCacheSize = 50; // 최대 캐시 크기
    class var imageCache: TStringList; // 캐시 (파일 경로 -> TBitmap)

    // 가장 오래된 항목 제거 (FIFO)
    class procedure RemoveOldestFromCache;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    // 캐시에서 이미지 가져오기 시도
    function TryGetFromCache(const filePath: string; out cachedImage: TBitmap): Boolean;

    // 캐시에 이미지 추가
    procedure AddToCache(const filePath: string; image: TBitmap);

    // 이미지 로드 메서드
    function LoadImage(const filePath: string): TBitmap;

    // 추상 메서드: 하위 클래스에서 구현 필요
    protected function LoadImageInternal(const filePath: string): TBitmap; virtual; abstract;
  end;

implementation

{ TImageLoader }

constructor TImageLoader.Create;
begin
  if not Assigned(imageCache) then
    imageCache := TStringList.Create;
end;

destructor TImageLoader.Destroy;
var
  i: Integer;
begin
  if Assigned(imageCache) then
  begin
    for i := 0 to imageCache.Count - 1 do
      TObject(imageCache.Objects[i]).Free; // 객체 해제
    imageCache.Free;
  end;
  inherited Destroy;
end;

class procedure TImageLoader.RemoveOldestFromCache;
begin
  if imageCache.Count > 0 then
  begin
    TObject(imageCache.Objects[0]).Free; // 첫 번째 객체 해제
    imageCache.Delete(0); // 첫 번째 항목 삭제
  end;
end;

function TImageLoader.TryGetFromCache(const filePath: string; out cachedImage: TBitmap): Boolean;
var
  index: Integer;
begin
  index := imageCache.IndexOf(filePath);
  if index <> -1 then
  begin
    cachedImage := TBitmap(imageCache.Objects[index]);
    Result := True;
  end
  else
  begin
    cachedImage := nil;
    Result := False;
  end;
end;

procedure TImageLoader.AddToCache(const filePath: string; image: TBitmap);
begin
  if imageCache.Count >= MaxCacheSize then
    RemoveOldestFromCache;

  imageCache.AddObject(filePath, image);
end;

function TImageLoader.LoadImage(const filePath: string): TBitmap;
var
  cachedImage: TBitmap;
begin
  if TryGetFromCache(filePath, cachedImage) then
  begin
    Result := cachedImage;
    Exit;
  end;

  // 캐시에 없으면 새로운 이미지를 로드
  Result := LoadImageInternal(filePath);
  AddToCache(filePath, Result);
end;

end.
