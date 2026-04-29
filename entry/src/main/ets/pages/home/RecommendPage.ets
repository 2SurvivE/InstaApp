import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { DEBUG, ERROR, INFO, FATAL, WARN } from "../../common/utils/logutils";
import VideoCard from '../../view/component/VideoCard'
import { requestFeedList } from '../../api/FeedApi'
import { VideoFeedItem } from '../../model/VideoFeedItem';

const tag = 'RecommendPage'

@Preview
@Component
export default struct RecommendPage {
  @State previewInfo: VideoFeedItem[] = createPlaceholderItems(8)

  async aboutToAppear(): Promise<void> {
    await this.loadFeed()
  }

  private async loadFeed(): Promise<void> {
    const list: VideoFeedItem[] = await requestFeedList()

    if (list.length <= 0) {
      ERROR(tag, 'requestFeedList returned empty list')
      return
    }

    this.previewInfo = list
  }

  build() {
    Column() {
      WaterFlow(){
        ForEach(
          this.previewInfo,
          (item: VideoFeedItem, index: number)=>{
            VideoCard(
              {
                coverPageUrl:item.coverUrl,
                authorAvatarUrl:item.authorAvatarUrl,
                authorNickname:item.authorNickname,
                coverWidth:item.coverWidth,
                coverHeight:item.coverHeight
              }
            )
          },
          (item:VideoFeedItem, index:number)=> `${item.id}_${index}`
        )
      }
        .columnsTemplate('1fr 1fr')
        .columnsGap(5)
        .rowsGap(5)
        .width('100%')
        .height('100%')
        .padding({ left: 5, right: 5 })
    }
    .height('100%')
    .width('100%')
  }
}

function createPlaceholderItems(count: number): VideoFeedItem[] {
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