
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


두 플랫폼 모두 webview를 통해서 <audio>, <video> 태그 사용가능함. 
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

