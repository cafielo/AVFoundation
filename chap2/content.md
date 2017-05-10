
# Chap 2 Playing and Recording Audio 

AVFoundation 은 처음에 오디오 플랫폼으로 시작함(비디오 없었음)
- AVAudioPlayer, AVAudioRecorder 가 주로 쓰이는 클래스임(대신 조금 오래되긴 함)

### Mac and iOS Enviroments

오디오 레코딩과 플레이백을 보기전에 Mac과 iOS 환경을 이해하는게 좋다 

iOS 환경에서 오디오 환경 시나리오
- 음악 스피커로 들음
- 전화가 와서 음악 정지하고, 다시 전화거절함
- 그러면 스피커로 나오지만, 고음질로 듣기 위해 헤드폰을 낌
- 헤드폰을 끼면 음원이 자동으로 스피커에서 헤드폰으로 라우팅됨 (음악 재생중에…)

iOS 는 managed audio enviroment(audio session)를 제공함 

### Understanding Audio Sessions

audio session은 앱과 iOS 간의 중간 매체라고 생각하면 됨 
하드웨어에 대한 상세 인터랙션을 설명하는 대신, 앱이 어떻게 행동이 되어야 하는지를 설명해주면 됨
모든 앱은 기본적으로 한개의 오디오 세션을 가짐 
- 기본 설정은 아래과 같음
    - 오디오 플레이백 켜짐, 레코딩은 꺼짐
    - 무음모드에서는 소리는 안남
    - 락스크린 켜지면 오디오는 무음됨
    - 앱에서 음원 재생하면, 다른 재생중이던 음원은 음소거..
기본 Audio session은 위와 같이 구성 되어 있지만, 각 앱에 맞게 오디오센션 행동에 대해 변경해줘야함(오디오를 이용하는 앱의 서비스의 경우). 

### Audio Session Categories

오디오 세션은 7가지 카테고리로 오디오 행동에 대해 구분해놓음

![category](https://cloud.githubusercontent.com/assets/5119286/25895643/b64960f2-35bb-11e7-93b4-1766e503342f.png)

추가적으로 advanced control을 하려면 ,option과 mode를 사용하면됨 
- VoIP, 비디오챗 등이 이런걸 열심히 씀

### Configuring an Audio Session

audio session은 앱 생명주기동안 변경이 가능함 
그러나 보통 한번 설정하고 끝나는데, 이거 설정하기 좋은 장소가….
- `application:didFinishLaunchingWithOptions:` 임
`AVAudioSession` 클래스는 앱이랑 인터랙션할수 있는 인터페이스를 제공함 

### Audio Playback with AVAudioPlayer

AVAudioPlayer는  오디오 재생에 대해 쉽게 구현할수 있는 인터페이스 제공
AVAudioPlayer는 CoreAudio의 C기반 AudioQueue Service 위에 만들어진 녀석임 
다만 가정이
- 네트웍, 초적은 지연시간, 원형 오디오데이터에 접근하지 않을때 사용하기 짱임


### Creating an AVAudioPlayer
AVAudioPlayer는 두가지 방법으로 구성할수 있는데 , 
- 첫번째는 메모리에 있는 NSDatat로 
-  두번째는 URL 기반으로 로컬에 있는 음원파일을 이용하는 방법

AVAudioPlayer를 URL 기반으로 구성시, 인스턴스 만들고 나서, prepareToPlay를 호출해놓는게 좋음
- 왜냐하면
    - 미리 하드웨어 자원들을 받아놓음
    - 플레이 메소드 호출시 지연시간을 줄일수 있음

### Controlling Playback

AVAudioPlayer는 다음의 메소드가 있음
- play
- pause
- stop (prepareToPlay 가 호출됨)

추가 고급기능이 있음
- 플레이어 소리 조절
- 소리의 위치 조절 ( -1 ~ 1.0)
- 재생속도 (default: 1, 2배속, 0.5배속)
- 반복 숫자 세팅을 이용해서 몇번이나 반복할지 정할수 있음 ( -1 세팅시 무한반복)
- 오디오의 평균 파워값 및 최고 파워값을  얻어 올수 있음 


### Building an Audio Looper

이번시간에는 오디오루핑 앱을 만듬
- 3개의 플레이어를 동시에 재생하게 만드는 것임
- 오디오 믹싱도됨
- 플레이백 레이트 컨트롤하게함

loop count = -1 은 무한루프임

먼저 거시적인 행동에 대해 먼저 구현
- 3개 동시 재생
- 정지
- 플레이백 레이트 조율


### Configuring the Audio Session 

실제 앱에 올려놓고 테스트 해볼 리스트
- 오디오 틀고 무음버튼 켜고,꺼보기
- 오디오 틀고, 락스크린버튼 눌러보기
아마 안들릴것임 > 그래서 오디오 세션에 대한 얘기를 좀 해야겠음 

모든 iOS앱은 기본 오디오 세션 제공(category: solo ambient)
- 사실 이것은 오디오 재생이 주목적인 앱에게는 적당하지 않음

오디오세션이 한번 세팅이 되야 하기 때문에, appdelegate에서 세팅하겠다 
- 이번 실습 앱은 주목적이 오디오재생이므로 
    - 카테고리를 AVAudioSessionCategoryPlayback 로 세팅하겠음
- setAction:error: 메소드를 이용해서 오디오세션을 activate 하겠음

이렇게 하고 다시 테스트 
- 무음모드에서 재생시 > 통과
- 락스크린 켜기 (백그라운드 재생) > 실패

백그라운드에서 실행해주기 위해서는 Info.plist 에서 백그라운드모드를 세팅해주어야함 




### Handling Interruptions

오디오 앱의 디테일을 챙기는것중 중요한것 하나가 인터럽션 핸들링이다 
iOS 자체는 이부분에서 OS입장에서 핸들링을 엄청잘하고 있지만, 앱의 디테일을 위해서는 
우리가 직접 잘 처리해줘야함 

인터럽션 핸들을 위해서는 테스트를 해야함 
아래의 절차에 따라 테스트를 해보자 
- 앱을 실행하고 재생시키자
- 오디오가 재생되는 동안에, 전화나 페이스타임을 통해 인터럽션을 발생시켜보자
- 거절 버튼을 이용해서 전화를 끊어 보자 

위의 테스트를 제대로 수행한 경우, 현재 재생중인 오디오가 조용히 페이드아웃되고, 전화 거절이후에도 정지해 있는 모습을 볼수 있다. 
- 전화 이후에는 다시 오디오가 재생해야할것 같은데,, 안됨


### Audio Session Notifications
AVAudioSession 에게 AVAudioSessionInterruptionnotification을 등록하여 인터럽션 상황을 공지 받도록 설정함
- 이때 재생/정지 버튼 업데이트를 제대로 처리해야함


AVAudioSessionInterrruptionTypeEnded의 노티가 오면, 
- 오디오 세션이 다시 활성화되고, 다시 재생할수 있음을 얘기함

### Responding to Route Changes

한가지 마지막으로 오디오 앱에서 챙겨하는 것이 오디오 라우트 변경에 대응해야함

이것을 대응하기 위해 해보아야할 테스트
- 앱을 켜고 
- 재생하고
- 헤드폰을 껴보고


원래 폰에서 키고 헤드폰 끼면 재생이 그대로 되어야함
대신 헤드폰 뺐을때는 음악이 정지되어야함(그런데 지금은 그냥 틀어지고 있음) > HIG에서 이렇게 가이드하고 있음


AVAudioSessionRouteChangeNotification을 AVAudioSessoin에 등록해서 변경사항을 노티 받도록 함
- 노티받으면 userInfo에서 AVAudioSessionRouteChangeReasonKey 를 통해서 변경사항을 알수가 있음 

다시 한번 강조하면, 미디어 관련 앱 만들때에는 
- 인터럽션 핸들링 
- 라우터 변경 핸들링 
꼭 해줘야함 



### Audio Recording with AVAudioRecorder

오디오 플레이만큼 오디오 레코딩도 AVFounation과 함께라면 짱 쉬움
- AVAudioRecorder 를 이용하면됨

Creating an AVAudioRecorder

AVAudioRecorder는 3개의 데이터만 있으면 만들수 있음
- 로컬URL(오디오음원이 기록될곳)
- 레코딩 세션관련 configuration Dictionary
- error포인터 (에러 발생시 이 error에다가 생성하게됨)

AVAudioRecorder 객체를 만들고 나면, prepareToRecord메소드를 호출해주어야 미리 리소스 준비하게됨


### Audio Format 
AVFormatIDKey는 어떤 형태의 오디오로 저장이 될지 결정해준다 
아래의 형태로 저장가능
- kAudioFormatLinearPCM
- kAudioFormatMPEG4AAC
- kAudioFormatAppleLossless
- kAudioFormatAppleIMA4
- kAudioFormatiLBC
- kAudioFormatULaw



### Sample Rate
AVSampleRateKey를 이용해서 레코딩 샘플링 레이트를 정함 

### Number of Channels
AVNumberOfChannelsKey를 이용해서 몇개의 오디오 채널을 사용할지 지정함

### Format-Specific Keys
포맷의 추가적인 구체사항들을 정의 할수 있음

### Controlling Recording 
AvAudioRecorder는 아래의 리스트를 수행할 수 있는 메소드가 있음
- 무한기간 녹음
- 미래의 특정 지점에 녹음하기 
- 특정 시간동안만 녹음하기 
- 녹음을 일시 중지한후 다시 시작하기 


### Building a Voice Memo App


### Audio Session Configuration 

레코딩을 위해서는 AudioSessionCategory 를 AVAudioSessionCategoryPlayAndRecord로 하여라
iOS7부터는 마이크 사용시 os에서 사용자로부터 퍼미션을 물어보도록 되어있다(앱에서 맘대로 오디오 못키게)


### Recorder Implementation 
THRecorderController 요런 클래스가 있음
- 레코딩 작업 관련 메소드들이 있음
위 클래스는 AVAudioRecorderDelegate를 따르는데
- 레코딩끝날시 호출받는 메소드를 가지고 있음

AVAudioRecorder는 currentTime 이라는 프로퍼티가 있음
- 이걸 이용해서 시간관련 피드백을 사용자에게 쉽게 줄수 있음
- 레코딩 시간관련 업데이트 어떻게 시킬것인가?
    - 그냥드는 생각은?  KVO를 통해서 currentTime이 바뀌는것을 옵저빙하면 되지 않을까?
        - 근데 currentTime은 observable 하지 않아서 KVO방식 안되용
    - KVO 대신 NSTimer를 이용해서 계속 업데이트 하는 방법을 써야함

### Enabling Audio Metering 

사용자에게 녹음시, 음성신호에 대한 시각적 피드백을 주는 것은 좋음
- metering  을 이용하면 할수가 있음

AVAudioRecorder랑 AVAudioPlayer 모두 오디오 metering을 할수가 있다. 짱!
- Average 와 peak값을 모두 읽을 수 있음 (db레벨임)
- averagePowerForChannler: , peak-PowerForChannel: 메소드를 이용하면 float값을 넘김(db레벨임)
- (최소)-160 ~ 0(최대음)db까지
- 이거 미터링 쓸라면, meteringEnabled 프로퍼티 켜야됨
- 미터링 값 읽기 전에 updateMeters 메소드로 업데이트 하고 값 가져오기 

NSTimer를 이용해서 매번 미터링을 업데이트 할수 있음
- 좀더 정확하고 스무스 하게 미터링 업데이트를 일정시간동안 하려면 CADisplayLink를 이용해야함 
- CADisplayLink 는 화면 fps에 맞추어서 업데이트 되기때문에 일정시간동안 업데이트 보장




