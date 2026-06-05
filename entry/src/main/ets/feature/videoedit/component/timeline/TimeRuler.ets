import { DEBUG } from '../../../../common/utils/logutils'
import {
  FRAME_TICK_HEIGHT,
  LABEL_HEIGHT,
  SECOND_TICK_HEIGHT,
  TICK_ITEM_WIDTH,
  TICK_WIDTH,
  TIME_RULER_HEIGHT
} from '../../constants/TimeLineConstant'
import { TimeRulerCoordinateUtil } from './TimeRulerCoordinateUtil'
import { TimeRulerScaleType } from './TimeRulerScale'
import { TimeRulerTick, TimeRulerTickUtil } from './TimeRulerTickUtil'

@Preview
@ComponentV2
export struct TimeRuler {
  @Require @Param currentTime: number
  @Require @Param durationTime: number
  @Require @Param frameRate: number
  @Require @Param scaleType: TimeRulerScaleType
  @Require @Param pxPerFrame: number // 每一帧占多少 vp。这是时间轴横向缩放的核心参数。
  @Require @Param leftPadding: number
  @Require @Param rightPadding: number
  @Param onTimeChange: (timeMs: number) => void = (_timeMs: number) => {}

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      ForEach(
        this.getTicks(),
        (tick: TimeRulerTick) => {
          this.tickItem(tick)
        },
        (tick: TimeRulerTick) => `${tick.frame}`
      )
    }
    .width(this.getContentWidth())
    .height(TIME_RULER_HEIGHT)
    .backgroundColor('#151515')
    .onClick((event: ClickEvent) => {
      this.handleClick(event)
    })
  }

  // 计算视频总帧数
  private getTotalFrame(): number {
    return TimeRulerCoordinateUtil.getTotalFrame(this.durationTime, this.frameRate)
  }

  // 计算整个标尺的宽度 = 左留白 + durationTime*pxPerFrame + 右留白
  private getContentWidth(): number {
    return TimeRulerCoordinateUtil.getContentWidthByDurationTime(
      this.durationTime,
      this.pxPerFrame,
      this.leftPadding,
      this.rightPadding,
      this.frameRate
    )
  }

  // 计算标尺的Tick（获取当前缩放档位下需要渲染的刻度数组）
  // 这个宽度应该和后续 VideoTrack、AudioTrack 的滚动内容宽度保持一致。
  private getTicks(): TimeRulerTick[] {
    return TimeRulerTickUtil.buildTicks(
      {
        durationTime: this.durationTime,
        scaleType: this.scaleType,
        frameRate: this.frameRate
      }
    )
  }

  // 根据帧数计算当前刻度在 TimeRuler 内容区域中的 x 坐标。
  private getTickX(frame: number): number {
    return TimeRulerCoordinateUtil.frameToX(frame, this.pxPerFrame, this.leftPadding)
  }

  private getTickLineHeight(tick: TimeRulerTick) {
    return tick.isSecondTick ? SECOND_TICK_HEIGHT : FRAME_TICK_HEIGHT
  }

  private getTickLineColor(tick: TimeRulerTick) {
    return tick.isSecondTick ? '#8A8A8A' : '#5A5A5A'
  }

  private getTickTextColor(tick: TimeRulerTick): ResourceColor {
    return tick.isSecondTick ? '#E6E6E6' : '#8A8A8A'
  }

  private handleClick(event: ClickEvent): void {

    const totalFrame = this.getTotalFrame()

    const frame = TimeRulerCoordinateUtil.xToFrame(

      event.x,

      this.pxPerFrame,

      this.leftPadding,

      totalFrame

    )

    const timeMs = TimeRulerCoordinateUtil.frameToTimeMs(frame, this.frameRate)

    this.onTimeChange(timeMs)

  }

  @Builder
  private tickItem(tick: TimeRulerTick) {
    Column() {
      Text(tick.text)
        .fontSize(11)
        .fontColor(this.getTickTextColor(tick))
        .height(LABEL_HEIGHT)
        .width(TICK_ITEM_WIDTH)
        .maxLines(1)
        .textOverflow({
          overflow: TextOverflow.Clip
        })
        .textAlign(TextAlign.Center)
      Rect()
        .width(TICK_WIDTH)
        .height(this.getTickLineHeight(tick))
        .fill(this.getTickLineColor(tick))
    }
    .width(TICK_ITEM_WIDTH)
    .height(TIME_RULER_HEIGHT)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .position({
      x: this.getTickX(tick.frame) - TICK_ITEM_WIDTH / 2,
      y: 0
    })

  }
}
