# **재생통계 WECANDEO Player**

## **공통**

- API 요청 시 header에 추가 내용
  - `User-Agent`: `({device model}; iOS {os version}) App/{app version}`
    - 예시 : `(iPhone; iOS 13.0) App/1.0`
---

## **사전에 조회할 값**

- WECANDEO Player를 사용하기 위해서는 활성화 된 WECANDEO 계정이 있어야 합니다.<br> 먼저 [WECANDEO 홈페이지](https://www.wecandeo.com)에서 계정을 생성하고 플랜(Trial, Standard, Enterprise)에 [가입](https://www.wecandeo.com/pricing/videopack/edition/)하여 계정을 활성화 합니다.<br> 활성화 된 계정에 이용중인 상품이 VideoPack인 경우 VODStatistics를, LivePack인 경우 Live Player를 사용할 수 있습니다.

- [WECANDEO API](https://support.wecandeo.com/developer/)를 사용하여 필요한 값을 조회합니다.
  - [WECANDEO API](https://support.wecandeo.com/developer/)를 사용하기 위해 필요한 API Key는 활성화 된 계정의 CMS에서 확인 가능합니다. [ CMS > 계정관리 > 개발자  API ]

- VODStatistics
  - videoKey: [동영상 배포 코드 조회 API](https://support.wecandeo.com/developer/video-pack-api/videos/video-data/video-pub-code/)를 호출하면 videoKey를 확인할 수 있습니다.
  - DRM 재생을 위한 값
    - gid : [ CMS > 부가서비스 > Wecandeo DRM ] 메뉴에서 `gid`를 확인할 수 있습니다.
    - secretKey : [ CMS > 부가서비스 > Wecandeo DRM ] 메뉴에서 `secretKey`를 확인할 수 있습니다.
    - packageId : [배포 패키지 목록 조회 API](https://support.wecandeo.com/developer/video-pack-api/publish-package/package-list/)를 호출하면 `packageId`를 확인할 수 있습니다.
    - videoId : [동영상 목록 - 배포 패키지별 조회 API](https://support.wecandeo.com/developer/video-pack-api/videos/video-data/video-list-package/)를 호출하면 `videoId`를 확인할 수 있습니다. 
    - client : 추가적인 사용자 암호화키, 사용자가 임의의 값으로 설정
  - **DRM 기능을 사용하기 위해서는 사용 가능한 플랜(Enterprise)에 가입되어 있어야 하며,<br> 관리자를 통해 해당 기능이 활성화 되어 있어야 합니다.**
- LiveStatistics
  - liveKey : [ CMS > 라이브 채널 > 채널 리스트 > 채널 선택 > 배포 코드 ] 메뉴에서 `liveKey`를 확인할 수 있습니다.

---

## **VOD**

### **Player 구성방법**

- `영상 상세정보 조회` API를 통해 `영상 상세정보` 조회 후
  - DRM
    - 조회된 `VideoId, gid` <br> 발급된 `VideoKey, ScretKey, Client, packageId` 를 통해 <br> **Player** 구성
  - Non DRM
    - 조회된 `VideoUrl` 를 통해 <br> **Player** 구성

### **설명**

- [x] 영상 상세정보 조회
- [x] 재생준비 완료 (**` AVPlayerItemStatusReadyToPlay `**)
  - [x] 영상 통계정보 조회
  - [x] 플레이어 로드 통계 전송
  - [x] 통계전송 준비완료 전송
- [x] 재생 중
  - [x] 재생 중 통계 전송 
    - 60초 이하 시 5초 마다
    - 60초 이상 시 10초 마다
  - [x] 재생중 구간통계 전송 (0 ~ 100%)
- [x] 재생 완료 시
  - [x] 정지 통계 전송
- [x] 재생 시 통계 전송
- [x] 일시정지 시 통계 전송
- [x] seekbar 이동 시 통계 전송

### **VodStatistics class**

- 영상 상세정보 조회
``` swift
func fetchDetail(_ videoKey: String, completion: @escaping () -> Void)
```

- 영상 통계정보 조회
``` swift
func fetchInfo(_ videoKey: String, completion: @escaping () -> Void)
```

- Player 로드 시
``` swift
func loadPlayer(completion: @escaping () -> Void)
```

- 통계 전송 준비완료 시
``` swift
func completionStatistics(completion: @escaping () -> Void)
```

- 재생구간 이동 (Seekbar 이동)
  - elapsedTime : 이동 시간
    
    ```swift
    func moveSeek(_ elapsedTime: Double)
    ```

- 재생구간 정보 전송
  - section : 구간정보 (0 ~ 100%)
  - version
    - (DRM) SDK 버전 정보 (eg. WCD_SDK_1.0)
    - (non DRM) App 버전 정보 (eg. TestApp_1.0)

    ``` swift
    func scPlay(_ section: Int, version: String)
    ```

- 재생
  - duration : 전체시간
  
    ``` swift
    func stPlay(_ duration: CMTime)
    ```

- 일시정지
  - current : 현재시간

    ``` swift
    func stPause(_ current: CMTime)
    ```

- 재생 중
  - start : 재생구간(초) 시작
  - end : 재생구간(초) 종료
  
    ``` swift
    func stPlaying(_ start: Int, _ end: Int)
    ```

- 정지
  - current : 현재시간

    ``` swift
    func stStop(_ current: CMTime)
    ```

---

## **Live**

### **Player 구성방법**

- 발급된 `VideoKey`로 `영상 상세정보 조회` 통해 `VideoUrl` 조회 후 <br> **Player** 구성

### **설명**

- [x] 영상 상태정보 조회
  - [x] `방송 중 경우` 영상 상세정보 조회
- [x] 재생 시 통계 전송
- [x] 재생 중 통계 전송 (5초 마다)
- [x] 정지 시 통계 전송

### **LiveStatistics class**

- 영상 상태정보 조회
``` swift
func fetchInfo(_ videoKey: String, completion: @escaping (_ errCode: LiveErrorCode) -> Void)
```

- 영상 상세정보 조회
``` swift
func fetchDetail(_ videoKey: String, completion: @escaping (_ addr: String) -> Void)
```

- 재생
``` swift
func stPlay()
```

- 재생 중
``` swift
func stPlaying()
```

- 정지
``` swift
func stStop()
```