/**
 * VideoFrameRateEnum.ets
 *
 * 视频编辑项目帧率枚举。
 *
 * 注意：
 * 这里定义的是“项目时间轴帧率”，不是原始视频文件的 VFR 可变帧率。
 * TimeRuler、TimeLinePanel、VideoTrack、AudioTrack 应统一使用这里的帧率。
 */

export enum VideoFrameRateEnum {
  FPS_24 = 24,
  FPS_25 = 25,
  FPS_30 = 30,
  FPS_50 = 50,
  FPS_60 = 60
}

export class VideoFrameRateUtil {
  private constructor() {}

  static readonly DEFAULT_FRAME_RATE: VideoFrameRateEnum = VideoFrameRateEnum.FPS_30

  static getFrameRateValue(frameRate: VideoFrameRateEnum): number {
    return frameRate as number
  }

  static getFrameRateText(frameRate: VideoFrameRateEnum): string {
    return `${VideoFrameRateUtil.getFrameRateValue(frameRate)}fps`
  }

  static getAllFrameRates(): VideoFrameRateEnum[] {
    return [
      VideoFrameRateEnum.FPS_24,
      VideoFrameRateEnum.FPS_25,
      VideoFrameRateEnum.FPS_30,
      VideoFrameRateEnum.FPS_50,
      VideoFrameRateEnum.FPS_60
    ]
  }

  static isValidFrameRate(frameRate: VideoFrameRateEnum): boolean {
    return VideoFrameRateUtil.getAllFrameRates().includes(frameRate)
  }

  static normalizeFrameRate(frameRate: VideoFrameRateEnum): VideoFrameRateEnum {
    if (VideoFrameRateUtil.isValidFrameRate(frameRate)) {
      return frameRate
    }

    return VideoFrameRateUtil.DEFAULT_FRAME_RATE
  }
}