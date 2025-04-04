
1. nuget 설치 패키지 
는 Visual Studio C# 프로젝트에서 nuget 설치후 
Package 에 있는 dll 을 선별해서 복사해서 사용
- SkiaSharp   안정적 버전 (연관된 패키지 자동 설치)
- SkiaSharp.Svg 안정적 버전
- 그외 ...


2.구조 설명
- Unit1.pas (메인 폼)
- ImageLoader.pas (추상 클래스 및 공통 로직)
- RasterImageHandler.pas (래스터 이미지 처리)
- SvgImageHandler.pas (SVG 이미지 처리 : 진행상황 X )
- AnimatedImageHandler.pas (애니메이션 GIF/WebP 처리)
