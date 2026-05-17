

@Preview
@ComponentV2
export struct TimeRuler {
  @Require @Param durationMs: number        // 总时长
  @Require @Param fps: number               // 帧率
  @Require @Param halfViewport: number      // 半屏宽度
  @Require @Param secondWidth: number       // 秒宽度

  build() {

  }

}
