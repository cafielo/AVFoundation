
# Chap 1 Getting Started with AV Foundation 

- 1991: 애플이 quickTime 출시, 뒤로 매스미디어에 영향.   
- 2001: 애플이 아이팟과 아이튠즈 출시.    
- 2007: 애플이 아이폰을 출시.    
- 디지털 미디어는 어디에나 있는 그런것이 되버림.     



### What is AV Foundation 

- 뭐냐? 애플의 시계열 기반 미디어 프레임웍임
- 멀티스레드를 사용하도록 고안되었음 
  - 멀티코어를 이용해서, 비싼 계산 및 GCD 처리를 할수 있음
- 하드웨어 가속을 이용하여 성능도 자동으로 최적화함


### Where Does AV Foundation Fit?

![screen shot 2017-04-18 at 1 34 41 am](https://cloud.githubusercontent.com/assets/5119286/25215813/9590c530-25da-11e7-8d91-cc05dd568bf3.png)


두 플랫폼 모두 webview를 통해서 `<audio>`, `<video>` 태그 사용가능함. 
AVFoundation 밑의 레이어에는 C-based 프레임웍들이 있음
- 속도가 빠름
- 대신 사용하기 복잡하고 어려움
- CoreAudio 
    - 오디오 처리를 담당
    - 녹음, 재생, 미디 컨텐츠 처리 
- CoreVideo
    - 디지털 비디오를 위해 파이프라인 모델을 제공
    - 파이프라인은 이미지 버퍼 및 버퍼풀을 제공함 
- CoreMedia
    - 저수준의 데이터 타입 제공
    - 타이밍 모델인 CMTime 제공
- CoreAnimation
    - 구성과 애니메이팅을 위한 프레임웍
    - 애플플랫폼에서 유려한 움직임을 위한 프레임웍


고도화를 위해 사용하는 CoreMedia 혹은 CoreAudio와  직접적으로 상호작용할수 있음 

### Decomposing AV Foundation 

AVFoundation 에  뭔놈의 클래스가 아따 엄청 많음 
그래서 뭘 어떻게 언제 써야하는지 막막함 
이제 샅샅이 나누어서 차근차근 살펴보자 


##### Audio Playback and Recording 

그림 1.1에 보면 AVFoundation 사각형 우측에 조그맣게 Audio-only 클래스들이 있다. 
AVFoundation 에 AVAudioPlayer, AVAudioRecorder등은 오디오 관련 작업을 쉽게 해주는 녀석이다


##### Media Inspection 

AVFoundation 에서는 당신이 쓰고 있는 미디어의 타입에 대해서 확인 할수 잇는 기능을 가지고 잇다. 
미디어의 속성들을 확인할수 있음
- 시간
- 생성시간
- 재생 볼륨

추가적으로 AVMetadataItem을 이용해서 메타 데이터 정보도 볼수 있음 

##### Viedo Playback

AVFoundation 은 비디오 재생에 많이 쓰임
- 로컬, 네트웍 비디오 모두 재생 및 컨트롤이 가능함 
- AVPlayer와 AVPlayerItem이 주요 역할을 할것임
    - 심지어, 오디오, 비디오 두개를 각각 구분할수도 있음


##### Media Capture

왠만한 애플 제품에는 빌트인 카메라가 있는데 동영상 및 이미지 캡쳐가 가능하다 
AVFoundation은 다양한 api들을 제공해주고 있음
- AVCaptureSession 이 허브가 될 클래스이다. 

##### Media Editing 

AVFoundation 은 미디어 구성과 편집에 강력한 기능들을 제공함 
AVFoundation 은 미디어 클립의 편집, 오디오 파라미터 변경, 애니메이팅 타이틀 추가, 전환효과등을 줄수 있는 앱을 만들수 있게 해줌 (헐 진짜???)

##### Media Processing 

대부분의 작업은 비트와 바이트 접근하지 않고도 성취가 가능하나, 가끔은 비트와 바이트 단위로 접근해서 처리가 필요할때가 있다. 
AVAssetReader, AVAssetWriter 가 미디어 프로세싱에 주요하게 필요한 클래스임

### Understanding Digital Media

우리가 소비하는 모든 미디어들은 디지털화 되어 있는데, 아날로그 데이터를  디지털로 변환하는데 생각해본적이 있니? …. 음 없지… 그러니 이책을 보고 있지…..

우리의 신체 기관 (눈, 귀)등은 이러한 아날로그 데이터를 전기신호로 바꾸어 준다. 
자연에서 우리가 접하는 아날로그 데이터들은 continuous한데 결국에는 디지털로 만들기 위해서는 0, 1로 바꾸어주어야함. 
이를 위해서 우리가 먼저해야할 일이 샘플링 하기이다 

##### Digital Media Sampling

샘플링 방법에는 크게 두가지가 있음
- temporal 샘플링 : 시간기반(오디오 샘플링 기법)
- spatial 샘플링 : 공간기반(이미지 쪽 샘플링 기법)
- 비디오의 경우 두가지 샘플링 방법 모두 사용

##### Understanding Audio Sampling

소리가 뭐냐!
- 우리가 실제 듣는 소리라는 것은, 매개를 통해 전달되는 어떤 진동인것임 
- 이 진동이 고막에 도착해서 원래 음원에서 발생했던 주파수와 크기를 다시 만듬 
- 이것을 다시 전기신호로 변환해서 뇌로 보냄

다시 샘플링
신호에는 우리가 봐야할 두가지 측면이 있다 
- 크기 
- 주파수 (주기)

유용한 지식 01
- 피아노 제일 저음 A0 : 27.5 Hz
- 피아노 제일 고음 C8 : 4.1 kHz

오디오 dizitizing에는 LPCM이라는 인코딩 방법이 수반됨 
- 아날로그 신호를 그대로 디지털화한것임(아주 날것 그대로, 다만 디지털로만 바꾼형태)

나이퀴스트 띠어럼
- 특정 주파수를 캡쳐하려할때는 그 2배되는 주파수 샘플링하면 가능함

주파수 외에도 각 오디오 샘플들을 어떻게 정확하게 캡쳐할까에 대한 측면이 있음
- 양자화: 캡쳐된 신호를 어느 정도로 정량화 할것인가? 
    - bitDepth로 얘기함

유용한 지식 02
- 1분짜리 44.1kHz 16bit LPCM 샘플링 크기 ?
    - bitwise: 16 * 44100 * 60 = 42,336,000 bit 
    - bytewise: 2 * 44100 * 60  = 5,292,000 byte (5Mb)
        - 보통 음원 Streo(channel이 2개), 따라서 5Mb * 2= 10Mb

비디오가 뭐냐!
- 이미지(프레임이라 부름)의 순서임 
- 보통 비디오 프레임 레이트 = 30fps

비디오 Dizitizing
- 보통 가로세로비율 16:9
- 보통 화면 해상도 1920 x 1080
- 초당 178Mb, 시간당 625Gb 필요(Holy great mother of god!!)

![screen shot 2017-04-19 at 6 33 19 pm](https://cloud.githubusercontent.com/assets/5119286/25239885/51c6021e-262c-11e7-9ad4-e27921982d79.png)


### Digital Media Compression 

디지털 미디어는 공간을 어마어마하게 쓰기때문에 당연히 압축이 필요(우리가 소비하는 모든 미디어는 압축되어있음)

##### Chroma Subsampling 

비디오 데이터는 YUV 컬러 모델을 이용해서 압축을 함
- YUV 컬러 모델은 (Y: 밝기 영역, UV: 색영역)
- 이유: 사람눈은 밝기에 보다 민감함,, 색차는 상대적으로 둔함 그래서 YUV모델 사용

YUV모델을 이용한 샘플링을 크로마 샘플링이라함 
- 여기서, 4:4:4, 4:2:2 이런 숫자가 나옴  (J: a: b) 비율
    - J: 참조할 블럭의 갯수 (보통 4개)
    - A: J 픽셀에 첫번째줄에 저장된 색차픽셀의 갯수
    - B: J 픽셀에 두번째줄에 저장된 색차픽셀의 갯수
    
![screen shot 2017-04-21 at 12 50 02 am](https://cloud.githubusercontent.com/assets/5119286/25239939/80f95eaa-262c-11e7-9eb3-31d293f92efa.png)

4:4:4 = 압축 없음
4:2:2 = 수평방향으로 2픽셀씩 색차 평균내버림 (이렇게 하면 색차 정보를 1/2로 줄일수 있음)
4:2:0 = 수평, 수직방향으로 색차 평균내버림 (이렇게 하면 색차 정보를 1/4로 줄일수 있음)

##### Codec Compression 

Codec을 이용해서 인코딩(압축저장)/디코딩함
- 인코딩에는 무손실과 손실 인코딩이 있음

유용한 지식 01
- 사람의 귀 가청영역: 20 ~20000 hz
- 사람의 귀가 가장 민감한 가청 영역: 1000 ~ 5000 hz

AVFoudation에서 제공되는 코덱들
- Video Codec: H.264, Apple ProRes
- Audio Codec: AAC 

##### Video Codec

H.264
엄청 많이 사용되는 코덱(MPEG-4 part 14)
두가지 측면에서 획기적으로 압축률을 높였다 
- Spatially: 프레임별 압축
- Temporally: 프레임간 압축

![screen shot 2017-04-20 at 3 06 01 pm](https://cloud.githubusercontent.com/assets/5119286/25240103/f4e5c614-262c-11e7-9a8b-b457ea8795c7.png)

IntraFrame Compression:
- JPEG 처럼 이미지 압축을 함
- 나중에 Inter Compression 기준프레임인 I-frame이 될 예정

InterFrame Compression:
- 프레임은 그룹을 이룸 (GOP)
- I frame: 키프레임이며, 이미지 생성을 위한 모든 데이터를 가짐
- P frame: 주변 p, i frame을 기반으로 인코딩됨, 또 본인자신이 b, p frame에 참조가 됨
- B frame: 앞뒤 전후 프레임으로부터 만든 프레임, 정보가 워낙 적어서 압축률은 높지만 디코딩이 시간 걸림


H.264 는 추가적으로 인코딩 프로파일을 제공함
- BaseLine:  모바일 용 인코딩을 할때 베이스라인 써야됨, 이건 B. frame을 안쓰는것인데, 그이유는 디코디에 연산이 넘 많이 들어감
- Main: BaseLine 보다 연산적으로 좀더 많이 들어가는 버젼, 따라서 좋은 화질을 압축률을 높게 만들수 있음
-  High: 가장 연산이 많이 들어감, 그래서 당연히 가장 높은 압축률을 만들어냄 

##### Apple ProRes

영상전문가들을 위한 코덱
이건  Iframe 만 있음 
비록, 손실압축이지만, 화질 제일 쩔
Apple ProRes 422는 4:2:2크로마 섭샘플링과 10bit depth를 이용함
ProRes는 OSX에서만 제공됨, iOS  개발시에는 H.264밖에 선택의 여지가 없음요


##### Audio Codecs
AVFoundation은 CoreAudio 프레임웍에서 제공하는 코덱 모두 제공함. 
LPCM(linear pcm) 을 사용하지 않은 경우에는 당신이 가장 많이 사용할 타입은 AAC 포맷이다

##### AAC(Advanced Audio Coding)
MP3를 대폭 개선한 버젼으로 오디오 인코딩에 가장 많이 사용됨 
추가로, 라이선스 및 특허 이슈가 없다 :) (MP3는 이걸로 사람들 좀괴롭힘)


##### Container Format

.mov, .m4v, mpg, m4a 는 파일타입이라고 말하기보다는, 컨테이너 포맷이라고 말하는게 훨씬 정확하다
컨테이너 포맷이 뭐냐?
- 메타파일 포맷이라고 생각하자
- 폴더인데 거기에 컨텐츠에 대한 상세를 써놓은 폴더라고 생각하자 
    - 예를 들면 퀵타임 파일에는 동영상, 오디오, 자막, 챕터 정보와 이것들을 상세 설명하고 있는 메타데이터가 있다고 보면됨

AVFoundation 에서 주로 사용할 두가지 컨테이너 포맷
- QuickTime 
    - 애플에서 제공하는 컨테이너 포맷
    - spec: https://developer.apple.com/library/content/documentation/QuickTime/QTFF/QTFFPreface/qtffPreface.html
- MPEG-4
    - MPEG-4 part 14 (mp4) 컨테이너 포맷
    - QuickTime에서 나온 형태이며, 업계 표준임
    - mp4 가 공식 확장자 인데,  그외에도 다른 확장자들이 애플 기기환경에서 특히 많이 쓰임 
    - 가끔 미디어 타입에 따라 구분을 지려고 할때가 있음
        - 오디오: m4a
        - 비디오: m4v


##### Hello AV Foundation 


