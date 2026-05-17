import { VideoFrameRateEnum, VideoFrameRateUtil } from '../../videoedit/constants/VideoFrameRateEnum'

/**
 * TimeFormatUtil.ets
 *
 * 时间轴时间格式化工具类。
 *
 * 约定：
 * 1. 时间轴内部统一使用 frame 作为计算单位。
 * 2. 帧率不在本类中写死，由 VideoFrameRateEnum 统一管理。
 * 3. 整秒刻度显示为 00:00、00:01、01:30。
 * 4. 非整秒帧刻度显示为 2f、4f、28f。
 */

export class TimeFormatUtil {
  static readonly ONE_SECOND_MS: number = 1000

  private constructor() {}

  private static toSafeInt(value: number): number {
    return Math.max(0, Math.floor(value))
  }

  private static toSafeNumber(value: number): number {
    return Math.max(0, value)
  }

  private static pad2(value: number): string {
    return value.toString().padStart(2, '0')
  }

  static clampNumber(value: number, minValue: number, maxValue: number): number {
    const min = Math.min(minValue, maxValue)
    const max = Math.max(minValue, maxValue)

    return Math.min(max, Math.max(min, value))
  }

  static timeMsToFrame(
    timeMs: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    const fps = VideoFrameRateUtil.getFrameRateValue(frameRate)

    return Math.floor(TimeFormatUtil.toSafeNumber(timeMs) / TimeFormatUtil.ONE_SECOND_MS * fps)
  }

  static frameToTimeMs(
    frame: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    const fps = VideoFrameRateUtil.getFrameRateValue(frameRate)

    return Math.floor(TimeFormatUtil.toSafeInt(frame) / fps * TimeFormatUtil.ONE_SECOND_MS)
  }

  static timeMsToSecond(timeMs: number): number {
    return Math.floor(TimeFormatUtil.toSafeNumber(timeMs) / TimeFormatUtil.ONE_SECOND_MS)
  }

  static frameToSecond(
    frame: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    const fps = VideoFrameRateUtil.getFrameRateValue(frameRate)

    return Math.floor(TimeFormatUtil.toSafeInt(frame) / fps)
  }

  static getFrameInSecond(
    frame: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    const fps = VideoFrameRateUtil.getFrameRateValue(frameRate)

    return TimeFormatUtil.toSafeInt(frame) % fps
  }

  static isSecondFrame(
    frame: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): boolean {
    return TimeFormatUtil.getFrameInSecond(frame, frameRate) === 0
  }

  static formatSecondText(totalSecond: number): string {
    const safeSecond = TimeFormatUtil.toSafeInt(totalSecond)
    const minute = Math.floor(safeSecond / 60)
    const second = safeSecond % 60

    return `${TimeFormatUtil.pad2(minute)}:${TimeFormatUtil.pad2(second)}`
  }

  static formatTimeMsText(timeMs: number): string {
    return TimeFormatUtil.formatSecondText(TimeFormatUtil.timeMsToSecond(timeMs))
  }

  static formatFrameTimeText(
    frame: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): string {
    return TimeFormatUtil.formatSecondText(TimeFormatUtil.frameToSecond(frame, frameRate))
  }

  static formatRulerTickText(
    frame: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): string {
    const safeFrame = TimeFormatUtil.toSafeInt(frame)
    const frameInSecond = TimeFormatUtil.getFrameInSecond(safeFrame, frameRate)

    return frameInSecond === 0
      ? TimeFormatUtil.formatFrameTimeText(safeFrame, frameRate)
      : `${frameInSecond}f`
  }

  static clampTimeMs(timeMs: number, durationTime: number): number {
    return TimeFormatUtil.clampNumber(
      timeMs,
      0,
      TimeFormatUtil.toSafeNumber(durationTime)
    )
  }

  static clampFrame(frame: number, totalFrame: number): number {
    return TimeFormatUtil.clampNumber(
      frame,
      0,
      TimeFormatUtil.toSafeInt(totalFrame)
    )
  }

  static getTotalFrameByDurationTime(
    durationTime: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    const fps = VideoFrameRateUtil.getFrameRateValue(frameRate)

    return Math.ceil(TimeFormatUtil.toSafeNumber(durationTime) / TimeFormatUtil.ONE_SECOND_MS * fps)
  }
}