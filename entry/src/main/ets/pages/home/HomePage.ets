import { DEBUG, ERROR } from "../../common/utils/logutils";

import RecommendPage from './RecommendPage'
import MallPage from './MallPage'
import TutorialPage from './TutorialPage'
import { AppUtil, EmitterUtil } from "@pura/harmony-utils";
import { AppEvents } from "../../common/event/AppEvents";
import { AppInitState, AppInitStatus } from "../../common/state/AppInitState";

const tag = 'HomePage'

@Builder
export function PageBuilder(name:string,param:object){
  HomePage()
}

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
@Entry
@Component
struct HomePage {

  private navStack:NavPathStack | null = new NavPathStack()
  @State private selectedIndex: number = 1
  @State private appReady: boolean = false
  build() {
    Navigation(this.navStack) {
      if (this.appReady) {
        this.contentArea()
      } else {
        this.splashContent()
      }
    }
    .hideTitleBar(true)
  }


  @Builder
  contentArea() {
    Column() {
      HeaderTabs({ selectedIndex: this.selectedIndex })
        .width('100%')

      Divider()
        .color(Color.Black)

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

      Button('VideoEditPage')
        .onClick(
          ()=>{
            this.navStack?.pushPathByName("VideoEditPage",null)
          }
        )
    }
    .height('100%')
    .width('100%')
    .padding({ top: this.getUIContext().px2vp(AppUtil.getStatusBarHeight()) })
  }

  @Builder
  splashContent(){
    Stack() {
      Image($r('app.media.index_page_background'))
        .height('100%')
        .width('100%')
        .objectFit(ImageFit.Cover)
        .zIndex(0)

      Column() {
        Text($r('app.string.EntryPage_WaterLabel'))
          .fontColor(Color.White)
          .fontSize(20)
          .padding({ bottom: 40 })
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

  private unsubscribeAppInit(): void {
    EmitterUtil.unSubscribe(AppEvents.APP_INIT)
  }

  private subscribeAppInit(): void {
    DEBUG(tag, `Subscribe the event ${AppEvents.APP_INIT}`)

    EmitterUtil.onSubscribe<boolean>(
      AppEvents.APP_INIT,
      (isSuccess: boolean): void => {
        this.unsubscribeAppInit()

        if (isSuccess) {
          DEBUG(tag, 'App init Success')
          this.appReady = true
          return
        }

        ERROR(tag, 'App init Failed')
      }
    )
  }

  aboutToAppear(): void {
    DEBUG(tag, `Success to show PAGE:${tag}`)

    if (AppInitState.status === AppInitStatus.SUCCESS) {
      DEBUG(tag, 'App already init success before page subscribe')
      this.appReady = true
      return
    }

    if (AppInitState.status === AppInitStatus.FAILED) {
      ERROR(tag, `App already init failed, error=${AppInitState.errorMessage}`)
      return
    }

    this.subscribeAppInit()
  }

  aboutToDisappear(): void {
    this.unsubscribeAppInit()
  }

}