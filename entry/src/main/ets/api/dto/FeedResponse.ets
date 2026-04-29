import { VideoFeedItem } from '../../model/VideoFeedItem'

export interface FeedResponse {
  code: number
  message: string
  data: VideoFeedItem[]
}