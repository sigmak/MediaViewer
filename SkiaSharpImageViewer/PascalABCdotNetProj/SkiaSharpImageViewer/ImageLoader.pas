unit ImageLoader;

uses System.Drawing;

var
  imageCache: Dictionary<string, Image>; // 전역 변수로 캐시 선언
  
type
  ImageLoader2 = abstract class
  private
    const MaxCacheSize = 50; // 최대 캐시 크기
    //class var imageCache: Dictionary<string, Image>; // 캐시
    
    // 가장 오래된 항목 제거 (FIFO)
    class procedure RemoveOldestFromCache;
    begin
      var oldestKey := imageCache.Keys.First;
      imageCache.Remove(oldestKey);
    end;
    
  public
    constructor;
    begin
      if imageCache = nil then
        imageCache := new Dictionary<string, Image>;
    end;
    
    // 캐시에서 이미지 가져오기 시도
    function TryGetFromCache(filePath: string; var cachedImage: Image): boolean;
    begin
      Result := imageCache.TryGetValue(filePath, cachedImage);
    end;
    
    // 캐시에 이미지 추가
    procedure AddToCache(filePath: string; image: Image);
    begin
      if imageCache.Count >= MaxCacheSize then
        RemoveOldestFromCache;
      
      imageCache[filePath] := image;
    end;
    
    // 이미지 로드 메서드
    function LoadImage(filePath: string): Image;
    var
      cachedImage: Image;
    begin
      if TryGetFromCache(filePath, cachedImage) then
      begin
        Result := cachedImage;
        exit;
      end;
      
      var loadedImage := LoadImageInternal(filePath);
      AddToCache(filePath, loadedImage);
      Result := loadedImage;
    end;
    
    // 추상 메서드: 하위 클래스에서 구현 필요
    protected function LoadImageInternal(filePath: string): Image; abstract;
  end;
  
  begin
    
  
  end.