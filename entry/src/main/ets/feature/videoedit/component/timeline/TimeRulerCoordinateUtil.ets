import { VideoFrameRateEnum, VideoFrameRateUtil } from '../../constants/VideoFrameRateEnum'
import { TimeFormatUtil } from './TimeFormatUtil'

/**
 * TimeRulerCoordinateUtil.ets
 *
 * 时间轴坐标计算工具。
 *
 * 职责：
 * 1. frame -> x
 * 2. x -> frame
 * 3. currentTime -> scrollOffsetX
 * 4. scrollOffsetX -> currentTime
 * 5. 计算 TimeRuler / VideoTrack / AudioTrack 的内容总宽度
 *
 * 核心约定：
 * 1. 时间轴内部统一使用 frame。
 * 2. x 坐标单位使用 vp。
 * 3. leftPadding 必须等于固定播放线 PlayHead 的 x 坐标。
 * 4. 00:00 的中心点、视频轨道起点、播放线中心必须三者对齐。
 *
 * 坐标模型：
 * tickX = leftPadding + frame * pxPerFrame
 *
 * 内容总宽度：
 * contentWidth = leftPadding + totalFrame * pxPerFrame + rightPadding
 */
export class TimeRulerCoordinateUtil {
  private constructor() {}

  /**
   * 防止 pxPerFrame 传入 0 或负数。
   *
   * pxPerFrame 是时间轴缩放的核心参数。
   * 它表示 1 帧占多少 vp。
   */
  private static normalizePxPerFrame(pxPerFrame: number): number {
    return Math.max(0.01, pxPerFrame)
  }

  /**
   * 统一把数字转成非负数。
   */
  private static toSafeNumber(value: number): number {
    return Math.max(0, value)
  }

  /**
   * 统一把数字转成非负整数。
   */
  private static toSafeInt(value: number): number {
    return Math.max(0, Math.floor(value))
  }

  /**
   * 根据视频时长计算总帧数。
   *
   * 示例：
   * durationTime = 1000ms
   * frameRate = 30fps
   * totalFrame = 30f
   */
  static getTotalFrame(
    durationTime: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    return TimeFormatUtil.getTotalFrameByDurationTime(durationTime, frameRate)
  }

  /**
   * 根据总帧数计算视频轨道宽度。
   *
   * 注意：
   * 这里返回的是视频真实内容宽度，不包含 leftPadding 和 rightPadding。
   *
   * 示例：
   * totalFrame = 30
   * pxPerFrame = 2
   * trackWidth = 60
   */
  static getTrackWidthByFrame(totalFrame: number, pxPerFrame: number): number {
    return TimeRulerCoordinateUtil.toSafeInt(totalFrame) *
    TimeRulerCoordinateUtil.normalizePxPerFrame(pxPerFrame)
  }

  /**
   * 根据视频时长计算视频轨道宽度。
   *
   * 注意：
   * 返回值不包含 leftPadding 和 rightPadding。
   */
  static getTrackWidthByDurationTime(
    durationTime: number,
    pxPerFrame: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    const totalFrame = TimeRulerCoordinateUtil.getTotalFrame(durationTime, frameRate)

    return TimeRulerCoordinateUtil.getTrackWidthByFrame(totalFrame, pxPerFrame)
  }

  /**
   * 根据总帧数计算横向滚动内容总宽度。
   *
   * 内容总宽度 = 左侧留白 + 视频内容宽度 + 右侧留白
   *
   * leftPadding：
   *   用来保证 00:00 可以对齐固定播放线。
   *
   * rightPadding：
   *   用来保证视频末尾可以滚动到固定播放线。
   */
  static getContentWidthByFrame(
    totalFrame: number,
    pxPerFrame: number,
    leftPadding: number,
    rightPadding: number
  ): number {
    const trackWidth = TimeRulerCoordinateUtil.getTrackWidthByFrame(totalFrame, pxPerFrame)

    return TimeRulerCoordinateUtil.toSafeNumber(leftPadding) +
      trackWidth +
    TimeRulerCoordinateUtil.toSafeNumber(rightPadding)
  }

  /**
   * 根据视频时长计算横向滚动内容总宽度。
   */
  static getContentWidthByDurationTime(
    durationTime: number,
    pxPerFrame: number,
    leftPadding: number,
    rightPadding: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    const totalFrame = TimeRulerCoordinateUtil.getTotalFrame(durationTime, frameRate)

    return TimeRulerCoordinateUtil.getContentWidthByFrame(
      totalFrame,
      pxPerFrame,
      leftPadding,
      rightPadding
    )
  }

  /**
   * frame -> x。
   *
   * 这是时间标尺最核心的坐标公式。
   *
   * 示例：
   * leftPadding = 235
   * pxPerFrame = 2
   * frame = 0
   * x = 235
   *
   * frame = 30
   * x = 235 + 30 * 2 = 295
   */
  static frameToX(
    frame: number,
    pxPerFrame: number,
    leftPadding: number
  ): number {
    return TimeRulerCoordinateUtil.toSafeInt(frame) *
    TimeRulerCoordinateUtil.normalizePxPerFrame(pxPerFrame) +
    TimeRulerCoordinateUtil.toSafeNumber(leftPadding)
  }

  /**
   * x -> frame。
   *
   * 传入的是 Scroll 内容内部的 x 坐标。
   *
   * 示例：
   * leftPadding = 235
   * pxPerFrame = 2
   * x = 295
   * frame = 30
   */
  static xToFrame(
    x: number,
    pxPerFrame: number,
    leftPadding: number,
    totalFrame: number
  ): number {
    const rawFrame = Math.round(
      (TimeRulerCoordinateUtil.toSafeNumber(x) - TimeRulerCoordinateUtil.toSafeNumber(leftPadding)) /
      TimeRulerCoordinateUtil.normalizePxPerFrame(pxPerFrame)
    )

    return TimeFormatUtil.clampFrame(rawFrame, totalFrame)
  }

  /**
   * frame -> scrollOffsetX。
   *
   * 这里不要加 leftPadding。
   *
   * 原因：
   * Scroll 的内容本身已经包含 leftPadding。
   * 初始 scrollOffsetX = 0 时，00:00 已经位于 leftPadding，也就是播放线下面。
   *
   * 所以：
   * currentFrame = 0
   * scrollOffsetX = 0
   *
   * currentFrame = 30
   * pxPerFrame = 2
   * scrollOffsetX = 60
   */
  static frameToScrollOffsetX(
    frame: number,
    pxPerFrame: number,
    totalFrame: number
  ): number {
    const safeFrame = TimeFormatUtil.clampFrame(
      TimeRulerCoordinateUtil.toSafeInt(frame),
      totalFrame
    )

    return safeFrame * TimeRulerCoordinateUtil.normalizePxPerFrame(pxPerFrame)
  }

  /**
   * scrollOffsetX -> frame。
   *
   * 这里也不要减 leftPadding。
   *
   * 因为 scrollOffsetX 表示内容整体向左滚动了多少。
   * 当内容向左滚动 60vp，并且 pxPerFrame = 2 时：
   *
   * currentFrame = 60 / 2 = 30f
   */
  static scrollOffsetXToFrame(
    scrollOffsetX: number,
    pxPerFrame: number,
    totalFrame: number
  ): number {
    const rawFrame = Math.round(
      TimeRulerCoordinateUtil.toSafeNumber(scrollOffsetX) /
      TimeRulerCoordinateUtil.normalizePxPerFrame(pxPerFrame)
    )

    return TimeFormatUtil.clampFrame(rawFrame, totalFrame)
  }

  /**
   * currentTime -> currentFrame。
   */
  static timeMsToFrame(
    timeMs: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    return TimeFormatUtil.timeMsToFrame(timeMs, frameRate)
  }

  /**
   * currentFrame -> currentTime。
   */
  static frameToTimeMs(
    frame: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    return TimeFormatUtil.frameToTimeMs(frame, frameRate)
  }

  /**
   * currentTime -> scrollOffsetX。
   *
   * 外部设置 currentTime 时，可以通过这个方法计算 Scroll 应该滚动到哪里。
   */
  static timeMsToScrollOffsetX(
    timeMs: number,
    durationTime: number,
    pxPerFrame: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    const totalFrame = TimeRulerCoordinateUtil.getTotalFrame(durationTime, frameRate)
    const currentFrame = TimeRulerCoordinateUtil.timeMsToFrame(timeMs, frameRate)

    return TimeRulerCoordinateUtil.frameToScrollOffsetX(
      currentFrame,
      pxPerFrame,
      totalFrame
    )
  }

  /**
   * scrollOffsetX -> currentTime。
   *
   * 用户横向拖动时间轴时，可以通过这个方法反算 currentTime。
   */
  static scrollOffsetXToTimeMs(
    scrollOffsetX: number,
    durationTime: number,
    pxPerFrame: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    const totalFrame = TimeRulerCoordinateUtil.getTotalFrame(durationTime, frameRate)
    const frame = TimeRulerCoordinateUtil.scrollOffsetXToFrame(
      scrollOffsetX,
      pxPerFrame,
      totalFrame
    )

    return TimeFormatUtil.clampTimeMs(
      TimeRulerCoordinateUtil.frameToTimeMs(frame, frameRate),
      durationTime
    )
  }

  /**
   * 计算右侧留白。
   *
   * 常用规则：
   * rightPadding = panelWidth - playHeadX
   *
   * 这样视频末尾可以滚动到播放线下面。
   */
  static getRightPadding(panelWidth: number, playHeadX: number): number {
    return Math.max(
      0,
      TimeRulerCoordinateUtil.toSafeNumber(panelWidth) -
      TimeRulerCoordinateUtil.toSafeNumber(playHeadX)
    )
  }

  /**
   * 计算默认播放线位置。
   *
   * 当前先使用面板中心。
   * 后面如果 UI 设计要求白线偏左或偏右，只需要替换这里的策略。
   */
  static getDefaultPlayHeadX(panelWidth: number): number {
    return TimeRulerCoordinateUtil.toSafeNumber(panelWidth) / 2
  }

  /**
   * 根据播放线位置获取 leftPadding。
   *
   * 这里单独封装，是为了强调：
   * leftPadding 本质上就是 playHeadX。
   */
  static getLeftPaddingByPlayHeadX(playHeadX: number): number {
    return TimeRulerCoordinateUtil.toSafeNumber(playHeadX)
  }
}