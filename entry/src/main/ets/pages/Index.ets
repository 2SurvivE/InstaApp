import { DEBUG, INFO, ERROR , FATAL, WARN} from '../common/utils/logutils/index'

import * as provider from '../ts-api/provider'

const tag = 'EntryPage'


@Entry
@Component
struct Index {
  build() {
    Stack() {
      Image($r('app.media.index_page_background'))
        .height('100%')
        .width('100%')

      Column(){
        Text($r('app.string.EntryPage_WaterLabel'))
          .fontColor(Color.White)
          .fontSize(20)
          .padding({bottom:40})

      }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End)
        .alignItems(HorizontalAlign.Center)
        .zIndex(2)

    }
      .height('100%')
      .width('100%')
      .expandSafeArea(
        [SafeAreaType.SYSTEM, SafeAreaType.CUTOUT],
        [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM, SafeAreaEdge.START, SafeAreaEdge.END]
      )
  }
}