
# Chap 3 Working with Asset and Metadata

iOS4 이후에 AVFoundation 나왔
- 이것은 미디어 활용에 있어서 다양한 짓을 할수 있게해줌
- 예를들면, 캡쳐링, 재생, 미디어 프로세싱
- 그리고 이것은 파일기반 클래스가 아닌 Asset 기반 클래스로 바꾸는 시점이됨

    
### Understanding Assets

AVFoudnation 의 중심은 AVAsset 임
- AVAsset은 미디어를 하나의 추상화 시킨 객채로 보면됨… 짱
    - 크게 두가지모델을 추상화 시켰는데..
    - 첫째, 포맷 (코덱의 디테일 생각안해도됨)
    - 두째, 리소스의 위치
- AVAsset 은 미디어 그 자체는 아니고, 컨테이너 정도로 생각하자 
    - 실제 미디어 데이터는 AVAssetTrack이란 놈으로 래핑함
    - AVAssetTrack은 AVAsset.tracks 프로퍼티로 접근가능요


### Creating an Assets

AVAsset은 만들때 미디어의 URL을 넘겨서 만듬
- 로컬주소, 리모트 서버주소 뭐 다됨

** iOS Asset Library **
주로 비디오 같은것들은 photos libary에 있음
iOS에서 AssetsLibrary 프레임웍을 통해 이것을 읽고 쓸수 있게해줌 

** iOS iPod Library **
주로 ipod libary에서 미디어를 가져오고 싶은데…. 이째 어찌함?
- MediaPlayer framework 이 쿼리 날려서 library에 있는 아이템들 찾을수 있게 해줌
- MPMediaPropertyPredicate 을 이용해서 조건 검색을 할수 있게 해줌

** Mac iTunes Library **
OSX 10.8, iTunes 11.0 이후, iTunesLibrary 프레임웍을 통해 라이브러리의 아이템을 접근할수 있게 해줌
MediaPlayer  프레임웍처럼 조건을 위한 api는 없지만, NSPredicate을 이용하면 조건 검색 가능

### Asynchronous Loading

AVAsset은 여러 트랙을 가져와서 작업할수 있는 메소드를 제공한다
AVAsset은 미디어의 어셋의 속성들을 로딩하는 것을 약간 미루게 디자인하였음
- 이것은 어셋객체를 즉시 만들수 있게해줌
- 그런데 알아둬야할것은 속성에 접근하는것은 항상 동기적으로 일어남
- 동기적으로 일어나다 보니 생기는 문제가 있음 (UI가 멈춘다든지….)
- 그래서 어셋 속성접근시에는 비동기 쿼리를 사용해야함
    - loadValuesAsynchronouslyForKeys:completionHandler:  메소드를 사용함


### Media Metadata

AVFoundation은 미디어의 메타데이터도 관리해줌
- 따라서 AVFoundation과 함께라면 메타데이터 처리도 쉬움
- 실제로, 메타데이터 처리를 쌩으로 할려면 좀 까다로움

** Metadata Formats **

주요 4가지 미디어포맷
- QuickTime(mov)
- MPEG4-Video(mp4, m4v)
- MPEG4-Audio(m4a)
- MPEG Layer3(mp3)


### Working with Metadata

AVAsset, AVAssetTrack 모두 메타데이터에 대한 정보를 가져 올수있는 능력이 있음
- AVAsset에서 제공해주는 메타데이터로 충분히 유용함
- 그러나, 가끔 트랙래밸로 메타데이터를 보는것도 필요할때가 있음
    - AVMetaDataItem이란 녀석을 통해 가져옴
- AVAsset, AVAsset 은 두가지 방법으로 메타데이터 제공
    - 이를 위해서 keyspaces란 것에대한 이해가 필요
    - 모든 어셋은 적어도 2개의 keyspaces를 가지고 있음
- Key spaces 다음의 영역이있음
    - Common: title, artist 등
    - Format: availableMetadataFormats 속성으로 가능한 포맷들을 모두 불르수 있음

** Finding Metedata **
메타데이타들을 받고 나서는, 이제 그에 해당하는 값을 찾아야 하는데…..
- 이것은 AVMetadataItem 를 이용해서 검색 및 필터해서 가져올수 잇당

** Using AVMetadataItem **
AVMetaDataItem은 하나의 key-value페어의 래퍼이당 
- 그래서 필요한 키값을 넣으면 값도 알수 있음


### Building the MetaManager App
이번 메타데이터 매니저앱은 AVFoundation이 지원하는 모든타입의 메타데이터 보여줌, 그리고 메타데이터 쓰는것까지…..(MP3는 쓰는건 안되는건 함정)
AVFoundation이 많은부분에서 추상화 시켜주고 있긴하지만, 실제로 통일화된 방식으로 관리하기 어려움
- 해결책이 필요함: 포맷 별 메타데이터를 일정하게 딕셔너리에 넣어서 관리하는 전략 채택

** THMediaItem **
AVAsset 인스턴스의 래핑 모델
AVAsset 의 메타데이터를 불러오는 기능포함
AVFoundation은 ID3 태그의 정보를 읽어 올수 있지만, 쓸수는 없음…. mp3 라이센스 때문인가?.. 
정보들은 한번만 가져오고, 상태를 prepared로 관리함


** THMetadata Implementation **
addMetadataItem메소드로 AVMetatatItem 형태로 저장시킴
metadataItems 메소드로 모든 메타데이터 정보를 가져옴 


### Data Converter
AVMetadataItem 을 쓰면서, 가장 힘든점은 value 속성을 이해하는 점임 
- 단순한 string,  int는 괜찮은데 가끔 혼란스러운것들 나옴
- 따라서 이런것을 잘 표현하려면 추가작업 해줘야함 
    - 그래서 컨버터프로토콜을 만드는 전략을 채택 

** Converting Artwork **
아트웍: 앨범 커버, 무비포스터 등등

** Converting Comments **
미디어의 커멘트 뽑는거 아주 심플함(mp3는 추가작업 필요)

** Converting Track Data **
오디오 트랙은 일반적으로 트랙 모음내에서 노래의 순서 정보를 가지고 있음
- 여기서는 오히려 mp3쉽고, m4a가 어려움(m4a추가작업 필요)

** Converting Disc Data **
CD에서 곡이 어느 디스크에 몇번째냐 정보를 얻어올때 쓰임

** Converting Genre Data **
이게 난리가 나는 작업중 하나임(빡셈)
- 왜냐, 장르가 많고, 그냥 장르, 사용자 장르, 장르아이디, 음악장르 등 뭐 엄청 많음 
이거 간소화를 위해 THGenre따로 만듬

** Finalizing THMetadata **
마무리하면서 해야할게 metadataItem 메소드만드는 것임
- 이건 현재 보여주는 값들을 다 가져와서 AVMetadataItem으로 컨버팅해주는 것임


### Saving Metadata

앞에서 메타데이터 읽고 쓰기 배움
AVAsset은 immutable인데 어떻게 쓸꺼임?
- AVAsset은 직접 건드리지 않고 AVAssetExportSession 를 이용할거임

** Using AVAssetExportSession **
AVAssetExportSession 이것은 주어진 AVAsset의 컨텐츠를 설정한 preset 으로 transcode할때 씀
- 이런기능들: 포맷변환, 컨텐츠자르기, 비디오 오디오 행동 수정, 새로 메타데이터 쓰기 등등
AVAssetExportSession은 해당 소스의 asset과 export preset 을 이용해서 만듬요
- outputURL을 설정해야 내보낼수 있음. 
- 마지막으로 exportAsynchronouslyWithCompletionHandler: 메소드를 이용해서 export하기 

** note(번역기가 설명해줌) **
AVAssetExportPresetPassthrough 사전 설정은 특정 시나리오에서 유용 할 수 있으며 데모 응용 프로그램의 목적에 적합합니다. 그러나 제한 사항이 있음을 유의하십시오. MPEG-4 또는 QuickTime 컨테이너에서 기존 메타 데이터를 수정할 수 있지만 새 메타 데이터를 추가 할 수는 없습니다. 새 메타 데이터를 추가하는 유일한 방법은 트랜스 코딩 사전 설정 중 하나를 사용하는 것입니다. 또한 ID3 태그를 수정하는 데 사용할 수 없습니다. 프레임 워크는 MP3 데이터 작성을 지원하지 않기 때문에 데모 응용 프로그램의 MP3 파일은 읽기 전용이었습니다.

### Challenge
미디어 라이브러리에서 노래나 비디오 복사떠보고,, 아이튠즈에서 한번 메타정보를 모두 넣어봐라?
-> 이건 생략 


