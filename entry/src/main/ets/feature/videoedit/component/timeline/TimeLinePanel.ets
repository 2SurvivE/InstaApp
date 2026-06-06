import { VideoFrameRateEnum } from "../../constants/VideoFrameRateEnum"
import { TimeFormatUtil } from "./TimeFormatUtil"
import { TimeRuler } from "./TimeRuler"
import { TimeRulerCoordinateUtil } from "./TimeRulerCoordinateUtil"
import { TimeRulerScaleType, TimeRulerScaleUtil } from "./TimeRulerScale"

@Preview
@ComponentV2
export struct TimelinePanel {
  @Param @Require currentTime: number
  @Param @Require durationTime: number
  @Param @Require frameRate: VideoFrameRateEnum
  @Local private scaleType:TimeRulerScaleType = TimeRulerScaleUtil.getDefaultScaleType() // 默认1s
  @Event onTimeChange: (timeMs:number) => void = (_timeMs:number) =>{}
  @Local private pxPerFrame: number = 2
  @Local private panelWidth: number = 0
  @Local private scrollOffsetX: number = 0

  private scroller: Scroller = new Scroller()

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Scroll(this.scroller) {
        this.scrollContent()
      }
      .width('100%')
      .height('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .onScroll((xOffset: number, yOffset: number) => {
        this.handleScroll(xOffset, yOffset)
      })
      // 修改：恢复使用 TimeFormatUtil 的统一时间格式，避免面板显示裸毫秒值。
      // Text(`${TimeFormatUtil.formatTimeMsText(this.currentTime)}/${TimeFormatUtil.formatTimeMsText(this.durationTime)}`)
      //   .fontSize(10)
      //   .fontColor(Color.White)
      //   .backgroundColor(PANEL_BACKGROUND_COLOR)

      Text(`${this.currentTime}/${this.durationTime}`)
        .fontSize(10)
        .fontColor(Color.White)
        .backgroundColor(PANEL_BACKGROUND_COLOR)

      this.playHead()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(PANEL_BACKGROUND_COLOR)
    .onAreaChange((oldArea: Area, newArea: Area) => {
      this.handleAreaChange(oldArea, newArea)
    })
  }

  // 获取播放线在 TimelinePanel 内的 x 坐标
  private getPlayHeadX():number{
    return TimeRulerCoordinateUtil.getDefaultPlayHeadX(this.getSafePanelWidth())
  }

  private getSafePanelWidth(): number {
    return Math.max(MIN_PANEL_WIDTH, this.panelWidth)
  }

  private getLeftPadding(): number {
    return TimeRulerCoordinateUtil.getLeftPaddingByPlayHeadX(this.getPlayHeadX())
  }

  private getRightPadding(): number {
    return TimeRulerCoordinateUtil.getRightPadding(
      this.getSafePanelWidth(),
      this.getPlayHeadX()
    )
  }

  private getContentWidth(): number {
    return TimeRulerCoordinateUtil.getContentWidthByDurationTime(
      this.durationTime,
      this.pxPerFrame,
      this.getLeftPadding(),
      this.getRightPadding(),
      this.frameRate
    )
  }

  private handleAreaChange(_oldArea: Area, newArea: Area): void {
    const width = Number(newArea.width)
    if (!Number.isNaN(width)) {
      this.panelWidth = Math.max(0, width)
    }
  }

  private handleScroll(_xOffset: number, _yOffset: number): void {
    const currentOffsetX = this.scroller.currentOffset().xOffset

    this.scrollOffsetX = Math.max(0, currentOffsetX)

    const timeMs = TimeRulerCoordinateUtil.scrollOffsetXToTimeMs(
      this.scrollOffsetX,
      this.durationTime,
      this.pxPerFrame,
      this.frameRate
    )

    this.onTimeChange(timeMs)
  }

  @Builder
  private scrollContent() {
    Column() {
      // 新增：TimelinePanel 负责 Scroll，TimeRuler 只负责渲染刻度。
      TimeRuler({
        durationTime: this.durationTime,
        frameRate: this.frameRate,
        pxPerFrame: this.pxPerFrame,
        scaleType: this.scaleType,
        leftPadding: this.getLeftPadding(),
        rightPadding: this.getRightPadding()
      })
        .height(TIME_RULER_HEIGHT)
        .width(this.getContentWidth())
    }
    .width(this.getContentWidth())
    .height('100%')

  }

  @Builder
  private playHead() {

    Rect()
      .width(PLAY_HEAD_WIDTH)
      .height('60%')
      .fill(PLAY_HEAD_COLOR)
      .position({
        x: this.getPlayHeadX() - PLAY_HEAD_WIDTH / 2,
        y: 40
      })
      .zIndex(10)
  }

}



const PANEL_BACKGROUND_COLOR: ResourceColor = '#151515'
const PLAY_HEAD_COLOR: ResourceColor = '#FFFFFF'
const TIME_RULER_HEIGHT: number = 44
const PLAY_HEAD_WIDTH: number = 2
const MIN_PANEL_WIDTH: number = 1
