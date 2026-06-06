import {
  FRAME_TICK_HEIGHT,
  LABEL_HEIGHT,
  SECOND_TICK_HEIGHT,
  TICK_WIDTH,
  TIME_RULER_HEIGHT
} from '../../constants/TimeLineConstant'
import { VideoFrameRateEnum } from '../../constants/VideoFrameRateEnum'
import { TimeRulerCoordinateUtil } from './TimeRulerCoordinateUtil'
import { TimeRulerScaleType } from './TimeRulerScale'
import { TimeRulerTick, TimeRulerTickUtil } from './TimeRulerTickUtil'

@Preview
@ComponentV2
export struct TimeRuler {
  // 新增：TimeRuler 只接收刻度展示所需参数，不持有播放状态和 currentTime。
  @Require @Param durationTime: number
  @Require @Param frameRate: VideoFrameRateEnum
  @Require @Param pxPerFrame: number
  @Require @Param scaleType: TimeRulerScaleType
  @Require @Param leftPadding: number
  @Require @Param rightPadding: number

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
    .backgroundColor(RULER_BACKGROUND_COLOR)
  }

  // 新增：内容宽度统一复用坐标工具，遵循 leftPadding + totalFrame * pxPerFrame + rightPadding。
  private getContentWidth(): number {
    return TimeRulerCoordinateUtil.getContentWidthByDurationTime(
      this.durationTime,
      this.pxPerFrame,
      this.leftPadding,
      this.rightPadding,
      this.frameRate
    )
  }

  // 新增：刻度生成以 frame 为基础单位，时间换算由 TimeRulerTickUtil -> TimeFormatUtil 统一处理。
  private getTicks(): TimeRulerTick[] {
    const totalFrame = TimeRulerTickUtil.getTotalFrame(this.durationTime, this.frameRate)
    const intervalFrame = TimeRulerTickUtil.getIntervalFrame(this.scaleType, this.frameRate)

    return TimeRulerTickUtil.buildTicksByFrame(totalFrame, intervalFrame, this.frameRate)
  }

  // 新增：刻度横坐标统一复用坐标工具，公式为 leftPadding + frameIndex * pxPerFrame。
  private getTickX(frame: number): number {
    return TimeRulerCoordinateUtil.frameToX(frame, this.pxPerFrame, this.leftPadding)
  }

  // 新增：获取当前缩放档位对应的完整刻度间隔。
  private getIntervalFrame(): number {
    return TimeRulerTickUtil.getIntervalFrame(this.scaleType, this.frameRate)
  }

  // 新增：最后一个完整刻度用于判断末尾不足完整区间时不绘制标签。
  private getLastTickFrame(): number {
    const totalFrame = TimeRulerTickUtil.getTotalFrame(this.durationTime, this.frameRate)

    return TimeRulerTickUtil.getLastTickFrame(totalFrame, this.getIntervalFrame())
  }

  private getNextTickFrame(tick: TimeRulerTick): number {
    return tick.frame + this.getIntervalFrame()
  }

  private hasFullLabelInterval(tick: TimeRulerTick): boolean {
    return this.getNextTickFrame(tick) <= this.getLastTickFrame()
  }

  // 新增：标签位于当前 Rect 与下一个 Rect 的中点，Text 自身不代表真实时间点。
  private getLabelX(tick: TimeRulerTick): number {
    const currentTickX = this.getTickX(tick.frame)
    const nextTickX = this.getTickX(this.getNextTickFrame(tick))
    const labelCenterX = (currentTickX + nextTickX) / 2

    return labelCenterX - TICK_LABEL_WIDTH / 2
  }

  private getTickLineY(tick: TimeRulerTick): number {
    return (LABEL_HEIGHT - this.getTickLineHeight(tick)) / 2
  }

  private getTickLineHeight(tick: TimeRulerTick): number {
    return tick.isSecondTick ? SECOND_TICK_HEIGHT : FRAME_TICK_HEIGHT
  }

  private getTickLineColor(tick: TimeRulerTick): ResourceColor {
    return tick.isSecondTick ? SECOND_TICK_COLOR : FRAME_TICK_COLOR
  }

  private getTickTextColor(tick: TimeRulerTick): ResourceColor {
    return tick.isSecondTick ? SECOND_TEXT_COLOR : FRAME_TEXT_COLOR
  }

  @Builder
  private tickItem(tick: TimeRulerTick) {
    Stack({ alignContent: Alignment.TopStart }) {
      // 修改：Rect 绑定当前 tick 的真实 x 坐标，作为时间分割点。
      if(!tick.isFirstTick)
        Rect()
          .width(TICK_WIDTH)
          .height(this.getTickLineHeight(tick))
          .fill(this.getTickLineColor(tick))
          .position({
            x: this.getTickX(tick.frame) - TICK_WIDTH / 2,
            y: this.getTickLineY(tick)
          })

      // 修改：Text 表示当前 Rect 到下一个 Rect 的区间标签，末尾不足完整区间不绘制。
      if (this.hasFullLabelInterval(tick)) {
        Text(tick.text)
          .fontSize(11)
          .fontColor(this.getTickTextColor(tick))
          .height(LABEL_HEIGHT)
          .width(TICK_LABEL_WIDTH)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Clip })
          .textAlign(TextAlign.Center)
          .position({
            x: this.getLabelX(tick),
            y: 0
          })
      }
    }
    .width(this.getContentWidth())
    .height(TIME_RULER_HEIGHT)
  }
}

const TICK_LABEL_WIDTH: number = 52
const RULER_BACKGROUND_COLOR: ResourceColor = '#151515'
const SECOND_TICK_COLOR: ResourceColor = '#8A8A8A'
const FRAME_TICK_COLOR: ResourceColor = '#5A5A5A'
const SECOND_TEXT_COLOR: ResourceColor = '#E6E6E6'
const FRAME_TEXT_COLOR: ResourceColor = '#8A8A8A'
