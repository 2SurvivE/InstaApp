import { DEBUG } from "../../common/utils/logutils";

import RecommendPage from './RecommendPage'
import MallPage from './MallPage'
import TutorialPage from './TutorialPage'

const tag = 'HomePage'

@Component
struct HeaderTabs {
  @Link selectedIndex: number;

  build() {
    Stack() {

      Row({ space: 8 }) {
        ForEach(
          this.mainTabsText,
          (item: string, index: number) => {
            Button(item)
              .backgroundColor(Color.Transparent)
              .padding(0)
              .fontColor(index === this.selectedIndex ? Color.Black : Color.Gray)
              .fontWeight(30)
              .fontSize(index === this.selectedIndex ? 28 : 20)
              .onClick(
                () => {
                  DEBUG(tag, `Press the ${index}`)
                  this.selectedIndex = index
                }
              )
          }
        )
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Button() {
        SymbolGlyph($r('sys.symbol.envelope'))
          .fontSize(20)
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .padding(0)
      .align(Alignment.Center)
      .margin({ left: 10 })

    }
    .width('100%')
    .height(40)
    .alignContent(Alignment.TopStart)
  }

  private mainTabsText: string[] = ['商城', '推荐', '教程']
}

@Preview
@Component
export struct HomePage {
  @State private selectedIndex: number = 1

  build() {
    NavDestination() {
      Column() {

        HeaderTabs({ selectedIndex: this.selectedIndex })
          .width('100%')

        Divider()
          .color(Color.Black)

        this.contentArea()

      }
      .height('100%')
      .width('100%')
      .padding({ top: 24 })
    }
  }

  @Builder
  contentArea() {
    Stack() {
      if (this.selectedIndex === 0) {
        MallPage()
      } else if (this.selectedIndex === 1) {
        RecommendPage()
      } else {
        TutorialPage()
      }
    }
      .layoutWeight(1)
  }
}