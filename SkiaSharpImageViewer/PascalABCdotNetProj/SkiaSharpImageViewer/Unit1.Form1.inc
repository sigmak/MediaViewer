procedure InitializeComponent;
    begin
        self.SuspendLayout();
        // 
        // Form1
        // 
        self.ClientSize := new System.Drawing.Size(278, 244);
        self.Name := 'Form1';
        self.Text := 'Form1';
        self.Load += Form1_Load;
        self.ResumeLayout(false);
    end;
