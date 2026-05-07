import { BusinessError } from '@kit.BasicServicesKit'
import { DEBUG, ERROR, INFO, FATAL, WARN } from "../../common/utils/logutils";
import { Router, window} from '@kit.ArkUI'
import { preferences } from '@kit.ArkData';

const tag = 'VideoPlayerPage'

interface VideoPlayerPageParams {
  videoUrl: string;
  coverWidth: number;
  coverHeight: number;
}

@Entry
@Component
struct VideoPlayerPage{
  @State videoUrl: string = ''
  @State coverWidth: number = 0
  @State coverHeight: number = 0
  @State private isPlaying: boolean = false
  @State private isFullScreen: boolean = false

  aboutToAppear(): void {
    let uiContext: UIContext = this.getUIContext();
    let router: Router = uiContext.getRouter();
    let params = router.getParams() as VideoPlayerPageParams;
    this.videoUrl = params?.videoUrl || "";
    this.coverWidth = params?.coverWidth || 0;
    this.coverHeight = params?.coverHeight || 0;
    this.sizeFix()
  }

  aboutToDisappear(): void {
    this.controller.stop()
    this.isPlaying = false

  }

  build() {
    Column() {
      // 修改点 4：全屏时隐藏顶部返回栏
      if (!this.isFullScreen) {
        Row() {
          Button() {
            SymbolGlyph($r('sys.symbol.arrow_left'))
              .fontSize(20)
          }
            .height(40)
            .width(40)
            .padding(0)
            .backgroundColor(Color.Transparent)
            .margin({ left: 10 })
            .onClick(() => {
              DEBUG(tag, `Back to last page`)
              this.getUIContext().getRouter().back()
            })
        }
        .height(40)
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Divider()
          .color(Color.Black)

        Blank()
          .height(5)

      }

      // 修改点 5：根据是否全屏，切换普通视频布局 / 全屏视频布局
      if (this.isFullScreen) {
        this.fullScreenVideoArea()
      } else {
        this.normalVideoArea()
      }
    }
    .height('100%')
    .width('100%')
    .padding({ top: this.isFullScreen ? 0 : 24 })
    .backgroundColor(this.isFullScreen ? Color.Black : Color.White)
  }
  @Builder
  private normalVideoArea(){
    Stack({ alignContent: Alignment.BottomEnd }){
      this.videoCore()
    }
      .width('100%')
      .aspectRatio(this.getCoverRatio())
      .backgroundColor(Color.Black)
  }

  @Builder
  private fullScreenVideoArea(){
    Stack({alignContent: Alignment.BottomEnd}){
      this.videoCore()
    }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Color.Black)
  }

  @Builder
  private videoCore(){
    Video(
      {
        src: this.videoUrl,
        controller:this.controller
      }
    )
      .width('100%')
      .aspectRatio(this.getCoverRatio())
      .backgroundColor(Color.Black)
      .autoPlay(true)
      .controls(true)
      .objectFit(ImageFit.Contain)
      .onPrepared(
        ()=>{
          DEBUG(tag,`Prepared to play ${this.videoUrl}`)
          this.isPlaying = true
          this.controller.start()
        }
      )
      .onError(
        ()=>{
          ERROR(tag,`Video play error, url=${this.videoUrl}`)
        }
      )
      .onClick(
        ()=>{
          this.toggleToPlay()
        }
      )
      .onFullscreenChange(
        (info : FullscreenInfo)=>{
          // 修改点：监听系统自带全屏按钮触发的全屏状态变化
          const fullscreen: boolean = info.fullscreen ?? false
          DEBUG(tag, `system fullscreen changed: ${fullscreen}`)

          if (fullscreen) {
            // 修改点：系统进入全屏后，把窗口切到横屏
            this.setWindowOrientation(window.Orientation.LANDSCAPE)
          } else {
            // 修改点：系统退出全屏后，恢复竖屏
            this.setWindowOrientation(window.Orientation.PORTRAIT)
          }
        }
      )

  }


  private exitFullScreen(){
    this.isFullScreen = false
    this.setWindowOrientation(window.Orientation.PORTRAIT)
  }

  private enterFullScreen(){
    this.isFullScreen = true
    this.setWindowOrientation(window.Orientation.LANDSCAPE)
  }

  private async setWindowOrientation(orientation : window.Orientation): Promise<void>{
    try {
      let currentWindow: window.Window = await window.getLastWindow(getContext(this))
      await currentWindow.setPreferredOrientation(orientation)
      DEBUG(tag, `set window orientation success: ${orientation}`)
    } catch (err) {
      let error = err as BusinessError
      ERROR(tag, `set window orientation failed, code=${error.code}, message=${error.message}`)
    }
  }

  private toggleToPlay():void{
    if (this.isPlaying) {
      this.controller.pause()
      this.isPlaying = false
      DEBUG(tag, 'pause video')
    } else {
      this.controller.start()
      this.isPlaying = true
      DEBUG(tag, 'start video')
    }
  }

  private controller: VideoController = new VideoController()

  getCoverRatio():number{
    if (this.coverWidth <= 0 || this.coverHeight <= 0) {
      return this.defaultWidth / this.defaultHeight
    }
    return this.coverWidth / this.coverHeight
  }

  private defaultHeight: number = 1080
  private defaultWidth: number = 1920

  private sizeFix(){
    if(this.coverWidth > 1280){
      this.coverWidth = 1280
    }

    if(this.coverHeight > 720){
      this.coverHeight = 720
    }
  }
}