Unit Unit1;

interface

uses System, System.Drawing, System.Windows.Forms;
uses SkiaSharp,  SkiaSharp.Extended.Svg ;
uses ImageLoader, RasterImageHandler, AnimatedImageHandler;

type
  Form1 = class(Form)
    viewer: PictureBox;
    btnOpen: Button;
    procedure InitializeComponents();
    procedure btnOpen_Click(sender: Object; e: EventArgs);  
    function IsAnimatedImage(filePath: string): boolean;
    procedure Form1_Load(sender: Object; e: EventArgs);
  {$region FormDesigner}
  internal
    {$resource Unit1.Form1.resources}
    {$include Unit1.Form1.inc}
  {$endregion FormDesigner}
  public
    constructor;
    begin
      InitializeComponent;
      InitializeComponents;
    end;
  end;

implementation

procedure Form1.InitializeComponents();
begin
  
  //Form1
  self.ClientSize := new System.Drawing.Size(600, 520);
  self.Text := 'ImageViewer with SkiaSharp : PascalABC.net';  
  //
  // viewer
  //
  viewer := new PictureBox;
  viewer.Location := new System.Drawing.Point(5, 5);
  viewer.Size := new System.Drawing.Size(500, 500);
  viewer.Dock := System.Windows.Forms.DockStyle.None;
  viewer.SizeMode := PictureBoxSizeMode.AutoSize;// .Zoom;  .AutoSize
  viewer.BackColor := Color.LightGray;

  //
  // btnOpen
  //
  btnOpen := new Button;
  btnOpen.Location := new System.Drawing.Point(513, 12);
  btnOpen.Text := 'Open';
  btnOpen.Size := new System.Drawing.Size(75, 23);
  btnOpen.TabIndex := 0;
  btnOpen.UseVisualStyleBackColor := true;
  btnOpen.Click += btnOpen_Click;
  
  self.Controls.Add(viewer);
  self.Controls.Add(btnOpen);

end;

procedure Form1.Form1_Load(sender: Object; e: EventArgs);
begin
  //libSkiaSharp.dll 파일은 64bit용으로 복사해와야됨.
  
  btnOpen.Text := 'Open';
  viewer.SizeMode := PictureBoxSizeMode.Zoom;   //.StretchImage;

end;

procedure Form1.btnOpen_Click(sender: Object; e: EventArgs);
var
  dlg: OpenFileDialog;
  filePath : string;
  extension : string;
  loader: ImageLoader.ImageLoader2; // ImageLoader 타입의 변수 선언
begin
  //
  dlg := new OpenFileDialog();
  if dlg.ShowDialog = System.Windows.Forms.DialogResult.OK then
  begin
    filePath:=dlg.FileName;
    extension := ExtractFileExt(filePath);  // 파일 확장자 추출 .webp
    //MessageBox.Show('extension = ' + extension);
    //viewer.Image := Image.FromFile(filePath); //기본 picturebox 사용법
    if (IsAnimatedImage(filePath)) then
    begin
       var animatedHandler := new AnimatedImageHandler.AnimatedImageHandler2;
       animatedHandler.Animation(filePath, viewer);
    end
    else
    begin
      loader := new RasterImageHandler.RasterImageHandler2;
      var image := loader.LoadImage(filePath);
      if viewer.Image <> nil then
        viewer.Image.Dispose();
      viewer.Image := image;
      viewer.Refresh();      
    end;
    
  end;
  
end;

function Form1.IsAnimatedImage(filePath: string): boolean;
begin
  var stream: System.IO.Stream := nil;
  var skStream: SKManagedStream := nil;
  var codec: SKCodec := nil;
  
  try
    // 파일 스트림 열기
    stream := System.IO.File.Open(filePath, System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.Read);
    skStream := new SKManagedStream(stream);
    codec := SKCodec.Create(skStream);

    // 프레임 수 확인 및 출력
    if codec <> nil then
    begin
      Console.WriteLine('codec.FrameCount = ' + codec.FrameCount.ToString);
      Result := codec.FrameCount > 1;
    end
    else
      Result := false;
  finally
    // 리소스 정리
    if codec <> nil then
      codec.Dispose;
    if skStream <> nil then
      skStream.Dispose;
    if stream <> nil then
      stream.Dispose;
  end;
end;

end.
