/**
 * TimeRulerScale.ets

 *

 * 时间标尺缩放档位定义。

 *

 * 说明：

 * 1. 秒级档位：10s、5s、3s、2s、1s

 *    实际 intervalFrame 需要根据项目帧率计算。

 *

 * 2. 帧级档位：15f、10f、5f、3f、2f

 *    实际 intervalFrame 直接等于对应帧数。

 *

 * 3. 当前文件只描述“刻度间隔”，不处理 pxPerFrame。

 *    pxPerFrame 属于坐标/缩放显示逻辑，后面单独处理。

 */
import { VideoFrameRateEnum, VideoFrameRateUtil } from "../../constants/VideoFrameRateEnum"

export enum TimeRulerScaleType {

  SCALE_10S = '10s',

  SCALE_5S = '5s',

  SCALE_3S = '3s',

  SCALE_2S = '2s',

  SCALE_1S = '1s',

  SCALE_15F = '15f',

  SCALE_10F = '10f',

  SCALE_5F = '5f',

  SCALE_3F = '3f',

  SCALE_2F = '2f'

}

export enum TimeRulerScaleUnit {
  SECOND = 'second',
  FRAME = 'frame'
}

export interface TimeRulerScaleInfo {
  type: TimeRulerScaleType
  unit: TimeRulerScaleUnit
  value: number
  text: string
}

export class TimeRulerScaleUtil {

  private constructor() {}

  static readonly DEFAULT_SCALE_INDEX: number = 4

  private static readonly SCALE_LIST: TimeRulerScaleInfo[] = [

    {

      type: TimeRulerScaleType.SCALE_10S,

      unit: TimeRulerScaleUnit.SECOND,

      value: 10,

      text: '10s'

    },

    {

      type: TimeRulerScaleType.SCALE_5S,

      unit: TimeRulerScaleUnit.SECOND,

      value: 5,

      text: '5s'

    },

    {

      type: TimeRulerScaleType.SCALE_3S,

      unit: TimeRulerScaleUnit.SECOND,

      value: 3,

      text: '3s'

    },

    {

      type: TimeRulerScaleType.SCALE_2S,

      unit: TimeRulerScaleUnit.SECOND,

      value: 2,

      text: '2s'

    },

    {

      type: TimeRulerScaleType.SCALE_1S,

      unit: TimeRulerScaleUnit.SECOND,

      value: 1,

      text: '1s'

    },

    {

      type: TimeRulerScaleType.SCALE_15F,

      unit: TimeRulerScaleUnit.FRAME,

      value: 15,

      text: '15f'

    },

    {

      type: TimeRulerScaleType.SCALE_10F,

      unit: TimeRulerScaleUnit.FRAME,

      value: 10,

      text: '10f'

    },

    {

      type: TimeRulerScaleType.SCALE_5F,

      unit: TimeRulerScaleUnit.FRAME,

      value: 5,

      text: '5f'

    },

    {

      type: TimeRulerScaleType.SCALE_3F,

      unit: TimeRulerScaleUnit.FRAME,

      value: 3,

      text: '3f'

    },

    {

      type: TimeRulerScaleType.SCALE_2F,

      unit: TimeRulerScaleUnit.FRAME,

      value: 2,

      text: '2f'

    }

  ]

  static getScaleList(): TimeRulerScaleInfo[] {

    return TimeRulerScaleUtil.SCALE_LIST.slice()

  }

  static getScaleCount(): number {

    return TimeRulerScaleUtil.SCALE_LIST.length

  }

  static getDefaultScaleInfo(): TimeRulerScaleInfo {

    return TimeRulerScaleUtil.getScaleInfoByIndex(TimeRulerScaleUtil.DEFAULT_SCALE_INDEX)

  }

  static getDefaultScaleType(): TimeRulerScaleType {

    return TimeRulerScaleUtil.getDefaultScaleInfo().type

  }

  static clampScaleIndex(index: number): number {

    const maxIndex = TimeRulerScaleUtil.SCALE_LIST.length - 1

    return Math.min(maxIndex, Math.max(0, Math.floor(index)))

  }

  static getScaleInfoByIndex(index: number): TimeRulerScaleInfo {

    return TimeRulerScaleUtil.SCALE_LIST[TimeRulerScaleUtil.clampScaleIndex(index)]

  }

  static getScaleTypeByIndex(index: number): TimeRulerScaleType {

    return TimeRulerScaleUtil.getScaleInfoByIndex(index).type

  }

  static getScaleIndex(scaleType: TimeRulerScaleType): number {

    const index = TimeRulerScaleUtil.SCALE_LIST.findIndex((item: TimeRulerScaleInfo) => {

      return item.type === scaleType

    })

    return index >= 0 ? index : TimeRulerScaleUtil.DEFAULT_SCALE_INDEX

  }

  static getScaleInfo(scaleType: TimeRulerScaleType): TimeRulerScaleInfo {

    const index = TimeRulerScaleUtil.getScaleIndex(scaleType)

    return TimeRulerScaleUtil.SCALE_LIST[index]

  }

  static getPreviousScaleIndex(index: number): number {

    return TimeRulerScaleUtil.clampScaleIndex(index - 1)

  }

  static getNextScaleIndex(index: number): number {

    return TimeRulerScaleUtil.clampScaleIndex(index + 1)

  }

  static getPreviousScaleType(scaleType: TimeRulerScaleType): TimeRulerScaleType {

    const currentIndex = TimeRulerScaleUtil.getScaleIndex(scaleType)

    const previousIndex = TimeRulerScaleUtil.getPreviousScaleIndex(currentIndex)

    return TimeRulerScaleUtil.getScaleTypeByIndex(previousIndex)

  }

  static getNextScaleType(scaleType: TimeRulerScaleType): TimeRulerScaleType {

    const currentIndex = TimeRulerScaleUtil.getScaleIndex(scaleType)

    const nextIndex = TimeRulerScaleUtil.getNextScaleIndex(currentIndex)

    return TimeRulerScaleUtil.getScaleTypeByIndex(nextIndex)

  }

  static isMinScaleIndex(index: number): boolean {

    return TimeRulerScaleUtil.clampScaleIndex(index) === 0

  }

  static isMaxScaleIndex(index: number): boolean {

    return TimeRulerScaleUtil.clampScaleIndex(index) === TimeRulerScaleUtil.SCALE_LIST.length - 1

  }

  static getIntervalFrame(
    scaleType: TimeRulerScaleType,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {

    const scaleInfo = TimeRulerScaleUtil.getScaleInfo(scaleType)

    if (scaleInfo.unit === TimeRulerScaleUnit.FRAME) {

      return scaleInfo.value

    }

    return scaleInfo.value * VideoFrameRateUtil.getFrameRateValue(frameRate)

  }

  static getIntervalFrameByIndex(
    index: number,
    frameRate: VideoFrameRateEnum = VideoFrameRateUtil.DEFAULT_FRAME_RATE
  ): number {

    const scaleType = TimeRulerScaleUtil.getScaleTypeByIndex(index)

    return TimeRulerScaleUtil.getIntervalFrame(scaleType, frameRate)

  }

  static getScaleText(scaleType: TimeRulerScaleType): string {

    return TimeRulerScaleUtil.getScaleInfo(scaleType).text

  }

  static getScaleTextByIndex(index: number): string {

    return TimeRulerScaleUtil.getScaleInfoByIndex(index).text

  }

}