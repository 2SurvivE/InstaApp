import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { DEBUG, ERROR, INFO, FATAL, WARN } from "../../common/utils/logutils";
import VideoCard from '../../view/component/VideoCard'
import { requestFeedList } from '../../api/FeedApi'
import { VideoFeedItem } from '../../model/VideoFeedItem';
import { DialogUtil, PreferencesUtil } from '@pura/harmony-utils';
import { preferences } from '@kit.ArkData';

const tag = 'RecommendPage'

@Preview
@Component
export default struct RecommendPage {
  // @State previewInfo: VideoFeedItem[] = this.createPlaceholderItems(20)
  @State previewInfo: VideoFeedItem[] = []
  private recommendReady:boolean = false;
  private timeoutId:number = -1;

  private createPlaceholderItems(count: number): VideoFeedItem[] {
    const list: VideoFeedItem[] = []
    for (let index = 0; index < count; index++) {
      list.push({
        id: `placeholder_${index}`,
        coverUrl: '',
        videoUrl: '',
        authorAvatarUrl: '',
        authorNickname: '加载中',
        coverWidth: 339,
        coverHeight: 223
      })
    }
    return list
  }

  async aboutToAppear(): Promise<void> {
    await this.loadFeed()
  }

  async aboutToDisappear(): Promise<void> {
    if(this.timeoutId!=-1){
      clearInterval(this.timeoutId)
      this.timeoutId = -1;
    }
    return;
  }

  private async loadFeed(): Promise<void> {

    const info = await PreferencesUtil.getString('PreviewInfo_last',"",'RecommendPage')
    DEBUG(tag,`Local Cache previewInfo length is ${info?.length}`)
    DEBUG(tag,`Local Cache previewInfo is ${info}`)

    if(info.length > 0){
      this.previewInfo = JSON.parse(info) as VideoFeedItem[]
      this.recommendReady = true
    }

    DEBUG(tag,`Try to load PreviewInfo from Server ${info?.length}`)

    this.timeoutId = setTimeout(
      ()=>{
        if(!this.recommendReady){
          DialogUtil.showConfirmDialog(
            {
              title:"温馨提示",
              message: "无法从服务器获取数据",
              confirm: "确认",
              onAction: ()=>{
              }
            }
          )
        }
        if(this.timeoutId!=-1){
          clearInterval(this.timeoutId)
          this.timeoutId = -1;
        }
      },
      5000
    )

    const list: VideoFeedItem[] = await requestFeedList()

    if (list.length <= 0) {
      ERROR(tag, 'requestFeedList returned empty list')
      return
    }else{
      this.previewInfo = list
      this.recommendReady = true
      await PreferencesUtil.put('PreviewInfo_last',JSON.stringify(this.previewInfo),'RecommendPage')
    }

  }

  build() {
    Column() {
      WaterFlow() {

        ForEach(
          this.previewInfo,
          (item: VideoFeedItem, index: number) => {
            VideoCard(
              {
                coverPageUrl: item.coverUrl,
                authorAvatarUrl: item.authorAvatarUrl,
                authorNickname: item.authorNickname,
                coverWidth: item.coverWidth,
                coverHeight: item.coverHeight,
                videoUrl: item.videoUrl,
                topMargin: index<2 ? 5 : 0
              }
            )
          },
          (item: VideoFeedItem, index: number) => `${item.id}_${index}`
        )

      }
        .columnsTemplate('1fr 1fr')
        .columnsGap(5)
        .rowsGap(5)
        .width('100%')
        .height('100%')
        .padding({ left: 5, right: 5, bottom : 20})
    }
      .height('100%')
      .width('100%')
  }
}
