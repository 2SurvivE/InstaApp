import { DEBUG } from '../../../../common/utils/logutils'
import { VideoFrameRateEnum, VideoFrameRateUtil } from '../../constants/VideoFrameRateEnum'
import { TimeFormatUtil } from './TimeFormatUtil'

import { TimeRulerScaleType, TimeRulerScaleUtil } from './TimeRulerScale'
const tag = 'TimeRulerTickUtil'
/**
 * TimeRulerTickUtil.ets
 *
 * 时间标尺刻度生成工具。
 *
 * 职责：
 * 1. 根据 durationTime 生成总帧数。
 * 2. 根据 scaleType 和 frameRate 计算刻度间隔 intervalFrame。
 * 3. 生成 TimeRuler 需要渲染的刻度数组。
 * 4. 处理视频末尾不足一个完整刻度时，不生成末尾残缺刻度。
 *
 * 注意：
 * 这个文件不负责 UI 绘制，也不负责 frame -> x 坐标计算。
 * 它只生成“刻度数据”。
 */

/**
 * 单个时间标尺刻度。
 */
export interface TimeRulerTick {
  /**
   * 当前刻度对应的绝对帧。
   *
   * 示例：
   * 0f、30f、60f、300f
   */
  frame: number

  /**
   * 当前刻度显示文本。
   *
   * 示例：
   * 00:00、00:01、2f、28f
   */
  text: string

  /**
   * 是否是整秒刻度。
   *
   * true:
   * 00:00、00:01、00:02
   *
   * false:
   * 2f、4f、28f
   */
  isSecondTick: boolean

  /**
   * 是否是第一个刻度。
   */
  isFirstTick: boolean

  /**
   * 是否是最后一个完整刻度。
   */
  isLastTick: boolean
}

/**
 * 生成刻度时需要的参数。
 */
export interface TimeRulerTickOptions {
  /**
   * 视频总时长，单位：毫秒。
   */
  durationTime: number

  /**
   * 当前缩放档位。
   */
  scaleType: TimeRulerScaleType

  /**
   * 项目时间轴帧率。
   */
  frameRate?: VideoFrameRateEnum
}

export class TimeRulerTickUtil {
  private constructor() {}

  /**
   * 获取视频总帧数。
   *
   * 示例：
   * durationTime = 698000ms
   * frameRate = 30fps
   * totalFrame = 20940f
   */
  static getTotalFrame(
    durationTime: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    return TimeFormatUtil.getTotalFrameByDurationTime(durationTime, frameRate)
  }

  /**
   * 获取当前缩放档位下的刻度间隔帧数。
   *
   * 示例：
   * scaleType = 10s, frameRate = 30fps -> 300f
   * scaleType = 10s, frameRate = 60fps -> 600f
   * scaleType = 2f,  frameRate = 60fps -> 2f
   */
  static getIntervalFrame(
    scaleType: TimeRulerScaleType,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {
    return TimeRulerScaleUtil.getIntervalFrame(scaleType, frameRate)
  }

  /**
   * 获取最后一个完整刻度对应的帧。
   *
   * 规则：
   * 视频结尾如果不足一个完整刻度，不生成额外刻度。
   *
   * 示例：
   * totalFrame = 20940f
   * intervalFrame = 300f
   *
   * lastTickFrame = floor(20940 / 300) * 300
   *               = 69 * 300
   *               = 20700f
   *
   * 对应时间：11:30
   *
   * 所以不会出现 11:38 这个非完整刻度。
   */
  static getLastTickFrame(totalFrame: number, intervalFrame: number): number {
    const safeTotalFrame = Math.max(0, Math.floor(totalFrame))
    const safeIntervalFrame = Math.max(1, Math.floor(intervalFrame))

    return Math.floor(safeTotalFrame / safeIntervalFrame) * safeIntervalFrame
  }

  /**
   * 根据总帧数和间隔帧数生成刻度数组。
   *
   * 这是最核心的刻度生成方法。
   */
  static buildTicksByFrame(
    totalFrame: number,
    intervalFrame: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): TimeRulerTick[] {
    const safeTotalFrame = Math.max(0, Math.floor(totalFrame))
    const safeIntervalFrame = Math.max(1, Math.floor(intervalFrame))
    const lastTickFrame = TimeRulerTickUtil.getLastTickFrame(safeTotalFrame, safeIntervalFrame)
    const ticks: TimeRulerTick[] = []

    for (let frame = 0; frame <= lastTickFrame; frame += safeIntervalFrame) {
      ticks.push({
        frame: frame,
        text: TimeFormatUtil.formatRulerTickText(frame, frameRate),
        isSecondTick: TimeFormatUtil.isSecondFrame(frame, frameRate),
        isFirstTick: frame === 0,
        isLastTick: frame === lastTickFrame
      })
    }

    return ticks
  }

  /**
   * 根据视频时长和缩放档位生成刻度数组。
   *
   * TimeRuler 后面主要调用这个方法。
   */
  static buildTicks(options: TimeRulerTickOptions): TimeRulerTick[] {
    const frameRate = options.frameRate ?? VideoFrameRateUtil.DEFAULT_FRAME_RATE
    const totalFrame = TimeRulerTickUtil.getTotalFrame(options.durationTime, frameRate)
    const intervalFrame = TimeRulerTickUtil.getIntervalFrame(options.scaleType, frameRate)
    DEBUG(tag,`Start to build ticks, frameRate: ${frameRate}, totalFrame: ${totalFrame}, intervalFrame: ${intervalFrame}`)
    return TimeRulerTickUtil.buildTicksByFrame(totalFrame, intervalFrame, frameRate)
  }

  /**
   * 获取刻度数量。
   *
   * 后面可以用于调试或者判断是否需要降级显示。
   */
  static getTickCount(options: TimeRulerTickOptions): number {
    return TimeRulerTickUtil.buildTicks(options).length
  }

  /**
   * 判断当前配置是否至少能生成一个刻度。
   *
   * 只要 durationTime >= 0，理论上至少会生成 00:00。
   */
  static hasTicks(options: TimeRulerTickOptions): boolean {
    return TimeRulerTickUtil.getTickCount(options) > 0
  }
}