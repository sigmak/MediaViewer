unit AnimatedImageHandler;

interface

uses System.Drawing, System.IO, System.Threading.Tasks, System.Windows.Forms;
uses SkiaSharp, ImageLoader;



type
  // NotImplementedException 정의
  NotImplementedException = class(Exception)
  public
    constructor Create;
    begin
      inherited Create('이 메서드는 구현되지 않았습니다.');
    end;
  end;
  
  AnimatedImageHandler2 = class(ImageLoader.ImageLoader2)
  private
    codec: SKCodec;
    pictureBox: PictureBox;
  public
    procedure Animation(filePath: string; targetPictureBox: System.Windows.Forms.PictureBox);
    procedure LoadImage;
  protected
    function LoadImageInternal(filePath: string): Image; override;
  end;
  
  
implementation    
    
    // 단일 이미지 로드는 지원되지 않음
{    
    function LoadImage(filePath: string): Image; //override;
    begin
      raise new NotSupportedException('AnimatedImageHandler는 단일 이미지를 반환하지 않습니다. StartAnimation 메서드를 사용하세요.');
    end;
}
procedure AnimatedImageHandler2.LoadImage;
var
  codecOptions : SKCodecOptions;
  stream2 : System.IO.Stream;
  //svg :SkiaSharp.Extended.Svg.SKSvg;   
begin
  try
    if codec.FrameCount > 1 then
    begin
      for var i := 0 to codec.FrameCount - 1 do
      begin
        codecOptions := new SKCodecOptions(i);
        var skImageInfo := new SKImageInfo(codec.Info.Width, codec.Info.Height);
        var skBitmap := new SKBitmap(skImageInfo); 
        // GetPixels을 사용하여 이미지 데이터 디코딩
        var result2 := codec.GetPixels(skBitmap.Info, skBitmap.GetPixels(), codecOptions);
        if result2 <> SKCodecResult.Success then
          raise new Exception('이미지 디코딩 실패: ' + result2.ToString);

        // SKBitmap을 System.Drawing.Bitmap으로 직접 변환
        var image := SKImage.FromBitmap(skBitmap);
        var data := image.Encode(SKEncodedImageFormat.Png, 100); 
        var buffer := data.ToArray;
        var memStream := new MemoryStream(buffer); 
        var bitmap := new Bitmap(memStream);
        //    if self.pictureBox.Image<> nil then
        //       self.pictureBox.Image.Dispose; // 이전 이미지 리소스 해제
        self.pictureBox.Image := bitmap;
        self.pictureBox.Refresh; // 화면 갱신
        
        Sleep(10); // 10ms 동안 대기
      end;
   end;

  except
    on ex: System.Exception do
    begin
      MessageBox.Show('애니메이션 로드 중 오류가 발생했습니다: ' + ex.Message, '오류', MessageBoxButtons.OK, MessageBoxIcon.Error);
    end;
  end;    
  
end;  

// 애니메이션 시작 메서드
procedure AnimatedImageHandler2.Animation(filePath: string; targetPictureBox: System.Windows.Forms.PictureBox);
var
  fileBytes: array of byte;
  stream : System.IO.Stream;
  task: System.Threading.Thread; // 추가
begin
  self.pictureBox := targetPictureBox;

  try
    // 파일을 메모리로 로드
    stream := System.IO.File.Open(filePath, System.IO.FileMode.Open, FileAccess.Read);  
    var skStream := new SKManagedStream(stream);
    
    codec := SKCodec.Create(skStream);
    if (codec = nil) or (codec.FrameCount<=1) then 
    begin
      MessageBox.Show('지원되지 않는 애니메이션 형식입니다.');
      exit;
    end;        
   // 새로운 스레드를 생성하여 비동기 작업 실행
   task := new System.Threading.Thread(System.Threading.ThreadStart(LoadImage));
   task.Start();   
   
  except
    on ex: System.Exception do
    begin
      MessageBox.Show('애니메이션 로드 중 오류가 발생했습니다: ' + ex.Message, '오류', MessageBoxButtons.OK, MessageBoxIcon.Error);
    end;
  end;
end;

function AnimatedImageHandler2.LoadImageInternal(filePath: string): Image; //override;
begin
  raise new NotImplementedException;
end;    


end.