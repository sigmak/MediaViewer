using SkiaSharp;
using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace SkiaSharpImageViewer
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            button1.Text = "Open";
            pictureBox1.SizeMode = PictureBoxSizeMode.Zoom;   //.StretchImage;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            using (var dlg = new OpenFileDialog())
            {
                if (dlg.ShowDialog() == DialogResult.OK)
                {
                    string filePath = dlg.FileName;
                    string extension = Path.GetExtension(filePath)?.ToLower();

                    try
                    {
                        if (IsAnimatedImage(filePath))
                        {
                            var animatedHandler = new AnimatedImageHandler();
                            //animatedHandler.StartAnimation(filePath, pictureBox1);
                            animatedHandler.Animation(filePath, pictureBox1);
                        }
                        else
                        {
                            ImageLoader loader;
                            if( extension == ".svg")
                            {
                                loader = new SvgImageHandler();
                            }
                            else
                            {
                                loader = new RasterImageHandler();
                            }
                            var image = loader.LoadImage(filePath);
                            pictureBox1.Image?.Dispose();
                            pictureBox1.Image = image;
                            pictureBox1.Refresh();
                        }
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"이미지 로드 중 오류가 발생했습니다: {ex.Message}", "오류", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
        }

        private bool IsAnimatedImage(string filePath)
        {
            using (var stream = new FileStream(filePath, FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.Read))
            using (var skStream = new SKManagedStream(stream))
            using (var codec = SKCodec.Create(skStream))
            {
                Console.WriteLine("codec.FrameCount = " + codec.FrameCount.ToString());
                return codec != null && codec.FrameCount > 1;
            }
        }


    }
}
