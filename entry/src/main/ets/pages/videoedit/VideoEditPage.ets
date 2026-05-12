import { AppUtil } from '@pura/harmony-utils'
import { DEBUG } from '../../common/utils/logutils/Logger'
import { VideoPreviewArea } from '../../feature/videoedit/component/preview/VideoPreviewArea'
import {VideoEditTopBar} from '../../feature/videoedit/component/topbar/VideoEditTopBar'
import { VideoResolutionRatioEnum } from '../../feature/videoedit/constants/VideoResolutionRatioEnum'

const tag = 'VideoEditPage'

@Entry
@ComponentV2
struct VideoEditPage{
  @Local videoRatio : VideoResolutionRatioEnum = VideoResolutionRatioEnum.RATIO_16_9
  @Local ratioExpanded: boolean = false
  @Local isPlaying: boolean = false

  private readonly xComponentId: string = 'xcomponent_video_id'
  private readonly xComponentController: XComponentController = new XComponentController()
  private navStack: NavPathStack|null = null

  build() {
    NavDestination(){
      Column(){
        VideoEditTopBar({
          selectedRatio: this.videoRatio,

          onCloseClick: () => {
            this.closeButton()
          },

          onSettingClick: () => {
            this.settingButton()
          },

          onRatioClick: () => {
            this.ratioButton()
          },

          onExportClick: () => {
            this.exportButton()
          }
        })

        Stack({alignContent:Alignment.TopStart}){
          if(this.ratioExpanded){
            this.aspectRatioPanel()
          }

          VideoPreviewArea(
            {
              selectedRatio:this.videoRatio,
              xComponentId: this.xComponentId,
              xComponentController: this.xComponentController
            }
          )
            .height('100%')
            .width('100%')
        }
        .width('100%')
        .height('60%')
        .backgroundColor(Color.Red)

        Stack({ alignContent: Alignment.Center }){
          Row(){
            Button(){
              SymbolGlyph($r('sys.symbol.arrow_left'))
                .fontColor([Color.White])
            }
            .backgroundColor(Color.Transparent)
            .onClick(()=>{this.undoButton()})

            Button(){
              SymbolGlyph($r('sys.symbol.arrow_right'))
                .fontColor([Color.White])
            }
            .backgroundColor(Color.Transparent)
            .margin({left:8})
            .onClick(()=>{this.redoButton()})

            Blank()

            Button(){
              SymbolGlyph($r('sys.symbol.fullscreen'))
                .fontColor([Color.White])
            }
            .backgroundColor(Color.Transparent)
            .margin({left:8})
            .onClick(()=>{this.fullScreenButton()})

          }
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Black)
          .padding({left:16,right:16})

          Button(){
            if(!this.isPlaying) {
              SymbolGlyph($r('sys.symbol.play'))
                .fontColor([Color.White])
            } else {
              SymbolGlyph($r('sys.symbol.pause'))
                .fontColor([Color.White])
            }
          }
          .backgroundColor(Color.Transparent)
          .onClick(()=>{this.videoControlButton()})
          .height('100%')
        }
        .width('100%')
        .height('5%')

      }
        .backgroundColor(Color.Black)
        .height('100%')
        .width('100%')
        .padding({top: this.getUIContext().px2vp(AppUtil.getStatusBarHeight()) })
    }
      .hideTitleBar(true)
      .onReady((navCtx:NavDestinationContext)=>{
          this.navStack = navCtx.pathStack
        })
  }

  @Builder
  private aspectRatioPanel() {
    Row() {
      this.ratioOption(VideoResolutionRatioEnum.RATIO_1_1)
      this.ratioOption(VideoResolutionRatioEnum.RATIO_235_1)
      this.ratioOption(VideoResolutionRatioEnum.RATIO_16_9)
      this.ratioOption(VideoResolutionRatioEnum.RATIO_9_16)
    }
    .zIndex(20)
    .height(40)
    .width('100%')
    .backgroundColor(Color.Black)
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
    .borderRadius({
      bottomLeft:5,
      bottomRight:5
    })
  }

  @Builder
  private ratioOption(ratio: VideoResolutionRatioEnum) {
    Button(ratio, { type: ButtonType.Normal, stateEffect: false })
      .backgroundColor(ratio === this.videoRatio ? Color.White : Color.Transparent)
      .fontColor(ratio === this.videoRatio ? Color.Black : Color.White)
      .border({
        width: 1,
        color: Color.White
      })
      .height(24)
      .width(60)
      .borderRadius(4)
      .onClick(() => {
        this.videoRatio = ratio
        this.ratioExpanded = false
        DEBUG(tag, `Select ratio: ${ratio}`)
      })
  }


  private closeButton() : void{
    DEBUG(tag,"CloseButton is clicked")
    this.navStack?.pop()
  }

  private settingButton(): void{
    DEBUG(tag,'SettingButton is clicked')
  }

  private ratioButton(): void{
    DEBUG(tag,'RatioButton is clicked')
    this.ratioExpanded = !this.ratioExpanded
  }

  private exportButton(): void{
    DEBUG(tag,'ExportButton is clicked')
  }

  private undoButton():void{
    DEBUG(tag,'Undo is click')
  }

  private redoButton():void{
    DEBUG(tag,'Redo is click')
  }

  private fullScreenButton():void{
    DEBUG(tag,'Full screen is click')
  }

  private videoControlButton():void{
    DEBUG(tag,`${!this.isPlaying? 'play' : 'pause'} is click`)
    this.isPlaying = !this.isPlaying
  }
}

@Builder
export function PageBuilder() {
  VideoEditPage()
}
